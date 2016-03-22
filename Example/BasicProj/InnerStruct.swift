struct Outer {
  struct Inner : Immutable {
    let s: String
  }
  
  struct OtherInner {
    let i: Int
  }
}

extension Outer.OtherInner : Immutable {}