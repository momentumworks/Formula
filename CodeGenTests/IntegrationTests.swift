//
//  CodeGenTests.swift
//  CodeGenTests
//
//  Created by Rheese Burgess on 16/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import XCTest
@testable import CodeGen
import Stencil
import SourceKittenFramework
import Quick
import Nimble

class CodeGenTests: XCTestCase {
  var template: Template!

  override func setUp() {
    super.setUp()
    template = try! Template(named: "Immutable.stencil", inBundle: self.testBundle)
  }

  override func tearDown() {
    super.tearDown()
  }

  
  func testSimpleGeneration() {
    let fixture = File(path: testBundle.pathForResource("ImmutableSimpleSource", ofType: "fixture")!)!
    let expected = File(path: testBundle.pathForResource("ImmutableSimpleResult", ofType: "fixture")!)!.contents

    let generator = CodeGenerator(templates: [template], infoHeader: nil)
    let output = generator.generateForFiles([fixture])

    XCTAssertEqual(output, expected, "Generated code wasn't as expected")
  }

  func testComplexGeneration() {
    let fixture = File(path: testBundle.pathForResource("ImmutableComplexSource", ofType: "fixture")!)!
    let expected = File(path: testBundle.pathForResource("ImmutableComplexResult", ofType: "fixture")!)!.contents

    let generator = CodeGenerator(templates: [template], infoHeader: nil)
    let output = generator.generateForFiles([fixture])

    XCTAssertEqual(output, expected, "Generated code wasn't as expected")
  }
}
