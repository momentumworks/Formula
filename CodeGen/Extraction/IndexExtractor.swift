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
  
  struct EnumExtractor: ElementExtractor {
    
    var supportedKinds: Set<String> = [SwiftDeclarationKind.Enum.rawValue]
    
    func extract(input: [String : SourceKitRepresentable], nesting: [Name]) -> [ExtractorOutput] {
      guard let name = input.name else { fatalError() }
      
      return [
        Type(accessibility: nil,
              name: (nesting + name).joinWithSeparator("."),
              extensions: [],
              kind: .Enum(input.entities?.flatMap(extractEnumCase) ?? [])
        )
      ]
    }
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
  