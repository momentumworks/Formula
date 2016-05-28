//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

extension Array {
  // This little beauty was found here: http://stackoverflow.com/a/30593673/1842158
  subscript (safe index: Int) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
  
}

public func +<T>(left: [T], right: T) -> [T] {
  var newArray = left
  newArray.append(right)

  return newArray
}

public extension Array where Element : Hashable {
  
  public var unique: [Element] {
    return Array(Set(self))
  }
  
}