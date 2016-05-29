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

class CodeGenTests: XCTestCase {
  var testBundle: NSBundle!
  var template: Template!

  override func setUp() {
    super.setUp()
    testBundle = NSBundle(forClass: self.dynamicType)
    template = try! Template(named: "Immutable.stencil", inBundle: testBundle)
  }

  override func tearDown() {
    super.tearDown()
  }

  
  func testSimpleGeneration() {
    let fixture = File(path: testBundle.pathForResource("SimpleSource", ofType: "fixture")!)!
    let expected = File(path: testBundle.pathForResource("SimpleResult", ofType: "fixture")!)!.contents

    let generator = CodeGenerator(templates: [template], infoHeader: nil)
    let output = generator.generateForFiles([fixture])

    XCTAssertEqual(output, expected, "Generated code wasn't as expected")
  }

  func testComplexGeneration() {
    let fixture = File(path: testBundle.pathForResource("ComplexSource", ofType: "fixture")!)!
    let expected = File(path: testBundle.pathForResource("ComplexResult", ofType: "fixture")!)!.contents

    let generator = CodeGenerator(templates: [template], infoHeader: nil)
    let output = generator.generateForFiles([fixture])

    XCTAssertEqual(output, expected, "Generated code wasn't as expected")
  }
}
