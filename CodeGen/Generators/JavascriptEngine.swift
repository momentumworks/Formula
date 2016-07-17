//
//  JavascriptEngine.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 11/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import JavaScriptCore
import PathKit

struct JavascriptEngine: TemplateEngine {
  
  let templateExtension = "js"
  
  func generateForFiles(types: [Type], imports: [Import], templates: [Path]) -> String {
  
    let templates = templates.map { try! $0.read() as String }
    let types = types.map(JavascriptType.init)
    let imports = imports.sort()
    
    let context = JSContext()!
    
    context["Type"] = JavascriptType.self
    context["Field"] = JavascriptField.self
    context["EnumCase"] = JavascriptEnumCase.self
    
    context["structs"] = types.filter { $0.isStruct }
    context["enums"] = types.filter { $0.isEnum }
    context["classes"] = types.filter { $0.isClass }
    context["extensions"] = types
      .splitBy { $0.extensions }
      .mapValues { $0.sort(sortByName) }
    context["imports"] = imports

    
    return templates
      .map { context.evaluateScript("(function printOut() { \($0); })()").toString()! }
      .joinWithSeparator("\n")
  }
  
}

private func sortByName(lhs: JavascriptType, rhs: JavascriptType) -> Bool {
  return lhs.name < rhs.name
}
