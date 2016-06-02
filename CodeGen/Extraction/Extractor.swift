//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework



protocol ElementExtractor {
  var supportedKinds: Set<String> { get }
  func extract(input: [String: SourceKitRepresentable], nesting: [Name]) -> [PossibleType]
}

public class Extractor {

  static func extractImports(files: [File]) -> [Import] {
    return files
      .flatMap(FileExtractor.extractImports)
      .unique
  }

  static func extractTypes(file: File) -> [Name:Type] {
    
    print("Extracting objects from \(file.path ?? "source string")")
    let structure: Structure = Structure(file: file)
    
    let indexed = Request.Index(file: file.path!).send()

    guard let substructures = structure.dictionary.substructures,
          let entities = indexed.entities else {
      return [:]
    }
    
    let extractedFromStructure = extractFromTree(from: substructures, extractors: [
                                                  StructureExtractor.ClassAndStructExtractor(),
                                                  StructureExtractor.EnumExtractor()],
                                                 traverseDeeper: { $0.substructures })
      .map { $0.getType! }
      .mergeIntoDictionary()
    
    let extractedFromIndex = extractFromTree(from: entities, extractors: [IndexExtractor.EnumExtractor()], traverseDeeper: { $0.entities })
      .map { $0.getType! }
      .mergeIntoDictionary()

    let extensions = extractFromTree(from: substructures, extractors: [StructureExtractor.ExtensionsExtractor()],
      traverseDeeper: { $0.substructures })
      .map { $0.getExtensionType! }
      .mergeIntoDictionary()
    
    
////    let extractedClassesStructs = extract(from: substructures, function: StructureExtractor.extractClassOrStruct)
//    
//    // the associated values that enum cases hold only appear in the output of the Index command
//    let enumsFromIndex = extract(from: entities, function: IndexExtractor.extractEnum)
//    
//    // but we still need the output of the structure to extract out accessiblity and other relevant information
//    let enumsFromStructure = extract(from: substructures, function: StructureExtractor.extractEnum)
//
//    // we have to extract out extensions separately for the enums, since they appear completely inconsistently throughout the structure output (not like with classes and structs, where they're nested)
//    let extensions = extract(from: substructures, function: StructureExtractor.extractExtensionTypes)

    let allTypes = extractedFromStructure.mergeWith(extractedFromIndex, mergeFn: Type.merge)
    return mergeTypesAndExtensions(allTypes, extensions)
  }
  
  static func extractTypes(files: [File]) -> [Name:Type] {
    return files
      .map(extractTypes)
      .reduce([Name:Type](), combine: +)
  }
  
}

private func extractFromTree(from input: [SourceKitRepresentable],
                             extractors: [ElementExtractor],
                             traverseDeeper: [String: SourceKitRepresentable] -> [SourceKitRepresentable]?,
                             currentNesting: [Name] = []) -> [PossibleType] {
  return input
    .flatMap { item -> [PossibleType] in
      guard let dict = item.asDictionary,
            let name = dict.name,
            let kind = dict.kind
        else {
          return []
      }
      
      let extractor = extractors.find { $0.supportedKinds.contains(kind) }
      
      let nested = traverseDeeper(dict)
        .flatMap { extractFromTree(from: $0, extractors: extractors, traverseDeeper: traverseDeeper, currentNesting: currentNesting + name) } ?? []
      
      return nested + extractor?.extract(dict, nesting: currentNesting)
    }

}

private extension Array where Element : TupleConvertible, Element : Mergeable {
  func mergeIntoDictionary() -> [Name: Element] {
    return Dictionary(tupleArray: self.map { $0.toTuple() }, mergeFn: Element.merge)
  }
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