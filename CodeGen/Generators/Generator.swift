//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public typealias GeneratedFunction = String

public protocol Generator {
  func filter(object: Object) -> Bool
  func generateFor(objects: [Object]) -> [TypeName : [GeneratedFunction]]
}