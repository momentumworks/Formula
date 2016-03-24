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
import Stencil
import PathKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"

private func generateForDirectory(directory: String, usingTemplates templates: [Template], cleanFirst: Bool) {
  let trimmedTarget = Utils.removeTrailingFileSeparator(directory)
  let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
  let outputFile = "\(outputDirectory)/\(GeneratedCodeFile)"
  
  if (cleanFirst) { Utils.deleteFile(outputFile) }
  
  print("About to generate extensions for directory \(directory) using templates \(templates)")
  
  let generator = CodeGenerator(templates: templates)
  let generated = generator.generateForDirectory(trimmedTarget)
  
  Utils.createDirectoryIfNonExistent(outputDirectory)
  print("Writing file \(outputFile)")
  try! generated.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
  
  print("Finished generating extensions")
}

func main() {
  var targetArgument: String?
  var templatesArgument: String?
  var cleanFirst = false

  for (idx, argument) in Process.arguments.enumerate() {
    switch argument {
    case "-target":
      targetArgument = Process.arguments[idx + 1]
    case "-templates":
        templatesArgument = Process.arguments[idx + 1]
    case "-clean":
      cleanFirst = true
    default:
      break
    }
  }

  guard let target = targetArgument else {
    print("Usage: \"codegen -target <path-directory> [-clean] [-templates <template-directory>]\"")
    return
  }

  print("Running code gen with target \(target) \(cleanFirst ? "(cleaning first)" : "")")
  let templates = Utils.fullPathForAllFilesAt(templatesArgument ?? Utils.pathFromWorkingDirectory("/Templates"), withExtension:"stencil", ignoreSubdirectory: GeneratedCodeDirectory).map { templatePath in
    return try! Template(path: Path(templatePath))
  }
  generateForDirectory(target, usingTemplates: templates, cleanFirst: cleanFirst)
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
}
else {
    main()
}