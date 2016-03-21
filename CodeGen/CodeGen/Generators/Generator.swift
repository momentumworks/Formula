//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public typealias GeneratedFunction = String

@objc public protocol Generator {
  func filter(object: Object) -> Bool
  func generateFor(filteredObjects: [Object]) -> [TypeName : [GeneratedFunction]]
}

@objc public class CodeGenerator : NSObject {
  static let GeneratedCodeDirectory = "Autogen"
  static let GeneratedCodeFile = "Autogen.swift"
  
  let generators: [Generator]

  public init(generators: [Generator]) {
    self.generators = generators
  }
  
  public func generateForDirectory(directory: String, cleanFirst: Bool) {
    let trimmedTarget = Utils.removeTrailingFileSeparator(directory)
    let outputDirectory = "\(trimmedTarget)/\(CodeGenerator.GeneratedCodeDirectory)"
    let outputFile = "\(outputDirectory)/\(CodeGenerator.GeneratedCodeFile)"
    
    if (cleanFirst) { Utils.deleteFile(outputFile) }
    
    NSLog("About to generate extensions for directory \(directory) using generators \(generators.map{ String($0.dynamicType) })")
    let (extractedImports, extractedObjects) = Extractor.parseDirectory(directory, ignoreDirectory: CodeGenerator.GeneratedCodeDirectory)
    let parsed = [Object](extractedObjects.values)
    
    let generatedFuncs = generators.reduce([TypeName : [GeneratedFunction]]()) { accumulated, generator in
      let nextGenerated: [TypeName : [GeneratedFunction]] = generator.generateFor(parsed.filter{generator.filter($0)})
      
      return accumulated.mergeWith(nextGenerated) { $0 + $1 }
    }
    
    let sortedImports = Set(extractedImports).sort()
    let sortedTypes = Set(generatedFuncs.keys).sort()
    
    let warning = "// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY\n"
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
    
    let output = "\(warning)\n\(imports)\n\n\(extensions)"
    
    Utils.createDirectoryIfNonExistent(outputDirectory)
    NSLog("Writing file \(outputFile)")
    try! output.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)

    NSLog("Finished generating extensions")
  }
}