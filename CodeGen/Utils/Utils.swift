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
    try! NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
  }

  static func fullPathForAllFilesAt(directory: String, withExtension ext: String?, ignoreSubdirectory: String?) -> [Path] {
    let subPaths = NSFileManager.defaultManager().enumeratorAtPath(directory)?.allObjects as! [NSString]
    let prefixToIgnore = ignoreSubdirectory.map{ "\(removeTrailingFileSeparator($0))/" }
    
    return subPaths.filter{ subPath in
        let fileShouldBeIgnored: Bool = prefixToIgnore.map{subPath.hasPrefix($0)} ?? false
        guard let ext = ext else {
          return !fileShouldBeIgnored
        }
        return subPath.pathExtension == ext && !fileShouldBeIgnored
      }
      .map { Path("\(directory)/\($0)") }
  }
  
  static func pathFromWorkingDirectory(pathComponent: String) -> String {
    return (NSFileManager.defaultManager().currentDirectoryPath as NSString).stringByAppendingPathComponent(pathComponent)
  }

  static func groupByExtension(paths: [Path]) -> [String: [Path]] {
    return paths.reduce([:] as [String: [Path]]) { (var working, path) in
      guard let ext = path.`extension` else {
        return working    // we need the extension to process a template
      }
      if working[ext] == nil {
        working[ext] = []
      }
      working[ext]?.append(path)
      return working
    }
  }

  static func mkdirAndWriteFile(fileName fileName: String, inDirectory directory: String, content: String) {
    FileUtils.createDirectoryIfNonExistent(directory)
    let outputFile = "\(directory)/\(fileName)"
    try! content.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
  }

}