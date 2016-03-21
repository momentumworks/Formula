//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public extension Dictionary {
  public init(_ tupleArr: [Element]) {
    self.init()
    for (k, v) in tupleArr {
      self[k] = v
    }
  }
  
  public init(_ tupleArr: [Element], mergeFn: (Value, Value) -> Value) {
    self.init()
    for (k, v) in tupleArr {
      if let existing = self[k] {
        self[k] = mergeFn(v, existing)
      } else {
        self[k] = v
      }
    }
  }

  public func mergeWith(other: Dictionary<Key, Value>, mergeFn: (Value, Value) -> Value) -> Dictionary<Key, Value> {
    var merged = self
    for (k, v) in other {
      if let existing = merged[k] {
        merged[k] = mergeFn(v, existing)
      } else {
        merged[k] = v
      }
    }
    return merged
  }
}

public func +<K, V>(left: [K:V], right: [K:V]) -> [K:V] {
  var map = [K: V]()
  for (k, v) in left {
    map[k] = v
  }
  for (k, v) in right {
    map[k] = v
  }
  return map
}

public func +<K, V>(left: [K:V], right: (K, V)?) -> [K:V] {
  guard let right = right else { return left }

  var newDict = left
  newDict[right.0] = right.1

  return newDict
}