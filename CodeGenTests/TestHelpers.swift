//
//  TestHelpers.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 12/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//


@testable import CodeGen
import PathKit
import Quick
import Nimble
import Foundation

internal func loadInputAndGenerate(templateName templateName: String, input: String, expectedOutput: String, engine: TemplateEngine) -> (generated: String, expected: String) {
  
  let types = Array(Extractor.extractTypes( [Path(input)] ).values)
  let imports = Extractor.extractImports( [Path(input)] )
  
  let expected : String = try! Path( expectedOutput).read()
  
  let output = engine.generateForFiles(types, imports: imports, templates: [Path(templateName)])
  return (generated: output ,expected: expected)
}

internal extension String {
  
  internal func removeAllFormatting() -> String {
    return stringByReplacingOccurrencesOfString("\n", withString: "")
      .stringByReplacingOccurrencesOfString(" ", withString: "")
      .stringByReplacingOccurrencesOfString("\t", withString: "")
  }
  
}