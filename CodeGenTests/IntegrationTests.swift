//
//  CodeGenTests.swift
//  CodeGenTests
//
//  Created by Rheese Burgess on 16/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

@testable import CodeGen
import PathKit
import Quick
import Nimble

class CodeGenTests: QuickSpec {
  
  override func spec() {
    
    describe("generator should output the correct fixtures") {

      it("when using Immutable stencil with simple source") {
        let result = self.loadInputAndGenerate(templateName: "Immutable", input: "ImmutableSimpleSource", expectedOutput: "ImmutableSimpleResult")
        expect(result).to(be(true))
      }
      
      it("when using Immutable stencil with complex source") {
        let result = self.loadInputAndGenerate(templateName: "Immutable", input: "ImmutableComplexSource", expectedOutput: "ImmutableComplexResult")
        expect(result).to(be(true))
      }
      
      it("when using AutoEquatable stencil with complex source") {
        let result = self.loadInputAndGenerate(templateName: "AutoEquatable", input: "AutoEquatableComplexSource", expectedOutput: "AutoEquatableComplexResult")
        expect(result).to(be(true))
      }
      
    }
    
  }
  
  private func loadInputAndGenerate(templateName templateName: String, input: String, expectedOutput: String) -> Bool {
    let template = Path (testBundle.pathForResource(templateName, ofType: "stencil")!)
    
    let fixture = Path( testBundle.pathForResource(input, ofType: "fixture")!)
    let expected : String = try! Path( testBundle.pathForResource(expectedOutput, ofType: "fixture")!).read()
    
    let output = StencilEngine().generateForFiles([fixture], templates: [template])
    return output == expected
  }
  
}

