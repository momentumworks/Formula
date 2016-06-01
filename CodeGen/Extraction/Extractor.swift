//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

public class Extractor {

  static func extractImports(file: File) -> [Import] {
    return Request.Index(file: file.path!).send()
      .dependencies?
      .flatMap(IndexExtractor.extractImports) ?? []
  }
  
  static func extractImports(files: [File]) -> [Import] {
    return files
      .flatMap(extractImports)
      .unique
      .filter { $0 != "Swift" }
  }

  static func extractTypes(file: File) -> [Name:Type] {
    
    print("Extracting objects from \(file.path ?? "source string")")
    let structure: Structure = Structure(file: file)
    
    let indexed = Request.Index(file: file.path!).send()

    guard let substructures = structure.dictionary.substructures,
          let entities = indexed.entities else {
      return [:]
    }
    
    let extractedClassesStructs = extract(from: substructures, function: StructureExtractor.extractClassOrStruct)
    
    // the associated values that enum cases hold only appear in the output of the Index command
    let enumsFromIndex = extract(from: entities, function: IndexExtractor.extractEnum)
    
    // but we still need the output of the structure to extract out accessiblity and other relevant information
    let enumsFromStructure = extract(from: substructures, function: StructureExtractor.extractEnum)

    // we have to extract out extensions separately for the enums, since they appear completely inconsistently throughout the structure output (not like with classes and structs, where they're nested)
    let extensions = extract(from: substructures, function: StructureExtractor.extractExtensionTypes)

    let allTypes = enumsFromStructure.mergeWith(enumsFromIndex, mergeFn: Type.merge) + extractedClassesStructs

    return mergeTypesAndExtensions(allTypes, extensions)
  }
  
  static func extractTypes(files: [File]) -> [Name:Type] {
    return files
      .map(extractTypes)
      .reduce([Name:Type](), combine: +)
  }
  
}

private func extract<T where T: TupleConvertible, T: Mergeable>(from input: [SourceKitRepresentable],
                     function: (source: SourceKitRepresentable, nesting: [Name]) -> [T]) -> [Name: T] {
  let tuples = input
    .flatMap { function(source: $0, nesting: []) }
    .map { $0.toTuple() }

  return Dictionary(tupleArray: tuples, mergeFn: T.merge)
}

private func mergeTypesAndExtensions(lhs: [Name: Type], _ rhs: [Name: ExtensionType]) -> [Name: Type] {
  var merged = lhs
  for (k, v) in rhs {
    if let existing = merged[k] {
      merged[k] = v + existing
    }
  }
  return merged
}