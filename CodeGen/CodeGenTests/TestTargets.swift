//
//  TestTargets.swift
//  CodeGen
//
//  Created by Rheese Burgess on 21/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
@testable import CodeGen

struct TestTargets {
  static let Simple = [
    [
      "struct Simple : Immutable {",
      "  let s : String",
      "  init(s: String) { self.s = s }",
      "}"
    ].joinWithSeparator("\n")
  ]
  
  static let SimpleResult = [
    CodeGenerator.Warning,
    "",
    "extension Simple {",
    "  func set(s s: String) -> Simple {",
    "    return Simple(s: s)",
    "  }",
    "}"
  ].joinWithSeparator("\n")
  
  static let Complex = [
    [
      "import AppKit",
      "import MomentumCore",
      "",
      "public class Thing: Equatable {",
      "  private let s: String",
      "  let f: Float",
      "  public let i: Int",
      "}",
      "",
      "struct OtherThing : Equatable {",
      "  let s : String",
      "}",
      "",
      "struct ThirdThing {",
      "  let i : Int",
      "}",
      "",
      "public class FourthThing: Equatable {",
      "  private let s: String",
      "  let f: Float",
      "  public let i: Int",
      "}",
      "",
      "extension FourthThing: Immutable {}"
    ].joinWithSeparator("\n"),
    [
      "import AppKit",
      "",
      "struct Thing : Immutable {}"
    ].joinWithSeparator("\n"),
    [
      "import MomentumCore",
      "",
      "extension OtherThing : Immutable {}"
    ].joinWithSeparator("\n")
  ]
  
  static let ComplexResult = [
    CodeGenerator.Warning,
    "",
    "import AppKit",
    "import MomentumCore",
    "",
    "extension FourthThing {",
    "  func set(f f: Float) -> FourthThing {",
    "    return FourthThing(s: s, f: f, i: i)",
    "  }",
    "",
    "  private func set(s s: String) -> FourthThing {",
    "    return FourthThing(s: s, f: f, i: i)",
    "  }",
    "",
    "  public func set(i i: Int) -> FourthThing {",
    "    return FourthThing(s: s, f: f, i: i)",
    "  }",
    "}",
    "",
    "extension OtherThing {",
    "  func set(s s: String) -> OtherThing {",
    "    return OtherThing(s: s)",
    "  }",
    "}",
    "",
    "extension Thing {",
    "  func set(f f: Float) -> Thing {",
    "    return Thing(s: s, f: f, i: i)",
    "  }",
    "",
    "  private func set(s s: String) -> Thing {",
    "    return Thing(s: s, f: f, i: i)",
    "  }",
    "",
    "  public func set(i i: Int) -> Thing {",
    "    return Thing(s: s, f: f, i: i)",
    "  }",
    "}"
  ].joinWithSeparator("\n")
}