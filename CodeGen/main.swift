import Foundation
import SourceKittenFramework
import AppKit
import PathKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"


private func generate(engines engines: [TemplateEngine], sourceDirectory: String, usingTemplates templates: [Path], cleanFirst: Bool) {
  print("About to generate extensions for directory \(sourceDirectory) using templates \(templates)")
  
  let filesToProcess = FileUtils.fullPathForAllFilesAt(sourceDirectory, withExtension: "swift", ignoreSubdirectory: GeneratedCodeDirectory)
  let types = Array(Extractor.extractTypes(filesToProcess).values)
  let imports = Extractor.extractImports(filesToProcess)

  let templatesByExtension = FileUtils.groupByExtension(templates)

  let generated = templatesByExtension.reduce("") { working, entry in
    let (ext, paths) = entry
    let engine:TemplateEngine? = engines.find{ $0.templateExtension == ext }
    if let engine = engine {
      return working + engine.generateForFiles(types, imports: imports, templates: paths)
    }
    return working
  }

  let trimmedTarget = FileUtils.removeTrailingFileSeparator(sourceDirectory)
  let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
  let outputFile = "\(outputDirectory)/\(GeneratedCodeFile)"
  if (cleanFirst) {
    FileUtils.deleteFile(outputFile)
  }
  print("Writing file \(outputDirectory)/\(GeneratedCodeFile)")
  FileUtils.mkdirAndWriteFile(fileName: GeneratedCodeFile, inDirectory: outputDirectory, content: generated)

  print("Finished generating extensions")
}

struct Configuration {
  let sourceDirectory: String
  let templates: String
  let cleanFirst: Bool
}

func parseArgs() -> Configuration? {
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

  return targetArgument == nil
    ? nil
    : Configuration(
        sourceDirectory: targetArgument!,
        templates: templatesArgument ?? FileUtils.pathFromWorkingDirectory("/Templates"),
        cleanFirst: cleanFirst
      )
}

func main() {
  let engines: [TemplateEngine] = [JavascriptEngine(), StencilEngine()]

  guard let config = parseArgs() else {
    print("Usage: \"codegen -target <path-directory> [-clean] [-templates <template-directory>]\"")
    return
  }

  print("Running code gen with target \(config.sourceDirectory) \(config.cleanFirst ? "(cleaning first)" : "")")

  let templates = FileUtils.fullPathForAllFilesAt(
    config.templates,
    withExtension: nil,
    ignoreSubdirectory: GeneratedCodeDirectory
  )
  generate(engines: engines, sourceDirectory: config.sourceDirectory, usingTemplates: templates, cleanFirst: config.cleanFirst)
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
} else {
    main()
}
