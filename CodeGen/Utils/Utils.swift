//
// Created by Rheese Burgess on 16/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import PathKit

struct FileUtils {
  
  static func removeTrailingFileSeparator(filePath: String) -> String {
    if (filePath.characters.last == "/") {
      return String(filePath.characters.dropLast())
    } else {
      return filePath
    }
  }

  static func deleteFile(filePath: String) {
    print("Deleting \(filePath)")
    do {
      try NSFileManager.defaultManager().removeItemAtPath(filePath)
    } catch {
      print("Unable to delete \(filePath) - \(error)")
    }
  }
  
  static func createDirectoryIfNonExistent(directory: String) {
    print("Creating directory \(directory)")
    try! NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
  }
  
  static func fullPathForAllFilesAt(directory: String, withExtension ext: String, ignoreSubdirectory: String?) -> [Path] {
    let subPaths = NSFileManager.defaultManager().enumeratorAtPath(directory)?.allObjects as! [NSString]
    let prefixToIgnore = ignoreSubdirectory.map{ "\(removeTrailingFileSeparator($0))/" }
    
    return subPaths.filter{ subPath in
        let fileShouldBeIgnored: Bool = prefixToIgnore.map{subPath.hasPrefix($0)} ?? false
        return subPath.pathExtension == ext && !fileShouldBeIgnored
      }
      .map { Path("\(directory)/\($0)") }
  }
  
  static func pathFromWorkingDirectory(pathComponent: String) -> String {
    return (NSFileManager.defaultManager().currentDirectoryPath as NSString).stringByAppendingPathComponent(pathComponent)
  }
}