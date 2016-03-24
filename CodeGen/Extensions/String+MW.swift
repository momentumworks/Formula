//
// Created by Rheese Burgess on 23/02/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public extension String {
  public func toInt() -> Int {
    return Int(self) ?? 0
  }

  public func toFloat() -> Float {
    return Float(self) ?? 0
  }

  public func toCGFloat() -> CGFloat? {
    if let n = NSNumberFormatter().numberFromString(self) {
      return CGFloat(n)
    } else {
      return nil
    }
  }

  public func split(stringToSplitBy: String) -> [String] {
    return self.componentsSeparatedByString(stringToSplitBy)
  }

  public func intSuffixForPrefix(prefix: String) -> Int? {
    let split = self.split(prefix + " ")

    guard split.count == 2, let suffixStr = split[safe: 1], let suffix = Int(suffixStr) else {

      return nil
    }

    return suffix
  }

  public func trim() -> String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }

  public func trimWithNewLines() -> String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}