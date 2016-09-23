//
//  FileExtractor.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 01/06/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit

struct FileExtractor {
  
  static func extractImports(file: Path) -> [Import] {
    return extractImports(File(path: file.description)!.lines.map { $0.content })
  }
  
  static func extractImports(lines: [String]) -> [Import] {
    // SourceKitten doesn't give us info about the import statements, and
    // altering it to support that would be way more work than this, so...
    
    return lines
      .filter { $0.trim().hasPrefix("import") }
      .map { $0.trim().split("import")[1].trim() }
  }
  
}



