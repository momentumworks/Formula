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

protocol Mergeable {
  static func merge(lhs: Self, rhs: Self) -> Self
}

public enum PossibleType {
  case Complete(Type)
  case PartialExtension(ExtensionType)
  
  var getType: Type? {
    if case .Complete(let type) = self {
      return type
    } else {
      return nil
    }
  }
  
  var getExtensionType: ExtensionType? {
    if case .PartialExtension(let type) = self {
      return type
    } else {
      return nil
    }
  }
  
}


extension PossibleType: Mergeable {
  static func merge(lhs: PossibleType, rhs: PossibleType) -> PossibleType {
    switch (lhs, rhs) {
    case (.Complete(let lhsType), .Complete(let rhsType)):
      return PossibleType.Complete(lhsType + rhsType)
      
    case (.Complete(let lhsType), .PartialExtension(let rhsType)):
      return PossibleType.Complete(rhsType + lhsType)
    case (.PartialExtension(let lhsType), .Complete(let rhsType)):
      return PossibleType.Complete(lhsType + rhsType)
      
    case (.PartialExtension(let lhsType), .PartialExtension(let rhsType)):
      return PossibleType.PartialExtension(lhsType + rhsType)
    }
  }
}

extension PossibleType: TupleConvertible {
  
  var name: Name {
    switch self {
    case .Complete(let type):
      return type.name
    case .PartialExtension(let extensionType):
      return extensionType.name
    }
  }
  
  func toTuple() -> (Name, PossibleType) {
    return (self.name, self)
  }
  
}



public enum Kind {
  case Struct([Field])
  case Class([Field])
  case Enum([EnumCase])
  
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

extension Type: Mergeable {
  static func merge(lhs: Type, rhs: Type) -> Type {
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
}

public func +(lhs: Type, rhs: Type) -> Type {
  return Type.merge(lhs, rhs: rhs)
}


public struct Field {
  public let accessibility : String
  public let name : Name
  public let type : String
    
  public init(accessibility: Accessibility, name: String, type: Name) {
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
  public let associatedValues: [Name]
  
}

// this is an incomplete type that is required because some extensions (especially for enums) only appear in the output
// of the index command, without additional type information.
// this is used to record all (name : extension) pairs, so later they can get merged back into the "complete" Type with the same name.
public struct ExtensionType {
  public let name : String
  public let extensions : Set<Extension>
}

extension ExtensionType: TupleConvertible {
  public func toTuple() -> (Name, ExtensionType) {
    return (self.name, self)
  }
}

extension ExtensionType: Mergeable {
  static func merge(lhs: ExtensionType, rhs: ExtensionType) -> ExtensionType {
    guard lhs.name == rhs.name else {
      return lhs
    }
    return ExtensionType(name: lhs.name, extensions: lhs.extensions + rhs.extensions)
  }
}


// this is here so we can merge an ExtensionType with a Type. this means that all of the additional Extensions
// the ExtensionType holds will get added to the Type.
public func +(lhs: ExtensionType, rhs: Type) -> Type {
  guard lhs.name == rhs.name else {
    return rhs
  }
  return Type(accessibility: rhs.accessibility, name: rhs.name, extensions: lhs.extensions + rhs.extensions, kind: rhs.kind)
}

public func +(lhs: ExtensionType, rhs: ExtensionType) -> ExtensionType {
  guard lhs.name == rhs.name else {
    return lhs
  }
  return ExtensionType(name: rhs.name, extensions: lhs.extensions + rhs.extensions)
}



extension EnumCase: Equatable {}
public func ==(lhs: EnumCase, rhs: EnumCase) -> Bool {
  
  return
    lhs.name == rhs.name &&
      lhs.associatedValues == rhs.associatedValues
  
}

extension Field: Equatable {}
public func ==(lhs: Field, rhs: Field) -> Bool {
  
  return
    lhs.accessibility == rhs.accessibility &&
      lhs.name == rhs.name &&
      lhs.type == rhs.type
  
}


extension Kind: Equatable {}
public func ==(lhs: Kind, rhs: Kind) -> Bool {
  switch (lhs, rhs) {
  case (.Struct(let lhsValue1), .Struct(let rhsValue1 )) where lhsValue1 == rhsValue1 :
    return true
  case (.Class(let lhsValue1), .Class(let rhsValue1 )) where lhsValue1 == rhsValue1 :
    return true
  case (.Enum(let lhsValue1), .Enum(let rhsValue1 )) where lhsValue1 == rhsValue1 :
    return true
  default: return false
  }
  
}

extension Type: Equatable {}
public func ==(lhs: Type, rhs: Type) -> Bool {
  
  return
    lhs.accessibility == rhs.accessibility &&
      lhs.name == rhs.name &&
      lhs.extensions == rhs.extensions &&
      lhs.kind == rhs.kind
  
}

