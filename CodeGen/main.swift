import Foundation
import SourceKittenFramework
import AppKit
import PathKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"


private func generate(extractorEngines extractorEngines: [ExtractorEngine], templateEngines: [TemplateEngine], sourceDirectory: String, usingTemplates templates: [Path], cleanFirst: Bool) {
  print("About to generate extensions for directory \(sourceDirectory) using templates \(templates)")
  
  let files = FileUtils.fullPathForAllFilesAt(sourceDirectory, withExtension: "swift", ignoreSubdirectory: GeneratedCodeDirectory)
  let filesByExtension  = files
    .filter { $0.fileExtension != nil }
    .arrayGroupBy { [$0.fileExtension!] }

  let types = filesByExtension.reduce([Type]()) { working, entry in
    let (ext, paths) = entry
    let engine = extractorEngines.find({ $0.fileExtension == ext })
    if let engine = engine {
      return working + engine.extractTypes(paths)
    }
    return working
  }

  let imports = filesByExtension.reduce([Import]()) { working, entry in
    let (ext, paths) = entry
    let engine = extractorEngines.find({ $0.fileExtension == ext })
    if let engine = engine {
      return working + engine.extractImports(paths)
    }
    return working
  }
  
  let templatesByExtension : [String: [Path]] = templates
    .filter { $0.fileExtension != nil }
    .arrayGroupBy { [$0.fileExtension!] }
  
  let generated = templatesByExtension.reduce("") { working, entry in
    let (ext, paths) = entry
    if let engine = templateEngines.find({ $0.templateExtension == ext }) {
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


private func parseArgs() -> Configuration? {
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
  
  return targetArgument.map {
    Configuration(
      sourceDirectory: $0,
      templates: templatesArgument ?? FileUtils.pathFromWorkingDirectory("/Templates"),
      cleanFirst: cleanFirst
    )
  }
}



func main() {
  let extractorEngines:  [ExtractorEngine] = [SourceKittenExtractor()]
  let templateEngines : [TemplateEngine] = [JavascriptEngine(), StencilEngine()]

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
  generate(extractorEngines: extractorEngines, templateEngines: templateEngines, sourceDirectory: config.sourceDirectory, usingTemplates: templates, cleanFirst: config.cleanFirst)
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
} else {
    main()
}



