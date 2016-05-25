import AppKit
import MomentumCore

public class Thing: Equatable {
  private let s: String
  let f: Float
  public let i: Int
  var calculated: Int { return 1 }
  static let constant: Int = 10
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

enum FifthThing {
  case One(String), Two(String), Three
}

extension FifthThing: AutoEquatable {}