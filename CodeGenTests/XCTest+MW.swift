//
//  XCTest+MW.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 31/05/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import Quick


extension XCTestCase {
  
  var testBundle: NSBundle {
    return NSBundle(forClass: self.dynamicType)
  }
  
}