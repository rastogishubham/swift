// RUN: sed -n -e '/VERIFY_BEGIN/,/VERIFY_END$/ p' %s > %t_no_errors.swift
// RUN: %target-swift-frontend -verify -typecheck %t_no_errors.swift

// RUN: %empty-directory(%t)
// RUN: %target-swift-ide-test -batch-code-completion -source-filename %s -filecheck %raw-FileCheck -completion-output-dir %t

// NO_CONSTRUCTORS-NOT: init(

// NO_SUPER_DECLS-NOT: Decl/Super

//===---
//===--- Tests for code completion after 'super'.
//===---

//===--- Testcase A, with implicit constructors in the base class.

// VERIFY_BEGIN

class SuperBaseA {
  var baseInstanceVar = 0

  var baseProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  // Don't declare constructors.

  func baseFunc0() {}
  func baseFunc1(_ a: Int) {}

  subscript(i: Int) -> Double {
    get {
      return Double(i)
    }
    set(v) {
      baseInstanceVar = i
    }
  }

  // expected-error@+1 {{class stored properties not supported}}
  class var baseStaticVar: Int = 0

  class var baseStaticProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  class func baseStaticFunc0() {}

  struct BaseNestedStruct {}
  class BaseNestedClass {}
  enum BaseNestedEnum {
    case BaseEnumX(Int)
  }

  typealias BaseNestedTypealias = Int
}

extension SuperBaseA {
  var baseExtProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  func baseExtFunc0() {}

  // expected-error@+1 {{class stored properties not supported}}
  class var baseExtStaticVar: Int = 0

  class func baseExtStaticFunc0() {}

  struct BaseExtNestedStruct {}
  class BaseExtNestedClass {}
  enum BaseExtNestedEnum {
    case BaseExtEnumX(Int)
  }

  typealias BaseExtNestedTypealias = Int
}

// VERIFY_END

