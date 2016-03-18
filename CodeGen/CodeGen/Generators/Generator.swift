//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public typealias GeneratedFunction = String

@objc public protocol Generator {
  func filter(object: Object) -> Bool
  func generateFor(objects: [Object]) -> [TypeName : [GeneratedFunction]]
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
    
    NSLog("About to generate extensions for directory \(directory) using generators \(generators.map{ String($0.dynamicType) })")
    let parsed = Array(Extractor.parseDirectory(directory, ignoreDirectory: CodeGenerator.GeneratedCodeDirectory).values)
    
    let generatedFuncs = generators.reduce([TypeName : [GeneratedFunction]]()) { accumulated, generator in
      let nextGenerated: [TypeName : [GeneratedFunction]] = generator.generateFor(parsed)
      
      return accumulated.mergeWith(nextGenerated) { $0 + $1 }
    }
    
    let generatedExtensions = generatedFuncs.map { (type, generatedFunctions) -> SourceString in
      let source = generatedFunctions.joinWithSeparator("\n\n")
      let generated = [
        "extension \(type) {",
        source,
        "}"
      ].joinWithSeparator("\n")
      
      return generated
    }
    
    let allGeneratedLines = [
      "// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY",
      ] + generatedExtensions
    
    let generatedSource = allGeneratedLines.joinWithSeparator("\n\n")
    
    if (cleanFirst) { Utils.deleteFile(outputFile) }
    Utils.createDirectoryIfNonExistent(outputDirectory)

    NSLog("Writing file \(outputFile)")
    try! generatedSource.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)

    NSLog("Finished generating extensions")
  }
}