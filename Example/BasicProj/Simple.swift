import AppKit
import MomentumCore

public class Thing: Equatable {
  private let s: String
  let f: Float
  public let i: Int
}

struct OtherThing : Equatable {
  let s : String
}

struct ThirdThing {
  let i : Int
}

public class FourthThing: Equatable {
  private let s: String
  let f: Float
  public let i: Int
}

extension FourthThing: Immutable {}