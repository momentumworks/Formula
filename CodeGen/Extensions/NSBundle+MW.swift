//
//  NSBundle+MW.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 12/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation

public extension NSBundle {
  
  public func pathForFileName(fileName: String) -> String? {
    return pathForResource((fileName as NSString).stringByDeletingPathExtension, ofType: (fileName as NSString).pathExtension);
  }
  
}