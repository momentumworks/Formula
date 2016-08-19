import Foundation
import SourceKittenFramework
import AppKit
import PathKit

let GeneratedCodeDirectory = "Autogen"
let GeneratedCodeFile = "Autogen.swift"


private func generateFirstPass(fromDirectory sourceDirectory: String, extractorEngines: [ExtractorEngine], templateEngines: [TemplateEngine], usingTemplates templates: [Path], cleanFirst: Bool) -> Path {
  print("About to generate extensions for directory \(sourceDirectory) using templates \(templates)")
  
  let files = FileUtils.fullPathForAllFilesAt(sourceDirectory, withExtension: "swift", ignoreSubdirectory: GeneratedCodeDirectory)
  let generated = generateCode(fromSource: files, extractorEngines: extractorEngines, templateEngines: templateEngines, usingTemplates: templates)
  
  let trimmedTarget = FileUtils.removeTrailingFileSeparator(sourceDirectory)
  let outputDirectory = "\(trimmedTarget)/\(GeneratedCodeDirectory)"
  let outputFile = "\(outputDirectory)/\(GeneratedCodeFile)"
  if (cleanFirst) {
    FileUtils.deleteFile(outputFile)
  }
  print("Writing file \(outputDirectory)/\(GeneratedCodeFile)")
  FileUtils.mkdirAndWriteFile(fileName: GeneratedCodeFile, inDirectory: outputDirectory, content: generated)

  print("Finished generating extensions")
  return Path(outputFile)
}


private func generateSecondaryPass(fromSource source: Path, extractorEngines: [ExtractorEngine], templateEngines: [TemplateEngine], usingTemplates templates: [Path]) {
  
  let originalContent: String = try! source.read()
  let generated = generateCode(fromSource: [source], extractorEngines: extractorEngines, templateEngines: templateEngines, usingTemplates: templates)

  try! source.delete()
  try! source.write(originalContent + generated)
}



private func generateCode(fromSource source: [Path], extractorEngines: [ExtractorEngine], templateEngines: [TemplateEngine], usingTemplates templates: [Path]) -> String {
  let filesByExtension  = source
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
  
  return templatesByExtension.reduce("") { working, entry in
    let (ext, paths) = entry
    if let engine = templateEngines.find({ $0.templateExtension == ext }) {
      return working + engine.generateForFiles(types, imports: imports, templates: paths)
    }
    return working
  }

}


struct Configuration {
  let sourceDirectory: String
  let templates: String
  let cleanFirst: Bool
  let passes: Int
}


private func parseArgs() -> Configuration? {
  var targetArgument: String?
  var templatesArgument: String?
  var cleanFirst = false
  var passes = 1
  
  for (idx, argument) in Process.arguments.enumerate() {
    switch argument {
    case "-target":
      targetArgument = Process.arguments[idx + 1]
    case "-templates":
      templatesArgument = Process.arguments[idx + 1]
    case "-clean":
      cleanFirst = true
    case "-passes":
      passes = Int(Process.arguments[idx + 1])!
    default:
      break
    }
  }
  
  return targetArgument.map {
    Configuration(
      sourceDirectory: $0,
      templates: templatesArgument ?? FileUtils.pathFromWorkingDirectory("/Templates"),
      cleanFirst: cleanFirst,
      passes: passes
    )
  }
}



func main() {
  let extractorEngines:  [ExtractorEngine] = [SourceKittenExtractor()]
  let templateEngines : [TemplateEngine] = [JavascriptEngine(), StencilEngine()]

  guard let config = parseArgs() else {
    print("Usage: \"codegen -target <path-directory> [-clean] [-templates <template-directory>] [-passes <number-of-passes>]\"")
    return
  }

  print("Running code gen with target \(config.sourceDirectory) \(config.cleanFirst ? "(cleaning first)" : "")")

  
  let templates = FileUtils.fullPathForAllFilesAt(
    config.templates,
    withExtension: nil,
    ignoreSubdirectory: GeneratedCodeDirectory
  )
  let generatedFilePath = generateFirstPass(fromDirectory: config.sourceDirectory, extractorEngines: extractorEngines, templateEngines: templateEngines, usingTemplates: templates, cleanFirst: config.cleanFirst)
  
  if config.passes > 1 {
    for _ in 1...config.passes {
      generateSecondaryPass(fromSource: generatedFilePath, extractorEngines: extractorEngines, templateEngines: templateEngines, usingTemplates: templates)
    }
  }
  
}

let inTests = NSClassFromString("XCTest") != nil

if inTests {
    NSApplicationMain( 0,  UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(nil) )
} else {
    main()
}



