// THIS FILE HAS BEEN AUTO GENERATED AND MUST NOT BE ALTERED DIRECTLY
import AppKit
import MomentumCore
// MARK: - Immutable

	extension Outer.OtherInner {
		
			 func set(i i: Int -> Outer.OtherInner) {
				return Outer.OtherInner(i: i)
			}
		
	}

	extension OtherThing {
		
			 func set(s s: String -> OtherThing) {
				return OtherThing(s: s)
			}
		
	}

	extension Simple {
		
			 func set(s s: String -> Simple) {
				return Simple(s: s)
			}
		
	}

	extension FourthThing {
		
			private func set(s s: String -> FourthThing) {
				return FourthThing(s: s, f: f, i: i)
			}
		
			 func set(f f: Float -> FourthThing) {
				return FourthThing(s: s, f: f, i: i)
			}
		
			public func set(i i: Int -> FourthThing) {
				return FourthThing(s: s, f: f, i: i)
			}
		
	}

	extension Thing {
		
			private func set(s s: String -> Thing) {
				return Thing(s: s, f: f, i: i)
			}
		
			 func set(f f: Float -> Thing) {
				return Thing(s: s, f: f, i: i)
			}
		
			public func set(i i: Int -> Thing) {
				return Thing(s: s, f: f, i: i)
			}
		
	}

	extension Outer.Inner {
		
			 func set(s s: String -> Outer.Inner) {
				return Outer.Inner(s: s)
			}
		
	}

// MARK: -