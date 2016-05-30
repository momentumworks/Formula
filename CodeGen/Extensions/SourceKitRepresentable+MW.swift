//
//  SourceKitRepresentable+MW.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 27/05/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

extension SourceKitRepresentable {
  
  var asDictionary: [String: SourceKitRepresentable]? {
    return self as? [String: SourceKitRepresentable]
  }
  
  var asArray: [SourceKitRepresentable]? {
    return self as? [SourceKitRepresentable]
  }
  
  var substructures: [SourceKitRepresentable]? {
    return asDictionary?["key.substructure"] as? [SourceKitRepresentable]
  }
  
  var entities: [SourceKitRepresentable]? {
    return asDictionary?["key.entities"] as? [SourceKitRepresentable]
  }
  
  var dependencies: [SourceKitRepresentable]? {
    return asDictionary?["key.dependencies"] as? [SourceKitRepresentable]
  }
  
  var name: Name? {
    return asDictionary?["key.name"] as? Name
  }
  
  var kind: String? {
    return asDictionary?["key.kind"] as? String
  }
  
  var typeName: Name? {
    return asDictionary?["key.typename"] as? Name
  }
  
  
  var accessibility: Accessibility? {
    guard let string = self.asDictionary?["key.accessibility"] as? String else { return nil }
    return Accessibility(rawValue: string)
  }
  
  var inheritedTypes: [SourceKitRepresentable]? {
    return asDictionary?["key.inheritedtypes"] as? [SourceKitRepresentable] ?? []
  }
  
  var fieldIsntCalculated: Bool {
    return asDictionary?["key.bodylength"] == nil
  }
  
  var fieldIsntStatic: Bool {
    return asDictionary?.kind != SwiftDeclarationKind.VarStatic.rawValue
//    // This feels dangerous...
//    return field.kind.flatMap{ $0 } != Optional(SwiftDeclarationKind.VarStatic.rawValue)
  }

  
}