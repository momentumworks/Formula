// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY
import AppKit
import MomentumCore
// MARK: - Description

public extension CustomDebugStringConvertible {
    var debugDescription: String {
        return debugDescription()
    }
    
    func debugDescription(indentationLevel: Int = 0) -> String {
        
        let indentString = (0..<indentationLevel).reduce("") { tabs, _ in tabs + "\t" }
        
        var s = "\(self.dynamicType)"
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        
        if children.count == 0 {
            return "\(s) = \(debugDescription),"
        }
        
        s += " {"
        
        s = children.reduce(s) {
            reducedString, child in
            
            if let aChild = child.1 as? CustomDebugStringConvertible {
                let childDescription = aChild.debugDescription(indentationLevel + 1)
                return reducedString + "\n\(indentString)\t\(child.0!): \(childDescription)"
            } else {

                return reducedString +  "\n\(indentString)\t\(child.0!): \(child.1),"
            }
        }
        
        s = s.substringToIndex(s.characters.endIndex.predecessor())
        s += "\n\(indentString)}"
        
        return s
    }
}


// MARK: -
// MARK: - Immutable

	extension FourthThing {
		
	}

	extension Outer.Inner {
		
			 func set(s s: String -> Outer.Inner {
				return Outer.Inner(s: s)
			}
		
	}

	extension Outer.OtherInner {
		
	}

	extension Simple {
		
			 func set(s s: String -> Simple {
				return Simple(s: s)
			}
		
	}

	extension Thing {
		
	}

// MARK: -