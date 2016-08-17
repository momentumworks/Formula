//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit

struct SourceKittenElementExtractor <T where T: TupleConvertible, T: Mergeable> {
  let supportedKinds: Set<String>
  let extract: (input: [String: SourceKitRepresentable], name: Name) -> [T]
}

public struct SourceKittenExtractor : ExtractorEngine {
  
  let fileExtension = "swift"

  func extractImports(files: [Path]) -> [Import] {
    return files
      .parallelMap(FileExtractor.extractImports)
      .flatten()
      .array
      .unique
  }
  
  func extractTypes(files: [Path]) -> [Type] {
    return files
      .map(extractTypesFromPath)
      .reduce([Name:Type](), combine: +)
      .values
      .array
  }
  
}


private func extractTypesFromPath(filePath: Path) -> [Name:Type] {
  
  let file = File(path: filePath.description)!
  print("Extracting objects from \(file.path ?? "source string")")
  let structure: Structure = Structure(file: file)
  
  let indexed = Request.Index(file: file.path!).send()
  
  
  guard let substructures = structure.dictionary.substructures,
    let entities = indexed.entities else {
      return [:]
  }
  
  let extractedFromStructure = extractFromTree(
    from: substructures,
    extractors: [
      StructureExtractor.ClassAndStructExtractor,
      StructureExtractor.EnumExtractor
    ],
    traverseDeeper: { $0.substructures })
    .mergeIntoDictionary()
  
  let extractedFromIndex = extractFromTree(
    from: entities,
    extractors: [IndexExtractor.EnumExtractor],
    traverseDeeper: { $0.entities })
    .mergeIntoDictionary()
  
  let extensions = extractFromTree(
    from: substructures,
    extractors: [StructureExtractor.ExtensionExtractor],
    traverseDeeper: { $0.substructures })
    .mergeIntoDictionary()
  
  let allTypes = extractedFromStructure.mergeWith(extractedFromIndex, mergeFn: Type.merge)
  return mergeTypesAndExtensions(allTypes, extensions)
    .mapValues(mapAssociatedValueHints)
}


private func extractFromTree<T where T: TupleConvertible, T: Mergeable>
  (from input: [SourceKitRepresentable],
   extractors: [SourceKittenElementExtractor<T>],
   traverseDeeper: [String: SourceKitRepresentable] -> [SourceKitRepresentable]?,
   currentNesting: [Name] = []) -> [T]
{
  return input
    .map { item -> [T] in
      guard let dict = item.asDictionary,
            let name = dict.name,
            let kind = dict.kind
        else {
          return []
      }
      
      let extractor = extractors.find { $0.supportedKinds.contains(kind) }
      
      let nested = traverseDeeper(dict)
        .flatMap { extractFromTree(from: $0, extractors: extractors, traverseDeeper: traverseDeeper, currentNesting: currentNesting + name) } ?? []
      
      return nested + extractor?.extract(input: dict, name: (currentNesting + name).joinWithSeparator("."))
    }
    .flatten()
    .array

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

private func mapAssociatedValueHints(type: Type) -> Type {
  
  let hints = type.staticFields
    .filter { ($0.name as NSString).hasPrefix("formula_associatedValues_") }
  
  if case .Enum = type.kind where !hints.isEmpty {
    
    let newCases = hints
      .map ({field in
        return EnumCase(
          name: field.name.drop("formula_associatedValues_"),
          associatedValues: field.type.drop("(").drop(")").drop(" ").split(",")
        )
      })
    return type.set(kind: .Enum(newCases))
    
  } else {
    return type
  }
  
}