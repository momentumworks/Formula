//
//  ExtractorTests.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 31/05/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import XCTest
@testable import CodeGen
import Stencil
import SourceKittenFramework

import Quick
import Nimble

class ExtractorTests: QuickSpec {

  override func spec() {
    describe("when extracting simple enums") {
      
      let file = File(path: self.testBundle.pathForResource("SimpleEnum", ofType: "fixture")!)!
      let metaData = Extractor.extractTypes([file])
      
      it("should recognize its name & type") {
        expect(metaData["Anenum"]).toNot(beNil())
        expect(metaData["Anenum"]?.kind.isEnum).to(equal(true))
      }
      
      it("should recognize its cases") {
        let enumCases = [
          EnumCase(name: "One", associatedValues: []),
          EnumCase(name: "Two", associatedValues: []),
          EnumCase(name: "Three", associatedValues: [])
        ]
        expect(metaData["Anenum"]?.kind).to(equal(Kind.Enum(enumCases)))
      }
      
      it("should recognize its extensions") {
        let extensions: Set<Extension> = [
          "Protocol1",
          "Protocol2"
        ]
        expect(metaData["Anenum"]?.extensions).to(equal(extensions))
      }

    }
    
    describe("when extracting complex enums") {
      
      let file = File(path: self.testBundle.pathForResource("ComplexEnum", ofType: "fixture")!)!
      let metaData = Extractor.extractTypes([file])
      
      it("should recognize its name & type") {
        expect(metaData["AComplexEnum"]).toNot(beNil())
        expect(metaData["AComplexEnum"]?.kind.isEnum).to(equal(true))
      }
      
      it("should recognize its cases") {
        let enumCases = [
          EnumCase(name: "One", associatedValues: ["Int"]),
          EnumCase(name: "Two", associatedValues: ["Int", "Int"]),
          EnumCase(name: "Three", associatedValues: ["String", "Int", "String"]),
          EnumCase(name: "Four", associatedValues: [])
        ]
        expect(metaData["AComplexEnum"]?.kind).to(equal(Kind.Enum(enumCases)))
      }
      
      it("should recognize its extensions") {
        let extensions: Set<Extension> = [
          "Protocol1",
          "Protocol2",
          "Protocol3"
        ]
        expect(metaData["AComplexEnum"]?.extensions).to(equal(extensions))
      }
      
    }

  
  }
  
}
