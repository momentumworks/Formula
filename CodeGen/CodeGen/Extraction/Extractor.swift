//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

public class Extractor {
  private static func extractAccessibility(typeDict: [String: SourceKitRepresentable]) -> Accessibility? {
    guard let accessibilityStr = typeDict["key.accessibility"] as? String else {
      return nil
    }

    return Accessibility(rawValue: accessibilityStr)
  }

  private static func extractName(typeDict: [String: SourceKitRepresentable]) -> String? {
    return typeDict["key.name"] as? String
  }

  private static func extractType(typeDict: [String: SourceKitRepresentable]) -> String? {
    return typeDict["key.typename"] as? String
  }

  private static func extractExtensions(typeDict: [String: SourceKitRepresentable]) -> [Extension] {
    guard let inheritedTypes = typeDict["key.inheritedtypes"] as? [SourceKitRepresentable] else {
      return []
    }

    return inheritedTypes.flatMap { inheritedType in
      guard let inheritedTypeDict = inheritedType as? [String : SourceKitRepresentable] else {
        return nil
      }

      return extractName(inheritedTypeDict)
    }
  }
  
  private static func extractFields(typeDict: [String: SourceKitRepresentable]) -> [Field] {
    guard let fields = typeDict["key.substructure"] as? [SourceKitRepresentable] else {
      return []
    }
    
    func fieldIsntCalculated(field: [String: SourceKitRepresentable]) -> Bool {
      return field["key.bodylength"] == nil
    }

    return fields.flatMap { field in
      guard let fieldData = field as? [String: SourceKitRepresentable],
        let accessibility = extractAccessibility(fieldData),
        let fieldName = extractName(fieldData),
        let fieldType = extractType(fieldData)
        where fieldIsntCalculated(fieldData) else {
          return nil
        }
      
      return Field(accessibility: accessibility, name: fieldName, type: fieldType)
    }
  }

  private static func extractObject(type: SourceKitRepresentable) -> Object? {
    guard let typeDict = type as? [String : SourceKitRepresentable],
    let name = extractName(typeDict) else {

      return nil
    }

    let accessibility = extractAccessibility(typeDict)
    let fields = extractFields(typeDict)
    let extensions = extractExtensions(typeDict)

    return Object(accessibility: accessibility, name: name, fields: fields, extensions: extensions)
  }

  private static func extractObjects(types: [SourceKitRepresentable]) -> [TypeName : Object] {
    let tuples = types.flatMap{ type -> (TypeName, Object)? in
      guard let obj = extractObject(type) else {
        return nil
      }

      return (obj.name, obj)
    }

    return Dictionary(tuples){ $0.mergeWith($1) }
  }
  
  static func extractImports(lines: [String]) -> [Import] {
    // SourceKitten doesn't give us info about the import statements, and
    // altering it to support that would be way more work than this, so...
    
    return lines.filter {
        $0.trim().hasPrefix("import")
      }
      .map {
        $0.trim().split("import")[1].trim()
      }
  }
  
  static func extractImports(file: File) -> [Import] {
    return extractImports(file.lines.map{ $0.content })
  }
  
  static func extractImports(files: [File]) -> [Import] {
    let allImports = files.reduce([Import]()) { imports, file in
      return imports + extractImports(file)
    }
    return [Import](Set(allImports))
  }

  static func extractObjects(file: File) -> [TypeName : Object] {
    NSLog("Extracting objects from \(file.path ?? "")")
    let structure: Structure = Structure(file: file)
    let dictionary = structure.dictionary
    guard let substructures = dictionary["key.substructure"] as? [SourceKitRepresentable] else {
      return [:]
    }

    return extractObjects(substructures)
  }
  
  static func extractObjects(files: [File]) -> [TypeName : Object] {
    return files.reduce([TypeName : Object]()) { objects, file in
      return objects.mergeWith(extractObjects(file)){ $0.mergeWith($1) }
    }
  }
}