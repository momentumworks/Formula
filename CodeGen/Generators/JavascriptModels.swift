//
//  JavascriptModels.swift
//  CodeGen
//
//  Created by Mark Aron Szulyovszky on 11/07/2016.
//  Copyright © 2016 Momentumworks. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol ExportedType : JSExport {
  
  var accessibility : String { get }
  var name : String { get }
  var extensions : [String] { get }
  var type : String { get }
  var fields: [JavascriptField] { get }
  var staticFields: [JavascriptField] { get }
  var enumCases: [JavascriptEnumCase] { get }
  
  var isStruct: Bool { get }
  var isEnum: Bool { get }
  var isClass: Bool { get }
  
}


@objc public class JavascriptType: NSObject, ExportedType {
  
  public dynamic var accessibility : String
  public dynamic var name : String
  public dynamic var extensions : [String]
  public dynamic var type : String
  public dynamic var fields: [JavascriptField]
  public dynamic var staticFields: [JavascriptField]
  public dynamic var enumCases: [JavascriptEnumCase]
  
  public dynamic var isStruct: Bool
  public dynamic var isEnum: Bool
  public dynamic var isClass: Bool
  
  init(type: Type) {
    self.accessibility = type.accessibility
    self.name = type.name
    self.extensions = Array(type.extensions)
    self.type = type.kind.stringValue
    self.fields = type.kind.fields?.map { JavascriptField(field: $0) } ?? []
    self.staticFields = type.staticFields.map { JavascriptField(field: $0) } ?? []
    self.enumCases = type.kind.enumCases?.map { JavascriptEnumCase(enumCase: $0) } ?? []
    self.isStruct = type.kind.isStruct
    self.isEnum = type.kind.isEnum
    self.isClass = type.kind.isClass
  }
  
}


@objc protocol ExportedField : JSExport {
  
  var accessibility : String { get }
  var name : String { get }
  var type : String { get }

}

@objc public class JavascriptField: NSObject, ExportedField {
  public let accessibility : String
  public let name : String
  public let type : String
  
  public init(field: Field) {
    self.accessibility = field.accessibility
    self.name = field.name
    self.type = field.type
  }
}

@objc protocol ExportedEnumCase : JSExport {
  
  var name : String { get }
  var associatedValues : [String] { get }
  
}

@objc public class JavascriptEnumCase: NSObject, ExportedEnumCase {
  
  public let name: Name
  public let associatedValues: [Name]
  
  public init(enumCase: EnumCase) {
    self.name = enumCase.name
    self.associatedValues = enumCase.associatedValues
  }
  
}


