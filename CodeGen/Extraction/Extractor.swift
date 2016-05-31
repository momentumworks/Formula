//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

public class Extractor {

  private static func extractExtensions(typeDict: [String: SourceKitRepresentable]) -> [Extension] {
    return typeDict.inheritedTypes?.flatMap { $0.asDictionary?.name } ?? []
  }
  
  // this only works with the output of the "index" command of SourceKit(ten)
  private static func extractImportsFromIndex(entities: SourceKitRepresentable) -> Import? {
    guard let entitiesDict = entities.asDictionary,
          let type = entitiesDict.kind,
          let name = entitiesDict.name
          where type == "source.lang.swift.import.module.swift"
      else {
        return nil
    }
    
    return name
  }
  
  
  // this only works with the output of the "index" command of SourceKit(ten)
  // this is a recrusive function
  // this won't extract accessibility info, because that's unfortunately can't be find in the output of "index"
  private static func extractEnumFromIndex(entities: SourceKitRepresentable, nesting: [Name] = []) -> [Type] {
    guard let entitiesDict = entities.asDictionary,
          let type = entitiesDict.kind,
          let name = entitiesDict.name
      else {
        return []
    }
    
    guard type == SwiftDeclarationKind.Enum.rawValue else {
      // if fails, recurisvely call this function again, one level deeper, to see if there's a valid type in there
      return entitiesDict
        .entities?
        .flatMap { extractEnumFromIndex($0, nesting: nesting + name) } ?? []
    }
    
    return [Type(accessibility: nil,
      name: (nesting + name).joinWithSeparator("."),
      extensions: [],
      kind: .Enum(entitiesDict.entities?.flatMap(extractEnumCase) ?? [])
    )]
  }
  
  // this only works with the output of the "structure" command of SourceKit(ten)
  // this is a recrusive function
  // this won't extract out the enum cases (that's done from the output of the index command), since it's not exposed by SourceKit
  private static func extractEnumFromStructure(substructure: SourceKitRepresentable, nesting: [Name]) -> [Type] {
    guard let substructuresDict = substructure.asDictionary,
          let type = substructuresDict.kind,
          let name = substructuresDict.name
      else {
        return []
    }
    
    guard type == SwiftDeclarationKind.Enum.rawValue else {
      // if fails, recurisvely call this function again, one level deeper, to see if there's a valid type in there
      return substructuresDict
        .substructures?
        .flatMap { extractEnumFromStructure($0, nesting: nesting + name) } ?? []
    }
    
    return [Type(accessibility: substructuresDict.accessibility?.description,
      name: (nesting + name).joinWithSeparator("."),
      extensions: Set(extractExtensions(substructuresDict)),
      kind: .Enum([])
    )]
  }
  
  private static func extractEnumCase(typeDict: SourceKitRepresentable) -> EnumCase? {
    
    guard let entitiesDict = typeDict.asDictionary,
          let kind = entitiesDict.kind,
          let name = entitiesDict.name
          where kind == SwiftDeclarationKind.Enumelement.rawValue
      else {
        return nil
    }
    
    let associatedTypes = entitiesDict
      .entities?
      .flatMap { $0.asDictionary?.name } ?? []
    
    return EnumCase(name: name, associatedValues: associatedTypes)
  }
  
  private static func extractFields(typeDict: [String: SourceKitRepresentable]) -> [Field] {
    guard let fields = typeDict.substructures else {
      return []
    }
    
    return fields.flatMap { field in
      guard let fieldData = field.asDictionary,
            let accessibility = fieldData.accessibility,
            let fieldName = fieldData.name,
            let fieldType = fieldData.typeName
            where fieldData.fieldIsntCalculated && fieldData.fieldIsntStatic
        else {
          return nil
      }
      
      return Field(accessibility: accessibility, name: fieldName, type: fieldType)
    }
  }

