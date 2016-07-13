//
//  TemplateEngine.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 08/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import PathKit

protocol TemplateEngine {
  
  var templateExtension : String { get }
  func generateForFiles(types: [Type], imports: [Import], templates: [Path]) -> String
  
}