//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public extension Dictionary {
  public init(tupleArray: [Element]) {
    self.init()
    for (k, v) in tupleArray {
      self[k] = v
    }
  }
  
  public init(tupleArray: [Element], mergeFn: (Value, Value) -> Value) {
    self.init()
    for (k, v) in tupleArray {
      if let existing = self[k] {
        self[k] = mergeFn(v, existing)
      } else {
        self[k] = v
      }
    }
  }
  
  @warn_unused_result
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
  
  @warn_unused_result
  func mapTuples<OutKey: Hashable, OutValue>(@noescape transform: Element throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
    return Dictionary<OutKey, OutValue>(tupleArray: try map(transform))
  }
  
  @warn_unused_result
  func mapValues<OutValue>(@noescape transform: Value throws -> OutValue) rethrows -> [Key: OutValue] {
    return Dictionary<Key, OutValue>(tupleArray: try map { (k, v) in (k, try transform(v)) })
  }
  
  @warn_unused_result
  func filterTuples(@noescape includeElement: Element throws -> Bool) rethrows -> [Key: Value] {
    return Dictionary(tupleArray: try filter(includeElement))
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
