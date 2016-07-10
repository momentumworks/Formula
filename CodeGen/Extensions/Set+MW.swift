//
//  Set+MW.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 28/05/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation

public func +<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
  return lhs.union(rhs)
}