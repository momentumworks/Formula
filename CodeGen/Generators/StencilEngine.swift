//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import Stencil
import PathKit


struct StencilEngine: TemplateEngine {
  
  let templateExtension = "stencil"

  func generateForFiles(types: [Type], imports: [Import], templates templatePaths: [Path]) -> String {
    let templates = templatePaths.map { try! Template(path: $0) }
    let types = types.map(StencilType.init).sort(sortByName)
    let imports = imports.sort()
    
    let extensions = types
      .splitBy { $0.extensions }
      .mapValues { $0.sort(sortByName) }

    let context = Context(dictionary: [
        "types": types,
        "structs": types.filter { $0.isStruct },
        "enums" : types.filter { $0.isEnum },
        "classes" : types.filter { $0.isClass },
        "extensions": extensions
    ])

    let namespace = Namespace()
    namespace.registerSimpleTag("comma", handler: { context in
      guard let last = (context["forloop"] as? [String: Any])?["last"] as? Bool else {
        return ""
      }
      return last ? "" : ", "
    })
    
    namespace.registerSimpleTag("andSymbol", handler: { context in
      guard let last = (context["forloop"] as? [String: Any])?["last"] as? Bool else {
        return ""
      }
      return last ? "" : "&& "
    })
    
    let generated = templates.reduce("") { accumulated, template in
      do {
        let result = try template.render(context, namespace: namespace)
        return accumulated + result
      } catch {
        print("Failed to render template \(error)")
        return accumulated
      }
    }

    var header = imports.map { "import \($0)" }.joinWithSeparator("\n")
    
    if !header.isEmpty {
        header += "\n"
    }
    return header + generated.trimWithNewLines()
}


}


private func sortByName(lhs: StencilType, rhs: StencilType) -> Bool {
  return lhs.name < rhs.name
}
