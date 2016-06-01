//
//  CodeGenTests.swift
//  CodeGenTests
//
//  Created by Rheese Burgess on 16/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

@testable import CodeGen
import Stencil
import SourceKittenFramework
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
      
    }
    
  }
  
  private func loadInputAndGenerate(templateName templateName: String, input: String, expectedOutput: String) -> Bool {
    let template = try! Template(named: templateName + ".stencil", inBundle: self.testBundle)
    
    let fixture = File(path: testBundle.pathForResource(input, ofType: "fixture")!)!
    let expected = File(path: testBundle.pathForResource(expectedOutput, ofType: "fixture")!)!.contents
    
    let generator = CodeGenerator(templates: [template], infoHeader: nil)
    let output = generator.generateForFiles([fixture])
    return output == expected
  }
  
}

