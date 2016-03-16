//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public typealias Extension = String
public typealias TypeName = String
public typealias SourceString = String

@objc public class Object : NSObject {
  public let accessibility : Accessibility?
  public let name : TypeName
  public let fields : [Field]
  public let extensions : [Extension]

  public var constructor : String {
    let params = self.fields.map { "\($0.name): \($0.type)" }.joinWithSeparator(", ")
    let fieldInits = self.fields.map { "    \($0.name) = \($0.name)" }.joinWithSeparator("\n")
    return "  init(\(params)) {\n\(fieldInits)\n  }"
  }

  public var constructorCall : String {
    let initParams = self.fields.map { "\($0.name): \($0.name)" }.joinWithSeparator(", ")
    return "return \(self.name)(\(initParams))"
  }
    
  public init(accessibility: Accessibility?, name: TypeName, fields: [Field], extensions: [Extension]) {
    self.accessibility = accessibility
    self.name = name
    self.fields = fields
    self.extensions = extensions
  }

  public func set(accessibility accessibility: Accessibility) -> Object {
    return Object(accessibility: accessibility, name: name, fields: fields, extensions: extensions)
  }

  public func set(fields fields: [Field]) -> Object {
    return Object(accessibility: accessibility, name: name, fields: fields, extensions: extensions)
  }

  public func appendExtensions(extensions: [Extension]) -> Object {
    return Object(accessibility: accessibility, name: name, fields: fields, extensions: self.extensions + extensions)
  }

  public func mergeWith(otherObj: Object) -> Object {
    guard otherObj.name == name else {
      return self
    }

    let accessibility = self.accessibility ?? otherObj.accessibility
    let fields = self.fields + otherObj.fields
    let extensions = self.extensions + otherObj.extensions

    return Object(accessibility: accessibility, name: name, fields: fields, extensions: extensions)
  }
}

public struct Field {
  public let accessibility : Accessibility
  public let name : String
  public let type : String
}

public enum Accessibility : String, CustomStringConvertible {
  case Private = "source.lang.swift.accessibility.private"
  case Internal = "source.lang.swift.accessibility.internal"
  case Public = "source.lang.swift.accessibility.public"

  public var description : String {
    switch self {
    case Private: return "private "
    case Internal: return ""
    case Public: return "public "
    }
  }
}
