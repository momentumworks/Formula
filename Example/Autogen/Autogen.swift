// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY
import AppKit
// MARK: - AutoEquatable


extension EnumCase: Equatable {}
public func ==(lhs: EnumCase, rhs: EnumCase) -> Bool {
  
  return    lhs.name == rhs.name && 
    lhs.associatedValues == rhs.associatedValues 
  
}

extension Field: Equatable {}
public func ==(lhs: Field, rhs: Field) -> Bool {
  
  return    lhs.accessibility == rhs.accessibility && 
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
  
  return    lhs.accessibility == rhs.accessibility && 
    lhs.name == rhs.name && 
    lhs.extensions == rhs.extensions && 
    lhs.kind == rhs.kind 
  
}

// MARK: - Immutable



extension FourthThing {
	
	private func set(s s: String -> FourthThing {
		return FourthThing(s: s, f: f, i: i)
	}
	
	 func set(f f: Float -> FourthThing {
		return FourthThing(s: s, f: f, i: i)
	}
	
	public func set(i i: Int -> FourthThing {
		return FourthThing(s: s, f: f, i: i)
	}
	
}



extension Simple {
	
	 func set(s s: String -> Simple {
		return Simple(s: s)
	}
	
}