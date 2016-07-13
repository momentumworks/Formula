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
    
    context.setObject(JavascriptType.self, forKeyedSubscript: "Type")
    context.setObject(JavascriptField.self, forKeyedSubscript: "Field")
    context.setObject(JavascriptEnumCase.self, forKeyedSubscript: "EnumCase")

    
    context["structs"] = types.filter { $0.isStruct }
    context["enums"] = types.filter { $0.isEnum }
    context["classes"] = types.filter { $0.isClass }
    context["extensions"] = types
      .splitBy { $0.extensions }
    //      .mapValues { $0.sort(sortByName) }

    
    return templates
      .map {
        context.evaluateScript("(function printOut() { \($0); })()").toString()!
      }
      .joinWithSeparator("\n")
  }
  
}

