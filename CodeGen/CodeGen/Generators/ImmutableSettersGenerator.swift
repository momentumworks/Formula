//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

@objc public class ImmutableSettersGenerator : NSObject, Generator {
  public func filter(object: Object) -> Bool {
    return object.extensions.contains("Immutable")
  }

  public func generateFor(objects: [Object]) -> [TypeName : [GeneratedFunction]] {
    let generatedTuples = objects.filter(filter).map { object -> (TypeName, [GeneratedFunction]) in
      let generatedFunctions = object.fields.map { field in
        "\n  \(field.accessibility)func set(\(field.name) \(field.name): \(field.type)) {\n    \(object.constructorCall)\n  }\n"
      }

      return (object.name, generatedFunctions)
    }

    return Dictionary(generatedTuples)
  }
}