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
  
  @warn_unused_result
  func splitBy<Key: Hashable>(keyExtractor: Element -> [Key]) -> [Key: [Element]] {
    return reduce([Key: [Element]]()) { (acc: [Key: [Element]], type: Element) in
      var newAcc = acc
      keyExtractor(type).forEach { ext in
        if let oldValue = newAcc[ext] {
          newAcc[ext] = oldValue + type
        } else {
          newAcc[ext] = [type]
        }
      }
      return newAcc
    }
  }
  
  @warn_unused_result
  func splitBy<Key: Hashable>(keyExtractor: Element -> Key) -> [Key: Element] {
    return reduce([Key: Element]()) { acc, item in
      var newAcc = acc
      newAcc[keyExtractor(item)] = item
      return newAcc
    }
  }

  
}

public func +<T>(left: [T], right: T) -> [T] {
  var newArray = left
  newArray.append(right)
  return newArray
}

extension SequenceType where Generator.Element: Hashable {
  
  var unique: [Generator.Element] {
    var seen: Set<Generator.Element> = []
    return filter {
      if seen.contains($0) {
        return false
      } else {
        seen.insert($0)
        return true
      }
    }
  }
  
}


public extension LazyMapCollection {
  
  var array: [Element] {
    return Array(self)
  }
  
}
