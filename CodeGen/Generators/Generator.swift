//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

public typealias GeneratedFunction = String

@objc public protocol Generator {
  func filter(object: Object) -> Bool
  func generateFor(filteredObjects: [Object]) -> [TypeName : [GeneratedFunction]]
}

class CodeGenerator {
  static let Warning = "// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY"
  
  let generators: [Generator]

  init(generators: [Generator]) {
    self.generators = generators
  }
  
  func generateForFiles(files: [File]) -> String {
    let extractedObjects = Extractor.extractObjects(files)
    let extractedImports = Extractor.extractImports(files)
    let parsed = [Object](extractedObjects.values)
    
    let generatedFuncs = generators.reduce([TypeName : [GeneratedFunction]]()) { accumulated, generator in
      let nextGenerated: [TypeName : [GeneratedFunction]] = generator.generateFor(parsed.filter{generator.filter($0)})
      
      return accumulated.mergeWith(nextGenerated) { $0 + $1 }
    }
    
    let sortedImports = extractedImports.sort()
    let sortedTypes = Set(generatedFuncs.keys).sort()
    
    let imports = sortedImports.map { "import \($0)" }.joinWithSeparator("\n")
    let extensions = sortedTypes.map { type -> SourceString in
      let functions = generatedFuncs[type]!
      let source = functions.sort().joinWithSeparator("\n\n")
      let generated = [
        "extension \(type) {",
        source,
        "}"
        ].joinWithSeparator("\n")
      
      return generated
      }.joinWithSeparator("\n\n")
    
    return "\(CodeGenerator.Warning)\(sortedImports.count > 0 ? "\n\n\(imports)" : "")\n\n\(extensions)"
  }
  
  func generateForDirectory(directory: String) -> String {
    let filePaths = Utils.fullPathForAllSourceFilesAt(directory, ignoreSubdirectory: GeneratedCodeDirectory)
    let files = filePaths.map { File(path: $0)! }
    return generateForFiles(files)
  }
}