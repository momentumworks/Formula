//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation

public typealias Extension = String
public typealias Entity = String
public typealias Name = String
public typealias SourceString = String
public typealias Import = String
public typealias Kind = String

public struct Type {
  public let accessibility : String
  public let name : Name
  public let fields : [Field]
  public let extensions : [Extension]
  public let enumCases: [EnumCase]
  public let kind: Kind

  public init(accessibility: String?, name: Name, fields: [Field], extensions: [Extension], kind: Kind, enumCases: [EnumCase] = []) {
    self.accessibility = accessibility ?? ""
    self.name = name
    self.fields = fields
    self.extensions = extensions
    self.kind = kind
    self.enumCases = enumCases
  }

  public func set(accessibility accessibility: String) -> Type {
    return Type(accessibility: accessibility, name: name, fields: fields, extensions: extensions, kind: kind)
  }

  public func set(fields fields: [Field]) -> Type {
    return Type(accessibility: accessibility, name: name, fields: fields, extensions: extensions, kind: kind)
  }

  public func appendExtensions(extensions: [Extension]) -> Type {
    return Type(accessibility: accessibility, name: name, fields: fields, extensions: self.extensions + extensions, kind: kind)
  }

  public func mergeWith(otherObj: Type) -> Type {
    guard otherObj.name == name else {
      return self
    }

    // not proud of this, but it's to allow us to remove optionals
    let accessibility = self.accessibility == "" ? otherObj.accessibility : self.accessibility
    let fields = self.fields + otherObj.fields
    let extensions = self.extensions + otherObj.extensions

    return Type(accessibility: accessibility, name: name, fields: fields, extensions: extensions, kind: kind)
  }
}

public struct Field {
  public let accessibility : String
  public let name : String
  public let type : String
    
  public init(accessibility: Accessibility, name: String, type: String) {
    self.accessibility = accessibility.description
    self.name = name
    self.type = type
  }
}

public enum Accessibility : String, CustomStringConvertible {
  case Private = "source.lang.swift.accessibility.private"
  case Internal = "source.lang.swift.accessibility.internal"
  case Public = "source.lang.swift.accessibility.public"

  public var description : String {
    switch self {
    case Private: return "private"
    case Internal: return ""
    case Public: return "public"
    }
  }
}

public struct Enum {
  
  public let name: Name
  public let accessibility: String?
  public let cases: [EnumCase]
  public let extensions: [Extension]
  
  public func set(accessibility accessibility: String) -> Enum {
    return Enum(name: name, accessibility: accessibility, cases: cases, extensions: extensions)
  }
  
  public func set(extensions extensions: [Extension]) -> Enum {
    return Enum(name: name, accessibility: accessibility, cases: cases, extensions: extensions)
  }
}

public struct EnumCase {
  
  public let name: Name
  public let associatedValues: [Kind]
  
}

