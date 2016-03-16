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
  let GeneratedCodeDirectory = "Autogen"
  let WarningComment = "// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY"
  let generators: [Generator]

  public init(generators: [Generator]) {
    self.generators = generators
  }
  
  public func generateForDirectory(directory: String) {
    NSLog("About to generate extensions for directory \(directory) using generators \(generators.map{ String($0.dynamicType) })")
    let parsed = Array(Extractor.parseDirectory(directory, ignoreDirectory: GeneratedCodeDirectory).values)
    
    let generatedFuncs = generators.reduce([TypeName : [GeneratedFunction]]()) { accumulated, generator in
      let nextGenerated: [TypeName : [GeneratedFunction]] = generator.generateFor(parsed)
      
      return accumulated.mergeWith(nextGenerated) { $0 + $1 }
    }
    
    let generatedExtensions = generatedFuncs.map { (type, generatedFunctions) -> (TypeName, SourceString) in
      let source = generatedFunctions.joinWithSeparator("\n  ")
      let generated = "\(WarningComment)\n\nextension \(type) {\n\(source)\n}\n"
      return (type, generated)
    }

    let trimmedTarget = Utils.removeTrailingFileSeparator(directory)
    let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
    Utils.deleteDirectory(outputDirectory)
    Utils.createDirectoryIfNonExistent(outputDirectory)

    for (type, source) in generatedExtensions {
      let fileName = "\(outputDirectory)/\(type).swift"
      NSLog("Writing file \(fileName)")
      try! source.writeToFile(fileName, atomically: true, encoding: NSUTF8StringEncoding)
    }

    NSLog("Finished generating extensions")
  }
}