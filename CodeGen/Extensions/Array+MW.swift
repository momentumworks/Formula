//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public func +<T>(left: [T], right: T) -> [T] {
  var newArray = left
  newArray.append(right)

  return newArray
}