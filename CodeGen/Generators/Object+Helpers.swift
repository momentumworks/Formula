//
// Created by Krzysztof Zabłocki on 24/03/16.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
extension Type {
  public var constructor : String {
    
    switch kind {
    case .Class(let fields):
      let params = fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
      let fieldInits = fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
      return "init(\(params)) {\n\(fieldInits)\n  }"
    case .Struct(let fields):
      let params = fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
      let fieldInits = fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
      return "init(\(params)) {\n\(fieldInits)\n  }"
    case .Enum(let cases):
      fatalError()
    }
  }

  public var constructorCall : String {
//    let initParams = self.fields.map { "\($0.name): \($0.name)" }.joinWithSeparator(", ")
//    return "\(self.name)(\(initParams))"
//    return ""
    fatalError()
  }
}