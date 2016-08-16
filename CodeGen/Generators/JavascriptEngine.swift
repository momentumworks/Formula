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
    let context = createContext(types, imports: imports)

    return templates
      .map { generate(context, fromTemplate: $0) }
      .joinWithSeparator("\n")
  }
  
}

private func sortByName(lhs: JavascriptType, rhs: JavascriptType) -> Bool {
  return lhs.name < rhs.name
}

private func createContext(types: [Type], imports: [Import]) -> JSContext {
  let jstypes = types.map(JavascriptType.init)
  let imports = imports.sort()
  let context = JSContext()!
  
  context["Type"] = JavascriptType.self
  context["Field"] = JavascriptField.self
  context["EnumCase"] = JavascriptEnumCase.self
  
  context["structs"] = jstypes.filter { $0.isStruct }
  context["enums"] = jstypes.filter { $0.isEnum }
  context["classes"] = jstypes.filter { $0.isClass }
  context["extensions"] = jstypes
    .arrayGroupBy { $0.extensions }
    .mapValues { $0.sort(sortByName) }
  context["imports"] = imports
  
  context.evaluateScript("var console = { log: function(message) { _consoleLog(JSON.stringify(message)) } }")
  let consoleLog: @convention(block) String -> Void = { message in
    print("Javascript log: " + message)
  }
  context["_consoleLog"] = unsafeBitCast(consoleLog, AnyObject.self)
  
  context.exceptionHandler = { context, value in
    print("Javascript exception: \(value)")
  }
  
  return context
}

private func generate(context: JSContext, fromTemplate template: String) -> String {
  return context.evaluateScript("(function printOut() { \(template); })()").toString()!
}
