//
// Created by Krzysztof Zabłocki on 24/03/16.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
extension Object {
  public var constructor : String {
    let params = self.fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
    let fieldInits = self.fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
    return "init(\(params)) {\n\(fieldInits)\n  }"
  }

  public var constructorCall : String {
    let initParams = self.fields.map { "\($0.name): \($0.name)" }.joinWithSeparator(", ")
    return "\(self.name)(\(initParams))"
  }
}