//
//  JSContext.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 11/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import JavaScriptCore

extension JSContext {
  
  @nonobjc subscript(key: String) -> AnyObject {
    get {
      return objectForKeyedSubscript(key)
    }
    set {
      setObject(newValue, forKeyedSubscript: key)
    }
  }
  
}
