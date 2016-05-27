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
    return self.asDictionary?["key.substructures"] as? [SourceKitRepresentable]
  }
  
  var entities: [SourceKitRepresentable]? {
    return self.asDictionary?["key.entities"] as? [SourceKitRepresentable]
  }
  
  var name: Name? {
    return self.asDictionary?["key.name"] as? String
  }
  
  var kind: Kind? {
    return self.asDictionary?["key.kind"] as? String
  }
  
}