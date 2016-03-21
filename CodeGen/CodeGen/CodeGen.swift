//
//  CodeGen.swift
//  CodeGen
//
//  Created by Rheese Burgess on 21/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation

@objc public class CodeGen : NSObject {
  static let GeneratedCodeDirectory = "Autogen"
  static let GeneratedCodeFile = "Autogen.swift"
  
  public func generateForDirectory(directory: String, usingGenerators generators: [Generator], cleanFirst: Bool) {
    let trimmedTarget = Utils.removeTrailingFileSeparator(directory)
    let outputDirectory = "\(trimmedTarget)/\(CodeGen.GeneratedCodeDirectory)"
    let outputFile = "\(outputDirectory)/\(CodeGen.GeneratedCodeFile)"
    
    if (cleanFirst) { Utils.deleteFile(outputFile) }
    
    NSLog("About to generate extensions for directory \(directory) using generators \(generators.map{ String($0.dynamicType) })")
    
    let generator = CodeGenerator(generators: generators)
    let generated = generator.generateForDirectory(trimmedTarget)
    
    Utils.createDirectoryIfNonExistent(outputDirectory)
    NSLog("Writing file \(outputFile)")
    try! generated.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
    
    NSLog("Finished generating extensions")
  }
}