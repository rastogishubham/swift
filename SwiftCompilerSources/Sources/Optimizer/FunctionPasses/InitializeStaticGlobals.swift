//===--- InitializeStaticGlobals.swift -------------------------------------==//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SIL

/// Converts a lazily initialized global to a statically initialized global variable.
///
/// When this pass runs on a global initializer `[global_init_once_fn]` it tries to
/// create a static initializer for the initialized global.
///
/// ```
///   sil [global_init_once_fn] @globalinit {
///     alloc_global @the_global
///     %a = global_addr @the_global
///     %i = some_const_initializer_insts
///     store %i to %a
///   }
/// ```
/// The pass creates a static initializer for the global:
/// ```
///   sil_global @the_global = {
///     %initval = some_const_initializer_insts
///   }
/// ```
/// and removes the allocation and store instructions from the initializer function:
/// ```
///   sil [global_init_once_fn] @globalinit {
///     %a = global_addr @the_global
///     %i = some_const_initializer_insts
///   }
/// ```
/// The initializer then becomes a side-effect free function which let's the builtin-
/// simplification remove the `builtin "once"` which calls the initializer.
///
let initializeStaticGlobalsPass = FunctionPass(name: "initialize-static-globals") {
  (function: Function, context: FunctionPassContext) in

  if !function.isGlobalInitOnceFunction {
    return
  }

  guard let (allocInst, storeToGlobal) = function.getGlobalInitialization() else {
    return
  }

  if !allocInst.global.canBeInitializedStatically {
    return
  }

  context.createStaticInitializer(for: allocInst.global,
                                  initValue: storeToGlobal.source as! SingleValueInstruction)
  context.erase(instruction: allocInst)
  context.erase(instruction: storeToGlobal)
}

private extension Function {
  /// Analyses the global initializer function and returns the `alloc_global` and `store`
  /// instructions which initialize the global.
  ///
  /// The function's single basic block must contain following code pattern:
  /// ```
  ///   alloc_global @the_global
  ///   %a = global_addr @the_global
  ///   %i = some_const_initializer_insts
  ///   store %i to %a
  /// ```
  func getGlobalInitialization() -> (allocInst: AllocGlobalInst, storeToGlobal: StoreInst)? {

    guard let block = singleBlock else {
      return nil
    }

    var allocInst: AllocGlobalInst? = nil
    var globalAddr: GlobalAddrInst? = nil
    var store: StoreInst? = nil

    for inst in block.instructions {
      switch inst {
      case is ReturnInst,
           is DebugValueInst,
           is DebugStepInst:
        break
      case let agi as AllocGlobalInst:
        if allocInst != nil {
          return nil
        }
        allocInst = agi
      case let ga as GlobalAddrInst:
        if globalAddr != nil {
          return nil
        }
        guard let agi = allocInst, agi.global == ga.global else {
          return nil
        }
        globalAddr = ga
      case let si as StoreInst:
        if store != nil {
          return nil
        }
        guard let ga = globalAddr else {
          return nil
        }
        if si.destination != ga {
          return nil
        }
        store = si
      default:
        if !inst.isValidInStaticInitializerOfGlobal {
          return nil
        }
      }
    }
    if let store = store {
      return (allocInst: allocInst!, storeToGlobal: store)
    }
    return nil
  }

  var singleBlock: BasicBlock? {
    let block = entryBlock
    if block.next != nil {
      return nil
    }
    return block
  }
}