  // this only works with the output of the "structure" command of SourceKit(ten)
  private static func extractClassOrStruct(source: SourceKitRepresentable, nesting: [Name]) -> [Type] {
    guard let typeDict = source.asDictionary,
          let type = typeDict.kind,
          let unqualifiedName = typeDict.name
      else {
        return []
    }
    
    let allowedTypes = [SwiftDeclarationKind.Class.rawValue,
                        SwiftDeclarationKind.Struct.rawValue]
    guard allowedTypes.contains(type) else {
      // if fails, recurisvely call this function again, one level deeper, to see if there's a valid type in there
      return type
        .substructures?
        .flatMap { extractClassOrStruct($0, nesting: nesting + unqualifiedName) } ?? []
    }
    
    let name = (nesting + unqualifiedName).joinWithSeparator(".")
    
    var kind = Kind(rawValue: type.drop("source.lang.swift.decl."))
    kind = {
      switch kind {
      case .Struct:
        return .Struct(extractFields(typeDict))
      case .Class:
        return .Class(extractFields(typeDict))
      case .Enum:
        return .Enum([])
      }
    }() as Kind
    
    let extensions = extractExtensions(typeDict)
  
    return [Type(accessibility: typeDict.accessibility?.description, name: name, extensions: Set(extensions), kind: kind)]
  }
  
  // this only works with the output of the "structure" command of SourceKit(ten)
  private static func extractExtensionTypes(source: SourceKitRepresentable, nesting: [Name]) -> [ExtensionType] {
    guard let typeDict = source.asDictionary,
          let type = typeDict.kind,
          let unqualifiedName = typeDict.name else {
      return []
    }
    
    let allowedTypes = [SwiftDeclarationKind.ExtensionStruct.rawValue,
                        SwiftDeclarationKind.Extension.rawValue,
                        SwiftDeclarationKind.ExtensionClass.rawValue,
                        SwiftDeclarationKind.ExtensionEnum.rawValue]
    guard allowedTypes.contains(type) else {
      // if fails, recurisvely call this function again, one level deeper, to see if there's a valid type in there
      return typeDict
        .substructures?
        .flatMap { extractExtensionTypes($0, nesting: nesting + unqualifiedName) } ?? []
    }
    
    let name = (nesting + unqualifiedName).joinWithSeparator(".")
    
    return extractExtensions(typeDict)
      .map { ExtensionType(name: name, extensions: [$0]) }
  }
  
  
  static func extractImports(file: File) -> [Import] {
    return Request.Index(file: file.path!).send()
      .dependencies?
      .flatMap(extractImportsFromIndex) ?? []
  }
  
  static func extractImports(files: [File]) -> [Import] {
    return files
      .flatMap(extractImports)
      .unique
      .filter { $0 != "Swift" }
  }

  static func extractTypes(file: File) -> [Name:Type] {
    
    print("Extracting objects from \(file.path ?? "source string")")
    let structure: Structure = Structure(file: file)
    
    let indexed = Request.Index(file: file.path!).send()

    guard let substructures = structure.dictionary.substructures,
          let entities = indexed.entities else {
      return [:]
    }
    
    let extractedClassesStructs = extract(from: substructures, function: extractClassOrStruct)
    
    // the associated values that enum cases hold only appear in the output of the Index command
    let enumsFromIndex = extract(from: entities, function: extractEnumFromIndex)
    
    // but we still need the output of the structure to extract out accessiblity and other relevant information
    let enumsFromStructure = extract(from: substructures, function: extractEnumFromStructure)

    // we have to extract out extensions separately for the enums, since they appear completely inconsistently throughout the structure output (not like with classes and structs, where they're nested)
    let extensions = extract(from: substructures, function: extractExtensionTypes)

    let allTypes = enumsFromStructure.mergeWith(enumsFromIndex, mergeFn: +) + extractedClassesStructs

    return mergeTypesAndExtensions(allTypes, extensions)
  }
  
  static func extractTypes(files: [File]) -> [Name:Type] {
    return files
      .map(extractTypes)
      .reduce([Name:Type](), combine: +)
  }
  
}

private func extract<T where T: TupleConvertible>(from input: [SourceKitRepresentable],
                     function: (source: SourceKitRepresentable, nesting: [Name]) -> [T]) -> [Name: T] {
  let tuples = input
    .flatMap { function(source: $0, nesting: []) }
    .map { $0.toTuple() }

  return Dictionary(tupleArray: tuples)
}

private func mergeTypesAndExtensions(lhs: [Name: Type], _ rhs: [Name: ExtensionType]) -> [Name: Type] {
  var merged = lhs
  for (k, v) in rhs {
    if let existing = merged[k] {
      merged[k] = v + existing
    }
  }
  return merged
}