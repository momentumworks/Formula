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

    return fields.flatMap { field in
      guard let fieldData = field as? [String: SourceKitRepresentable],
      let accessibility = extractAccessibility(fieldData),
      let fieldName = extractName(fieldData),
      let fieldType = extractType(fieldData) else {

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
    let tuple = types.flatMap{ type -> (TypeName, Object)? in
      guard let obj = extractObject(type) else {
        return nil
      }

      return (obj.name, obj)
    }

    return Dictionary(tuple)
  }

  public static func parseFile(file: File) -> [TypeName : Object] {
    let structure: Structure = Structure(file: file)
    let dictionary = structure.dictionary
    guard let substructures = dictionary["key.substructure"] as? [SourceKitRepresentable] else {
      return [:]
    }

    return extractObjects(substructures)
  }

  public static func parseDirectory(path: String, ignoreDirectory: String) -> [TypeName : Object] {
    let files = NSFileManager.defaultManager().enumeratorAtPath(path)?.allObjects as! [NSString]
    let ignoredPrefix = "\(Utils.removeTrailingFileSeparator(ignoreDirectory))/"

    return files.filter{ $0.pathExtension == "swift" && !$0.hasPrefix(ignoredPrefix) }.reduce([TypeName : Object]()) { objs, filePath in
      let file = File(path: "\(path)/\(filePath)")!

      return objs.mergeWith(parseFile(file)){ $0.mergeWith($1) }
    }
  }
}