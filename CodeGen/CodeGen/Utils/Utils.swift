//
// Created by Rheese Burgess on 16/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

struct Utils {
  static func removeTrailingFileSeparator(filePath: String) -> String {
    if (filePath.characters.last == "/") {
      return String(filePath.characters.dropLast())
    } else {
      return filePath
    }
  }

  static func deleteFile(filePath: String) {
    NSLog("Deleting \(filePath)")
    do {
      try NSFileManager.defaultManager().removeItemAtPath(filePath)
    } catch {
      NSLog("Unable to delete \(filePath) - \(error)")
    }
  }
  
  static func createDirectoryIfNonExistent(directory: String) {
    NSLog("Creating directory \(directory)")
    try! NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
  }
}