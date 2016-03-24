//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework
import Stencil
import PathKit

public typealias GeneratedFunction = String

@objc public protocol Generator {
  func filter(object: Object) -> Bool
  func generateFor(filteredObjects: [Object]) -> [TypeName : [GeneratedFunction]]
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
    let extractedObjects = Extractor.extractObjects(files)
    let extractedImports = Extractor.extractImports(files)
    let sortedImports = extractedImports.sort()

    let objects = [Object](extractedObjects.values)
    let extensions = objects.reduce([Extension:[Object]]()) { acc, object in
      var newAcc = acc
      object.extensions.forEach { ext in

        if let oldValue = newAcc[ext] {
          newAcc[ext] = oldValue + [object]
        } else {
          newAcc[ext] = [object]
        }
      }

      return newAcc
    }

    let context = Context(dictionary: [
        "objects": objects,
        "extensions": extensions
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