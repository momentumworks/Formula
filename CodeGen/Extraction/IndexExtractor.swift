//
//  IndexExtractor.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 01/06/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct IndexExtractor {
  
  // this only works with the output of the "index" command of SourceKit(ten)
  static func extractImports(entities: SourceKitRepresentable) -> Import? {
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
  static func extractEnum(entities: SourceKitRepresentable, nesting: [Name] = []) -> [Type] {
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
        .flatMap { extractEnum($0, nesting: nesting + name) } ?? []
    }
    
    return [Type(accessibility: nil,
      name: (nesting + name).joinWithSeparator("."),
      extensions: [],
      kind: .Enum(entitiesDict.entities?.flatMap(extractEnumCase) ?? [])
      )]
  }
  
}

private func extractEnumCase(typeDict: SourceKitRepresentable) -> EnumCase? {
  
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
  