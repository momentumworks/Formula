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

protocol TupleConvertible {
  var name: Name { get }
  func toTuple() -> (Name, Self)
}

public enum Kind {
  case Struct([Field])
  case Class([Field])
  case Enum([EnumCase])
  
  // there's a possiblity that we can't infer the Kind properly, when dealing with extensions. so we'll need an option to allow this temporarily, before merging all types with the same name.
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
    default:
      fatalError("type can't be inferred")
    }
  }
  
}

public extension Kind {
  var stringValue: String {
    switch self {
    case .Struct:   return "struct"
    case .Enum:     return "enum"
    case .Class:    return "class"
    case .Unknown:  return "unkown"
    }
  }
  
  var fields: [Field]? {
    switch self {
    case let .Class(fields):  return fields
    case let .Struct(fields): return fields
    default:                   return nil
    }
  }
  
  var enumCases: [EnumCase]? {
    switch self {
    case let .Enum(cases):  return cases
    default:                return nil
    }
  }
  
  var isEnum: Bool {
    switch self {
    case .Enum: return true
    default:    return false
    }
  }
  
  var isStruct: Bool {
    switch self {
    case .Struct: return true
    default:    return false
    }
  }

  var isClass: Bool {
    switch self {
    case .Class: return true
    default:    return false
    }
  }
}

public struct Type {
  public let accessibility : String
  public let name : Name
  public let extensions : Set<Extension>
  public let kind: Kind

  public init(accessibility: String?, name: Name, extensions: Set<Extension>, kind: Kind) {
    self.accessibility = accessibility ?? ""
    self.name = name
    self.extensions = extensions
    self.kind = kind
  }

  public func set(accessibility accessibility: String) -> Type {
    return Type(accessibility: accessibility, name: name, extensions: extensions, kind: kind)
  }

  public func appendExtensions(extensions: Set<Extension>) -> Type {
    return Type(accessibility: accessibility, name: name, extensions: self.extensions + extensions, kind: kind)
  }
}

extension Type: TupleConvertible {
  public func toTuple() -> (Name, Type) {
    return (self.name, self)
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

public struct ExtensionType {
  public let name : String
  public let extensions : Set<Extension>
}

extension ExtensionType: TupleConvertible {
  public func toTuple() -> (Name, ExtensionType) {
    return (self.name, self)
  }
}

public func +(lhs: ExtensionType, rhs: ExtensionType) -> ExtensionType {
  guard lhs.name == rhs.name else {
    return lhs
  }
  return ExtensionType(name: lhs.name, extensions: lhs.extensions + rhs.extensions)
}

public func +(lhs: Type, rhs: ExtensionType) -> Type {
  guard lhs.name == rhs.name else {
    return lhs
  }
  return Type(accessibility: lhs.accessibility, name: lhs.name, extensions: lhs.extensions + rhs.extensions, kind: lhs.kind)
}

public func +(lhs: ExtensionType, rhs: Type) -> Type {
  guard lhs.name == rhs.name else {
    return rhs
  }
  return Type(accessibility: rhs.accessibility, name: rhs.name, extensions: lhs.extensions + rhs.extensions, kind: rhs.kind)
}



