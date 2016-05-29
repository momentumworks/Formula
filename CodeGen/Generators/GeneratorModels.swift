//
//  GeneratorModels.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 29/05/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation

// this is the Stencil-compatible version of our Type model

@objc public class StencilType: NSObject {
  
  public let accessibility : String
  public let name : Name
  public let extensions : [Extension]
  public let type : String
  public let fields: [StencilField]?
  public let enumCases: [StencilEnumCase]?
  
  init(type: Type) {
    self.accessibility = type.accessibility
    self.name = type.name
    self.extensions = Array(type.extensions)
    self.type = type.kind.stringValue
    self.fields = type.kind.fields?.map { StencilField(field: $0) } ?? []
    self.enumCases = type.kind.enumCases?.map { StencilEnumCase(enumCase: $0) } ?? []
  }
  
}




extension StencilType {
//  public var constructor : String {
//    
//    switch kind {
//    case .Class(let fields):
//      let params = fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
//      let fieldInits = fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
//      return "init(\(params)) {\n\(fieldInits)\n  }"
//    case .Struct(let fields):
//      let params = fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
//      let fieldInits = fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
//      return "init(\(params)) {\n\(fieldInits)\n  }"
//    case .Enum(let cases):
//      fatalError()
//    case .Unknown:
//      fatalError()
//    }
//  }
  
  public var constructorCall : String {
    
    let initParams = {
      if let fields = fields {
        return fields.map { "\($0.name): \($0.name)" }.joinWithSeparator(", ")
      } else if let enumCases = enumCases {
        return enumCases.map { "\($0.name)" }.joinWithSeparator("")
      } else {
        fatalError("no fields or cases property found on StencilType")
      }
    }() as String

    return "\(self.name)(\(initParams))"
  }
}

@objc public class StencilField: NSObject {
  public let accessibility : String
  public let name : String
  public let type : String
  
  public init(field: Field) {
    self.accessibility = field.accessibility
    self.name = field.name
    self.type = field.type
  }
}

@objc public class StencilEnumCase: NSObject {
  
  public let name: Name
  public let associatedValues: [Name]
  
  public init(enumCase: EnumCase) {
    self.name = enumCase.name
    self.associatedValues = enumCase.associatedValues
  }
  
}
