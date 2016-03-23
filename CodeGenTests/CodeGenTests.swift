//
//  CodeGenTests.swift
//  CodeGenTests
//
//  Created by Rheese Burgess on 16/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import XCTest
@testable import CodeGen

class CodeGenTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testSimpleGeneration() {
    let input = Utils.filesFromSources(TestTargets.Simple)
    let generator = CodeGenerator(generators: [ImmutableSettersGenerator()])
    let output = generator.generateForFiles(input)
    
    XCTAssertEqual(output, TestTargets.SimpleResult, "Generated code wasn't as expected")
  }

  func testComplexGeneration() {
    let input = Utils.filesFromSources(TestTargets.Complex)
    let generator = CodeGenerator(generators: [ImmutableSettersGenerator()])
    let output = generator.generateForFiles(input)
    
    XCTAssertEqual(output, TestTargets.ComplexResult, "Generated code wasn't as expected")
  }
}
