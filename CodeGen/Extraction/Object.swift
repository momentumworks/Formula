//
// Created by Rheese Burgess on 15/03/2016.
// Copyright (c) 2016 Momentumworks. All rights reserved.
//

import Foundation
import SourceKittenFramework

public typealias Extension = String
public typealias Entity = String
public typealias Name = String
public typealias SourceString = String
public typealias Import = String

public enum Kind {
  case Struct([Field])
  case Class([Field])
  case Enum([EnumCase])
  case Unknown
  
  init(rawValue: String?) {
    guard let rawValue = rawValue else { fatalError() }
    switch rawValue {
    case "struct", SwiftDeclarationKind.ExtensionStruct.rawValue:
      self = .Struct([])
    case "enum", SwiftDeclarationKind.ExtensionEnum.rawValue:
      self = .Enum([])
    case "class", SwiftDeclarationKind.ExtensionClass.rawValue:
      self = .Class([])
    case SwiftDeclarationKind.Extension.rawValue:
      self = .Unknown
    default:
      fatalError()
    }
  }
}

public struct Type {
  public let accessibility : String
  public let name : Name
  public let extensions : [Extension]
  public let kind: Kind

  public init(accessibility: String?, name: Name, extensions: [Extension], kind: Kind) {
    self.accessibility = accessibility ?? ""
    self.name = name
    self.extensions = extensions
    self.kind = kind
  }

  public func set(accessibility accessibility: String) -> Type {
    return Type(accessibility: accessibility, name: name, extensions: extensions, kind: kind)
  }

  public func appendExtensions(extensions: [Extension]) -> Type {
    return Type(accessibility: accessibility, name: name, extensions: self.extensions + extensions, kind: kind)
  }
}


public func +(lhs: Type, rhs: Type) -> Type {
  guard lhs.name == rhs.name else {
    return lhs
  }
  
  // not proud of this, but it's to allow us to remove optionals
  let accessibility = lhs.accessibility == "" ? rhs.accessibility : lhs.accessibility
  let extensions = lhs.extensions + rhs.extensions
  let kind = {
    switch (lhs.kind, rhs.kind) {
    case let (.Struct(lhsValue), .Struct(rhsValue)):
      return .Struct(lhsValue + rhsValue)
    case let (.Enum(lhsValue), .Enum(rhsValue)):
      return .Enum(lhsValue + rhsValue)
    case let (.Class(lhsValue), .Class(rhsValue)):
      return .Class(lhsValue + rhsValue)
    case (.Unknown, _):
      return rhs.kind
    case (_, .Unknown):
      return lhs.kind
    default:
      fatalError()
    }
  }() as Kind
  
  return Type(accessibility: accessibility, name: lhs.name, extensions: extensions, kind: kind)
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

public struct EnumCase {
  
  public let name: Name
  public let associatedValues: [Kind]
  
}
