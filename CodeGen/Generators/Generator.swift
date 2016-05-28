//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework
import Stencil
import PathKit

public typealias GeneratedFunction = String

public protocol Generator {
  func filter(object: Type) -> Bool
  func generateFor(filteredObjects: [Type]) -> [Name: [GeneratedFunction]]
}

class CodeGenerator {
  static let Warning = "// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY\n"

  let templates: [Template]
  let infoHeader: String

  init(templates: [Template], infoHeader: String? = CodeGenerator.Warning) {
    self.templates = templates
    self.infoHeader = infoHeader ?? ""
  }

  func generateForFiles(files: [File]) -> String {
    let extractedTypes = Extractor.extractTypes(files)
    let extractedImports = Extractor.extractImports(files)
    let sortedImports = extractedImports.sort()

    let types = [Type](extractedTypes.values).sort { $0.name < $1.name }
    let extensions = types.reduce([Extension:[Type]]()) { acc, type in
      var newAcc = acc
      type.extensions.forEach { ext in

        if let oldValue = newAcc[ext] {
          newAcc[ext] = oldValue + [type]
        } else {
          newAcc[ext] = [type]
        }
      }

      return newAcc
    }
    
    var sortedExtension = [Extension: [Type]]()
    extensions.forEach { value in
        sortedExtension[value.0] = value.1.sort { $0.name < $1.name }
    }

    let context = Context(dictionary: [
        "types": types,
        "structs": types.filter(onlyStructs),
        "extensions": sortedExtension
    ])

    let generated = templates.reduce("") { accumulated, template in
      var result = ""
      do {
        result = try template.render(context)
      } catch {
        print("Failed to render template \(error)")
      }

      return accumulated + result
    }

    var header = infoHeader + sortedImports.map { "import \($0)" }.joinWithSeparator("\n")
    if !header.isEmpty {
        header += "\n"
    }
    return header + generated.trimWithNewLines()
}

  func generateForDirectory(directory: String) -> String {
    let filePaths = Utils.fullPathForAllFilesAt(directory, withExtension: "swift", ignoreSubdirectory: GeneratedCodeDirectory)
    let files = filePaths.map { File(path: $0)! }
    return generateForFiles(files)
  }
}

private func onlyStructs(type: Type) -> Bool {
  if case .Struct(_) = type.kind {
    return true
  } else {
    return false
  }
}