// COMMON_BASE_A_NO_DOT: Begin completions
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseInstanceVar[#Int#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[Subscript]/CurrNominal:      [{#(i): Int#}][#Double#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseExtProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseExtFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_NO_DOT: End completions

// COMMON_BASE_A_DOT: Begin completions
// COMMON_BASE_A_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseInstanceVar[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseExtProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseExtFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT: End completions

// COMMON_BASE_A_DOT_CONTEXT: Begin completions
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceVar]/CurrNominal/TypeRelation[Identical]: baseInstanceVar[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceVar]/CurrNominal/TypeRelation[Identical]: baseProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceVar]/CurrNominal/TypeRelation[Identical]: baseExtProp[#Int#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT-DAG: Decl[InstanceMethod]/CurrNominal: baseExtFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_A_DOT_CONTEXT: End completions

class SuperDerivedA : SuperBaseA {
  var derivedInstanceVar: Int

  func derivedFunc0() {}

  init() {
    super#^CONSTRUCTOR_SUPER_NO_DOT_1?check=COMMON_BASE_A_NO_DOT;check=CONSTRUCTOR_SUPER_NO_DOT_1^#
// CONSTRUCTOR_SUPER_NO_DOT_1: Begin completions, 8 items
// CONSTRUCTOR_SUPER_NO_DOT_1-DAG: Decl[Constructor]/CurrNominal/Flair[SuperChain]: .init()[#SuperBaseA#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_NO_DOT_1: End completions
  }

  init(a: Int) {
    super.#^CONSTRUCTOR_SUPER_DOT_1?check=COMMON_BASE_A_DOT;check=CONSTRUCTOR_SUPER_DOT_1^#
    super(#^CONSTRUCTOR_SUPER_PAREN?check=CONSTRUCTOR_SUPER_NOINIT^#
// CONSTRUCTOR_SUPER_DOT_1: Begin completions, 7 items
// CONSTRUCTOR_SUPER_DOT_1-DAG: Decl[Constructor]/CurrNominal: init()[#SuperBaseA#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_DOT_1: End completions
  }

  convenience init(foo1: Int) {
    super.#^CONV_CONSTRUCTOR_SUPER_DOT?check=CONSTRUCTOR_SUPER_NOINIT^#
    super#^CONV_CONSTRUCTOR_SUPER_NO_DOT?check=CONSTRUCTOR_SUPER_NOINIT^#
    super(#^CONV_CONSTRUCTOR_SUPER_PAREN?check=CONSTRUCTOR_SUPER_NOINIT^#
// CONSTRUCTOR_SUPER_NOINIT-NOT: Decl[Constructor]
  }

  init (a: Float) {
    super.init#^CONSTRUCTOR_SUPER_INIT_1^#
// CONSTRUCTOR_SUPER_INIT_1: Begin completions
// CONSTRUCTOR_SUPER_INIT_1-DAG: Decl[Constructor]/CurrNominal/Flair[ArgLabels]: ()[#SuperBaseA#]; name=()
// CONSTRUCTOR_SUPER_INIT_1: End completions
  }
  init (b: Float) {
    super.init(#^CONSTRUCTOR_SUPER_INIT_PAREN_1^#
// CONSTRUCTOR_SUPER_INIT_PAREN_1: Begin completions, 1 items
// CONSTRUCTOR_SUPER_INIT_PAREN_1: Decl[Constructor]/CurrNominal/Flair[ArgLabels]: ['('][')'][#SuperBaseA#]; name=
// CONSTRUCTOR_SUPER_INIT_PAREN_1: End completions
  }

  deinit {
    super#^DESTRUCTOR_SUPER_NO_DOT_1?check=COMMON_BASE_A_NO_DOT;check=DESTRUCTOR_SUPER_NO_DOT_1;check=NO_CONSTRUCTORS^#
// DESTRUCTOR_SUPER_NO_DOT_1: Begin completions, 7 items
// DESTRUCTOR_SUPER_NO_DOT_1: End completions

    var resyncParser = 42

    super.#^DESTRUCTOR_SUPER_DOT_1?check=COMMON_BASE_A_DOT;check=DESTRUCTOR_SUPER_DOT_1;check=NO_CONSTRUCTORS^#
// DESTRUCTOR_SUPER_DOT_1: Begin completions, 6 items
// DESTRUCTOR_SUPER_DOT_1: End completions
  }

  func test1() {
    super#^FUNC_SUPER_NO_DOT_1?check=COMMON_BASE_A_NO_DOT;check=FUNC_SUPER_NO_DOT_1;check=NO_CONSTRUCTORS^#
// FUNC_SUPER_NO_DOT_1: Begin completions, 7 items
// FUNC_SUPER_NO_DOT_1: End completions
  }

  func test2() {
    super.#^FUNC_SUPER_DOT_1?check=COMMON_BASE_A_DOT;check=FUNC_SUPER_DOT_1;check=NO_CONSTRUCTORS^#
// FUNC_SUPER_DOT_1: Begin completions, 6 items
// FUNC_SUPER_DOT_1: End completions
  }
}

//===--- Testcase B, with explicit constructors in the base class.

// COMMON_BASE_B_NO_DOT: Begin completions
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseInstanceVar[#Int#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseProp[#Int#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[Subscript]/CurrNominal:      [{#(i): Int#}][#Double#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceVar]/CurrNominal:    .baseExtProp[#Int#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT-DAG: Decl[InstanceMethod]/CurrNominal: .baseExtFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_B_NO_DOT: End completions

// COMMON_BASE_B_DOT: Begin completions
// COMMON_BASE_B_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseInstanceVar[#Int#]{{; name=.+$}}
// COMMON_BASE_B_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseProp[#Int#]{{; name=.+$}}
// COMMON_BASE_B_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_B_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// COMMON_BASE_B_DOT-DAG: Decl[InstanceVar]/CurrNominal:    baseExtProp[#Int#]{{; name=.+$}}
// COMMON_BASE_B_DOT-DAG: Decl[InstanceMethod]/CurrNominal: baseExtFunc0()[#Void#]{{; name=.+$}}
// COMMON_BASE_B_DOT: End completions

// VERIFY_BEGIN

class SuperBaseB {
  var baseInstanceVar: Int

  var baseProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  init() {}
  init(a: Double) {}
  init(int: Int) {}

  func baseFunc0() {}
  func baseFunc1(_ a: Int) {}

  subscript(i: Int) -> Double {
    get {
      return Double(i)
    }
    set(v) {
      baseInstanceVar = i
    }
  }

  // expected-error@+1 {{class stored properties not supported}}
  class var baseStaticVar: Int = 0

  class var baseStaticProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  class func baseStaticFunc0() {}

  struct BaseNestedStruct {}
  class BaseNestedClass {}
  enum BaseNestedEnum {
    case BaseEnumX(Int)
  }

  typealias BaseNestedTypealias = Int
}

extension SuperBaseB {
  var baseExtProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  func baseExtFunc0() {}

  // expected-error@+1 {{class stored properties not supported}}
  class var baseExtStaticVar: Int = 0

  class var baseExtStaticProp: Int {
    get {
      return 42
    }
    set(v) {}
  }

  class func baseExtStaticFunc0() {}

  struct BaseExtNestedStruct {}
  class BaseExtNestedClass {}
  enum BaseExtNestedEnum {
    case BaseExtEnumX(Int)
  }

  typealias BaseExtNestedTypealias = Int
}

// VERIFY_END

class SuperDerivedB : SuperBaseB {
  var derivedInstanceVar: Int

  func derivedFunc0() {}

  init() {
    super#^CONSTRUCTOR_SUPER_NO_DOT_2?check=COMMON_BASE_B_NO_DOT;check=CONSTRUCTOR_SUPER_NO_DOT_2^#
// CONSTRUCTOR_SUPER_NO_DOT_2: Begin completions, 10 items
// CONSTRUCTOR_SUPER_NO_DOT_2-DAG: Decl[Constructor]/CurrNominal/Flair[SuperChain]: .init()[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_NO_DOT_2-DAG: Decl[Constructor]/CurrNominal: .init({#a: Double#})[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_NO_DOT_2-DAG: Decl[Constructor]/CurrNominal: .init({#int: Int#})[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_NO_DOT_2: End completions
  }

  init(int a: Int) {
    super.#^CONSTRUCTOR_SUPER_DOT_2?check=COMMON_BASE_B_DOT;check=CONSTRUCTOR_SUPER_DOT_2^#
// CONSTRUCTOR_SUPER_DOT_2: Begin completions, 9 items
// CONSTRUCTOR_SUPER_DOT_2-DAG: Decl[Constructor]/CurrNominal: init()[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_DOT_2-DAG: Decl[Constructor]/CurrNominal: init({#a: Double#})[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_DOT_2-DAG: Decl[Constructor]/CurrNominal/Flair[SuperChain]: init({#int: Int#})[#SuperBaseB#]{{; name=.+$}}
// CONSTRUCTOR_SUPER_DOT_2: End completions
  }

  deinit {
    super#^DESTRUCTOR_SUPER_NO_DOT_2?check=COMMON_BASE_B_NO_DOT;check=DESTRUCTOR_SUPER_NO_DOT_2;check=NO_CONSTRUCTORS^#
// DESTRUCTOR_SUPER_NO_DOT_2: Begin completions, 7 items
// DESTRUCTOR_SUPER_NO_DOT_2: End completions

    var resyncParser = 42

    super.#^DESTRUCTOR_SUPER_DOT_2?check=COMMON_BASE_B_DOT;check=DESTRUCTOR_SUPER_DOT_2;check=NO_CONSTRUCTORS^#
// DESTRUCTOR_SUPER_DOT_2: Begin completions, 6 items
// DESTRUCTOR_SUPER_DOT_2: End completions
  }

  func test1() {
    super#^FUNC_SUPER_NO_DOT_2?check=COMMON_BASE_B_NO_DOT;check=FUNC_SUPER_NO_DOT_2;check=NO_CONSTRUCTORS^#
// FUNC_SUPER_NO_DOT_2: Begin completions, 7 items
// FUNC_SUPER_NO_DOT_2: End completions
  }

  func test2() {
    super.#^FUNC_SUPER_DOT_2?check=COMMON_BASE_B_DOT;check=FUNC_SUPER_DOT_2;check=NO_CONSTRUCTORS^#
// FUNC_SUPER_DOT_2: Begin completions, 6 items
// FUNC_SUPER_DOT_2: End completions
  }

  class func test3() {
    super#^CLASS_FUNC_SUPER_NODOT?check=CLASS_FUNC_SUPER^#
  }
  class func test4() {
    super.#^CLASS_FUNC_SUPER_DOT?check=CLASS_FUNC_SUPER^#
  }
  class func test5() {
    super(#^CLASS_FUNC_SUPER_PAREN?check=CONSTRUCTOR_SUPER_NOINIT^#
  }
// CLASS_FUNC_SUPER: Decl[Constructor]/CurrNominal: {{.init|init}}()[#SuperBaseB#]
// CLASS_FUNC_SUPER: Decl[Constructor]/CurrNominal: {{.init|init}}({#a: Double#})[#SuperBaseB#]
// CLASS_FUNC_SUPER: Decl[Constructor]/CurrNominal: {{.init|init}}({#int: Int#})[#SuperBaseB#]
}

//===--- Check that we assign a special semantic context to the overridden decl.

class SemanticContextBase1 {
  init() {}
  init(a: Int) {}
  func instanceFunc1() {}
  func instanceFunc1(_ a: Int) {}
}

class SemanticContextDerived1 : SemanticContextBase1 {
  init() {}
  init(a: Int) {
    #^SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1?check=SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1;check=NO_SUPER_DECLS;check=NO_CONSTRUCTORS^#
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1: Begin completions
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1-DAG: Decl[InstanceMethod]/CurrNominal: instanceFunc1()[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1-DAG: Decl[InstanceMethod]/CurrNominal: instanceFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_1: End completions

    super.#^SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2?check=SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2;check=NO_SUPER_DECLS^#
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2: Begin completions
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2-NEXT: Decl[Constructor]/CurrNominal:    init()[#SemanticContextBase1#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2-NEXT: Decl[Constructor]/CurrNominal/Flair[SuperChain]:    init({#a: Int#})[#SemanticContextBase1#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2-NEXT: Decl[InstanceMethod]/CurrNominal: instanceFunc1()[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2-NEXT: Decl[InstanceMethod]/CurrNominal: instanceFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_2-NEXT: End completions
  }
  override func instanceFunc1() {
    #^SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3?check=SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3;check=NO_SUPER_DECLS;check=NO_CONSTRUCTORS^#
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3: Begin completions
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3-DAG: Decl[InstanceMethod]/CurrNominal: instanceFunc1()[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3-DAG: Decl[InstanceMethod]/CurrNominal: instanceFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_3: End completions

    super.#^SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4?check=SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4;check=NO_SUPER_DECLS;check=NO_CONSTRUCTORS^#
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4: Begin completions
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4-NEXT: Decl[InstanceMethod]/CurrNominal/Flair[SuperChain]: instanceFunc1()[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4-NEXT: Decl[InstanceMethod]/CurrNominal:  instanceFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_4-NEXT: End completions
  }
  override func instanceFunc1(_ a: Int) {
    super.#^SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5?check=SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5;check=NO_SUPER_DECLS;check=NO_CONSTRUCTORS^#
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5: Begin completions
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5-NEXT: Decl[InstanceMethod]/CurrNominal:  instanceFunc1()[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5-NEXT: Decl[InstanceMethod]/CurrNominal/Flair[SuperChain]: instanceFunc1({#(a): Int#})[#Void#]{{; name=.+$}}
// SEMANTIC_CONTEXT_OVERRIDDEN_DECL_5-NEXT: End completions
  }
}

class Closures : SuperBaseA {
  func foo() {
    func inner() {
      super.#^CLOSURE_1?check=COMMON_BASE_A_DOT;check=CLOSURE_1;check=NO_CONSTRUCTORS^#
      // CLOSURE_1: Begin completions, 6 items
      // CLOSURE_1: End completions
    }
  }

  func bar() {
    let inner = { () -> Int in
      // CLOSURE_2: Begin completions, 6 items
      // CLOSURE_2: End completions
      super.#^CLOSURE_2?check=COMMON_BASE_A_DOT_CONTEXT;check=CLOSURE_2;check=NO_CONSTRUCTORS^#
    }
  }

  func baz() {
    let inner = { [weak self] in
      super.#^CLOSURE_CAPTURE_1?check=CLOSURE_CAPTURE_1;check=NO_SUPER_DECLS;check=NO_CONSTRUCTORS^#
      // CLOSURE_CAPTURE_1-NOT: Begin completions
    }
  }
}

class SuperBaseC {
  init(x: Int) {}
  func foo() {}
  func bar() {}
}
class SuperDerivedC1: SuperBaseC {}
class SuperDerivedC2: SuperDerivedC1 {
  init(x: Int) {
    super.#^OVERRIDE_2HOP_INIT1^#
// OVERRIDE_2HOP_INIT1: Begin completions, 3 items
// OVERRIDE_2HOP_INIT1-DAG: Decl[Constructor]/CurrNominal/Flair[SuperChain]: init({#x: Int#})[#SuperDerivedC1#];
// OVERRIDE_2HOP_INIT1-DAG: Decl[InstanceMethod]/Super:         foo()[#Void#];
// OVERRIDE_2HOP_INIT1-DAG: Decl[InstanceMethod]/Super:         bar()[#Void#];
// OVERRIDE_2HOP_INIT1: End completions
  }
  init(y: Int) {
    super.#^OVERRIDE_2HOP_INIT2^#
// OVERRIDE_2HOP_INIT2: Begin completions, 3 items
// OVERRIDE_2HOP_INIT2-DAG: Decl[Constructor]/CurrNominal:      init({#x: Int#})[#SuperDerivedC1#];
// OVERRIDE_2HOP_INIT2-DAG: Decl[InstanceMethod]/Super:         foo()[#Void#];
// OVERRIDE_2HOP_INIT2-DAG: Decl[InstanceMethod]/Super:         bar()[#Void#];
// OVERRIDE_2HOP_INIT2: End completions
  }
  override func foo() {
    super.#^OVERRIDE_2HOP_METHOD^#
// OVERRIDE_2HOP_METHOD: Begin completions, 2 items
// OVERRIDE_2HOP_METHOD-DAG: Decl[InstanceMethod]/Super/Flair[SuperChain]: foo()[#Void#];
// OVERRIDE_2HOP_METHOD-DAG: Decl[InstanceMethod]/Super:         bar()[#Void#];
// OVERRIDE_2HOP_METHOD: End completions
  }
}

//===--- Code completion for 'super' keyword itself.

class SuperKWBase {
  func test() {
    #^BASE_SUPER_KW^#
// BASE_SUPER_KW: Begin completions
// BASE_SUPER_KW-NOT: Keyword[super]
  }
}

class SuperKWDerived : SuperKWBase {
  func test() {
    #^DERIVED_SUPER_KW^#
// DERIVED_SUPER_KW: Begin completions
// DERIVED_SUPER_KW: Keyword[super]/CurrNominal: super[#SuperKWBase#];
  }
}
