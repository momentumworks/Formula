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
import PathKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"

let templateEngine: TemplateEngine = StencilEngine()

private func generateForDirectory(directory: String, usingTemplates templates: [Path], cleanFirst: Bool) {
  let trimmedTarget = FileUtils.removeTrailingFileSeparator(directory)
  let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
  let outputFile = "\(outputDirectory)/\(GeneratedCodeFile)"
  
  if (cleanFirst) { FileUtils.deleteFile(outputFile) }
  
  print("About to generate extensions for directory \(directory) using templates \(templates)")
  
  let filesToProcess = FileUtils.fullPathForAllFilesAt(directory, withExtension: "swift", ignoreSubdirectory: GeneratedCodeDirectory)
  
  let types = Extractor.extractTypes(filesToProcess)
  let imports = Extractor.extractImports(filesToProcess)
  
  let generated = templateEngine.generateForFiles(types, imports: imports, templates: templates)
  
  FileUtils.createDirectoryIfNonExistent(outputDirectory)
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
  let templates = FileUtils.fullPathForAllFilesAt(templatesArgument ?? FileUtils.pathFromWorkingDirectory("/Templates"), withExtension:"stencil", ignoreSubdirectory: GeneratedCodeDirectory)
  generateForDirectory(target, usingTemplates: templates, cleanFirst: cleanFirst)
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
} else {
    main()
}
