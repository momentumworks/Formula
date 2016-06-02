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
  
  struct ExtensionsExtractor: ElementExtractor {
    
    var supportedKinds: Set<String> = [SwiftDeclarationKind.ExtensionStruct.rawValue,
                                       SwiftDeclarationKind.Extension.rawValue,
                                       SwiftDeclarationKind.ExtensionClass.rawValue,
                                       SwiftDeclarationKind.ExtensionEnum.rawValue]
    
    func extract(input: [String : SourceKitRepresentable], nesting: [Name]) -> [PossibleType] {
      guard let name = input.name else { fatalError() }
      let fullName = (nesting + name).joinWithSeparator(".")
      
      return input
        .extensions?
        .map { .PartialExtension( ExtensionType(name: fullName, extensions: [$0]) ) } ?? []
    }
  }
  
  
  struct ClassAndStructExtractor: ElementExtractor {
    
    var supportedKinds: Set<String> = [SwiftDeclarationKind.Class.rawValue,
                                       SwiftDeclarationKind.Struct.rawValue]
    
    func extract(input: [String : SourceKitRepresentable], nesting: [Name]) -> [PossibleType] {
      guard let name = input.name,
            let type = input.kind
        else {
          fatalError()
      }
      
      let fullName = (nesting + name).joinWithSeparator(".")

      let kind = {
        let initial = Kind(rawValue: type.drop("source.lang.swift.decl."))
        switch initial {
        case .Struct:
          return .Struct(extractFields(input))
        case .Class:
          return .Class(extractFields(input))
        case .Enum:
          return .Enum([])
        }
      }() as Kind
      
      return [.Complete(Type(accessibility: input.accessibility?.description,
        name: fullName,
        extensions: Set(input.extensions ?? []),
        kind: kind)
        )
      ]
    }
  }
  
  // this won't extract out the enum cases (that's done from the output of the index command), since it's not exposed by SourceKit

  struct EnumExtractor: ElementExtractor {
    
    var supportedKinds: Set<String> = [SwiftDeclarationKind.Enum.rawValue]
    
    func extract(input: [String : SourceKitRepresentable], nesting: [Name]) -> [PossibleType] {
      guard let name = input.name else { fatalError() }
      
      return [.Complete(Type(accessibility: input.accessibility?.description,
        name: (nesting + name).joinWithSeparator("."),
        extensions: Set(input.extensions ?? []),
        kind: .Enum([]))
        )
      ]
    }
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
