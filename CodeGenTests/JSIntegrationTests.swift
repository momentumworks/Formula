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
      
      it("when using ImmutableTemplate.js with simple source") {
        let result = loadInputAndGenerate(
          templateName: self.testBundle.pathForFileName("ImmutableTemplate.js")!,
          input: self.testBundle.pathForFileName("ImmutableSimpleSource.fixture")!,
          expectedOutput: self.testBundle.pathForFileName("ImmutableSimpleResult.fixture")!,
          engine: JavascriptEngine()
        )
        expect(result.generated.removeAllFormatting()).to(equal(result.expected.removeAllFormatting()))
      }
      
      it("when using ImmutableTemplate.js with complex source") {
        let result = loadInputAndGenerate(
          templateName: self.testBundle.pathForFileName("ImmutableTemplate.js")!,
          input: self.testBundle.pathForFileName("ImmutableComplexSource.fixture")!,
          expectedOutput: self.testBundle.pathForFileName("ImmutableComplexResult.fixture")!,
          engine: JavascriptEngine()
        )
        expect(result.generated.removeAllFormatting()).to(equal(result.expected.removeAllFormatting()))
      }

      it("when using AutoEquatableTemplate.js with complex source") {
        let result = loadInputAndGenerate(
          templateName: self.testBundle.pathForFileName("AutoEquatableTemplate.js")!,
          input: self.testBundle.pathForFileName("AutoEquatableComplexSource.fixture")!,
          expectedOutput: self.testBundle.pathForFileName("AutoEquatableComplexResult.fixture")!,
          engine: JavascriptEngine()
        )
        expect(result.generated.removeAllFormatting()).to(equal(result.expected.removeAllFormatting()))
      }
      
      it("when using JSONCodecTemplate with a string backed enum source") {
        let result = loadInputAndGenerate(
          templateName: self.testBundle.pathForFileName("JSONCodecTemplate.js")!,
          input: self.testBundle.pathForFileName("JSONCodecSimpleEnumSource.fixture")!,
          expectedOutput: self.testBundle.pathForFileName("JSONCodecSimpleEnumResult.fixture")!,
          engine: JavascriptEngine()
        )
        expect(result.generated.removeAllFormatting()).to(equal(result.expected.removeAllFormatting()))
      }


      

    }
    
  }
  

  
}

