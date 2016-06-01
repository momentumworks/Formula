//
//  StructureExtractor.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 01/06/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct StructureExtractor {
  
  // this only works with the output of the "structure" command of SourceKit(ten)
  static func extractExtensionTypes(source: SourceKitRepresentable, nesting: [Name]) -> [ExtensionType] {
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
    
    return typeDict
      .extensions?
      .map { ExtensionType(name: name, extensions: [$0]) } ?? []
  }
  
  // this only works with the output of the "structure" command of SourceKit(ten)
  static func extractClassOrStruct(source: SourceKitRepresentable, nesting: [Name]) -> [Type] {
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
    
    let nestedTypes = typeDict
      .substructures?
      .flatMap { extractClassOrStruct($0, nesting: nesting + unqualifiedName) } ?? []
    
    return nestedTypes + Type(accessibility: typeDict.accessibility?.description,
      name: name,
      extensions: Set(typeDict.extensions ?? []),
      kind: kind)
  }
  
  
  // this only works with the output of the "structure" command of SourceKit(ten)
  // this is a recrusive function
  // this won't extract out the enum cases (that's done from the output of the index command), since it's not exposed by SourceKit
  static func extractEnum(substructure: SourceKitRepresentable, nesting: [Name]) -> [Type] {
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
        .flatMap { extractEnum($0, nesting: nesting + name) } ?? []
    }
    
    return [Type(accessibility: substructuresDict.accessibility?.description,
      name: (nesting + name).joinWithSeparator("."),
      extensions: Set(substructuresDict.extensions ?? []),
      kind: .Enum([])
      )]
  }

}


private func extractFields(typeDict: [String: SourceKitRepresentable]) -> [Field] {
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
