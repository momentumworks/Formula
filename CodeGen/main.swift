//
//  main.swift
//  codegen-cli
//
//  Created by Krzysztof Zabłocki on 23/03/16.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework
import AppKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"

private func generateForDirectory(directory: String, usingGenerators generators: [Generator], cleanFirst: Bool) {
  let trimmedTarget = Utils.removeTrailingFileSeparator(directory)
  let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
  let outputFile = "\(outputDirectory)/\(GeneratedCodeFile)"
  
  if (cleanFirst) { Utils.deleteFile(outputFile) }
  
  NSLog("About to generate extensions for directory \(directory) using generators \(generators.map{ String($0.dynamicType) })")
  
  let generator = CodeGenerator(generators: generators)
  let generated = generator.generateForDirectory(trimmedTarget)
  
  Utils.createDirectoryIfNonExistent(outputDirectory)
  NSLog("Writing file \(outputFile)")
  try! generated.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
  
  NSLog("Finished generating extensions")
}

func main() {
  var targetArgument: String?
  var cleanFirst = false

  for (idx, argument) in Process.arguments.enumerate() {
    switch argument {
    case "-target":
      targetArgument = Process.arguments[idx + 1]
    case "-clean":
      cleanFirst = true
    default:
      break
    }
  }

  guard let target = targetArgument else {
    print("Usage: \"codegen -path <path-directory> [-clean]\"")
    return
  }

  NSLog("Running code gen with target \(target) \(cleanFirst ? "(cleaning first)" : "")")
  let generators = [ImmutableSettersGenerator()]
  generateForDirectory(target, usingGenerators: generators, cleanFirst: cleanFirst)
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
}
else {
    main()
}