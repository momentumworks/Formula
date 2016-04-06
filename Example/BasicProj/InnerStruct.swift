struct Outer {
  struct Inner : Immutable {
    let s: String
  }
  
  struct OtherInner {
    let i: Int
    let x: Optional<Int>
  }
}

extension Outer.OtherInner : Immutable {}