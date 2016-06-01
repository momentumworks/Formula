
public enum Kind : AutoEquatable  {
  case Struct([Field])
  case Class([Field])
  case Enum([EnumCase])

}

public struct Type : AutoEquatable {
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




public struct Field : AutoEquatable {
  public let accessibility : String
  public let name : Name
  public let type : String

  public init(accessibility: Accessibility, name: String, type: Name) {
    self.accessibility = accessibility.description
    self.name = name
    self.type = type
  }
}


public struct EnumCase: AutoEquatable {

  public let name: Name
  public let associatedValues: [Name]

}
