//
//  TemplateEngine.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 08/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import PathKit

protocol TemplateEngine {
  
  func generateForFiles(files: [Path], templates: [Path]) -> String
  
}