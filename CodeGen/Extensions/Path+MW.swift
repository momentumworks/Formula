//
//  Path+MW.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 16/08/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import PathKit

extension Path {
  
  var fileExtension: String? {
    let pathExtension = (self.description as NSString).pathExtension
    if  pathExtension.isEmpty {
      return nil
    }
    
    return pathExtension
  }
  
}
