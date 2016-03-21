import AppKit

struct Thing : Equatable {
  private let s : String
  let f : Float
  public let i : Int
}

struct OtherThing : Equatable {
  let s : String
}

struct ThirdThing {
  let i : Int
}