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
  
  private static func extractKind(typeDict: [String: SourceKitRepresentable]) -> String? {
    return typeDict["key.kind"] as? String
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
  
  private static func extractEntities(typeDict: [String: SourceKitRepresentable]) -> [SourceKitRepresentable] {
    return typeDict["key.entities"] as? [SourceKitRepresentable] ?? []
  }

  
  private static func extractEnum(entities: SourceKitRepresentable) -> [Enum] {
    guard let entitiesDict = entities as? [String: SourceKitRepresentable],
          let type = extractKind(entitiesDict),
          let name = extractName(entitiesDict)
      else {
        return []
    }
    
    guard type == SwiftDeclarationKind.Enum.rawValue else {
      return extractEntities(entitiesDict).flatMap(extractEnum)
    }
    
    return [Enum(name: name, cases: extractEntities(entitiesDict).flatMap(extractEnumCase))]
  }
  
  private static func extractEnumCase(typeDict: SourceKitRepresentable) -> EnumCase? {
    
    guard let entitiesDict = typeDict as? [String: SourceKitRepresentable],
          let kind = entitiesDict["key.kind"] as? String,
          let name = entitiesDict["key.name"] as? String
          where kind == SwiftDeclarationKind.Enumelement.rawValue
      else {
        return nil
    }
    
    let associatedValuesTypeDict = entitiesDict["key.entities"] as? [SourceKitRepresentable] ?? []
    
    return EnumCase(name: name, associatedValues: extractAssociatedTypes(associatedValuesTypeDict))
  }
  
  private static func extractAssociatedTypes(typeArray: [SourceKitRepresentable]) -> [Kind] {
    return typeArray.flatMap { associatedValueDict in
      guard let dict = associatedValueDict as? [String: SourceKitRepresentable]
        else {
          return nil
      }
      return extractKind(dict)
    }
  }
  
  private static func extractFields(typeDict: [String: SourceKitRepresentable]) -> [Field] {
    guard let fields = typeDict["key.substructure"] as? [SourceKitRepresentable] else {
      return []
    }
    
    func fieldIsntCalculated(field: [String: SourceKitRepresentable]) -> Bool {
      return field["key.bodylength"] == nil
    }
    
    func fieldIsntStatic(field: [String: SourceKitRepresentable]) -> Bool {
      // This feels dangerous...
      return field["key.kind"].flatMap{ $0 as? String } != Optional(SwiftDeclarationKind.VarStatic.rawValue)
    }

    return fields.flatMap { field in
      guard let fieldData = field as? [String: SourceKitRepresentable],
        let accessibility = extractAccessibility(fieldData),
        let fieldName = extractName(fieldData),
        let fieldType = extractType(fieldData)
        where fieldIsntCalculated(fieldData) &&
        fieldIsntStatic(fieldData) else {
          return nil
        }
      
      return Field(accessibility: accessibility, name: fieldName, type: fieldType)
    }
  }

  private static func extractType(typeDict: [String : SourceKitRepresentable], nesting: [Name]) -> Type? {
    guard let type = typeDict["key.kind"] as? String,
        let unqualifiedName = extractName(typeDict) else {
      return nil
    }
    
    let allowedTypes = [SwiftDeclarationKind.Class.rawValue,
                        SwiftDeclarationKind.ExtensionClass.rawValue,
                        SwiftDeclarationKind.Struct.rawValue,
                        SwiftDeclarationKind.ExtensionStruct.rawValue,
                        SwiftDeclarationKind.Extension.rawValue,
                        SwiftDeclarationKind.ExtensionEnum.rawValue]
    if !allowedTypes.contains(type) {
        return nil
    }
    
    let name = (nesting + unqualifiedName).joinWithSeparator(".")

    let accessibility = extractAccessibility(typeDict)
    let fields = extractFields(typeDict)
    let extensions = extractExtensions(typeDict)

    return Type(accessibility: accessibility?.description, name: name, fields: fields, extensions: extensions, kind: type.stringByReplacingOccurrencesOfString("source.lang.swift.decl.", withString: ""))
  }
  
  
  private static func extractNestedTypes(typeDict: [String : SourceKitRepresentable], nesting: [Name]) -> [(Name, Type)] {
    guard let nestedTypes = typeDict["key.substructure"] as? [SourceKitRepresentable] else {
      return []
    }
    
    return extractTypesAsTuples(nestedTypes, nesting: nesting)
  }
  
  private static func extractTypesAsTuples(types: [SourceKitRepresentable], nesting: [Name]) -> [(Name, Type)] {
    return types.flatMap{ type -> [(Name, Type)] in
      guard let typeDict = type as? [String : SourceKitRepresentable],
        let obj = extractType(typeDict, nesting: nesting) else {
        return []
      }
      
      let nestedObjects = extractNestedTypes(typeDict, nesting: nesting + obj.name)
      return nestedObjects + (obj.name, obj)
    }
  }

  private static func extractTypes(types: [SourceKitRepresentable], nesting: [Name]) -> [Name:Type] {
    let tuples = extractTypesAsTuples(types, nesting: nesting)
    return Dictionary(tuples){ $0.mergeWith($1) }
  }
  
  static func extractImports(lines: [String]) -> [Import] {
    // SourceKitten doesn't give us info about the import statements, and
    // altering it to support that would be way more work than this, so...
    
    // TODO: this can be done using the Indexing feature of SourceKit/SourceKitten
    
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

  static func extractTypes(file: File) -> [Name:Type] {
    
    print("Extracting objects from \(file.path ?? "source string")")
    let structure: Structure = Structure(file: file)
    let dictionary = structure.dictionary
    
    let indexed = Request.Index(file: file.path!).send()
    
    guard let substructures = dictionary["key.substructure"] as? [SourceKitRepresentable]
      else { return [:] }
    
    let enums = extractEntities(indexed).flatMap(extractEnum)

    return extractTypes(substructures, nesting: [])
  }
  
  static func extractTypes(files: [File]) -> [Name:Type] {
    return files
      .map(extractTypes)
      .reduce([Name:Type](), combine: +)
  }
}