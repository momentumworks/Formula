//
//  ExtractorEngine.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 16/08/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import PathKit

protocol ExtractorEngine {
  
  var fileExtension : String { get }
  
  func extractImports(files: [Path]) -> [Import]
  func extractTypes(files: [Path]) -> [Name:Type]

}