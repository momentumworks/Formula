//
//  main.swift
//  CodeGen
//
//  Created by Rheese Burgess on 15/03/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

let generators: [Generator] = [ImmutableSettersGenerator()]

let directory = "/Users/rb/Documents/Shared Playground Data/Sources"
let parsed = Array(Extractor.parseDirectory(directory).values)

let generatedFuncs = generators.reduce([TypeName : [GeneratedFunction]]()) { accumulated, generator in
  let nextGenerated: [TypeName : [GeneratedFunction]] = generator.generateFor(parsed)

  return accumulated.mergeWith(nextGenerated) { $0 + $1 }
}

for (type, generatedFunctions) in generatedFuncs {
  let source = generatedFunctions.joinWithSeparator("\n\n    ")
  print("\nextension \(type) {\n\(source)\n  }\n")
}