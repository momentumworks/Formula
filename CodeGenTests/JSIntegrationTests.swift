//
//  JSIntegrationTests.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 12/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//


@testable import CodeGen
import PathKit
import Quick
import Nimble

class JSIntegrationTests: QuickSpec {
  
  override func spec() {
    
    describe("generator should output the correct fixtures") {
      
      it("when using Immutable stencil with simple source") {
        let result = loadInputAndGenerate(
          templateName: self.testBundle.pathForFileName("ImmutableTemplate.js")!,
          input: self.testBundle.pathForFileName("ImmutableSimpleSource.fixture")!,
          expectedOutput: self.testBundle.pathForFileName("Temp.fixture")!,
          engine: JavascriptEngine()
        )
        expect(result.generated).to(be("1"))
      }
      
//      it("when using Immutable stencil with complex source") {
//        let result = loadInputAndGenerate(
//          templateName: self.testBundle.pathForFileName("Immutable.stencil")!,
//          input: self.testBundle.pathForFileName("ImmutableComplexSource.fixture")!,
//          expectedOutput: self.testBundle.pathForFileName("ImmutableComplexResult.fixture")!,
//          engine: StencilEngine()
//        )
//        expect(result).to(be(true))
//      }
//      
//      it("when using AutoEquatable stencil with complex source") {
//        let result = loadInputAndGenerate(
//          templateName: self.testBundle.pathForFileName("AutoEquatable.stencil")!,
//          input: self.testBundle.pathForFileName("AutoEquatableComplexSource.fixture")!,
//          expectedOutput: self.testBundle.pathForFileName("AutoEquatableComplexResult.fixture")!,
//          engine: StencilEngine()
//        )
//        expect(result).to(be(true))
//      }
//      
      

    }
    
  }
  

  
}

