public struct SeededGenerator: RandomNumberGenerator {
  private var state: UInt64
  private static let m: UInt64 = 1 << 48
  private static let a: UInt64 = 25214903917
  private static let c: UInt64 = 11

  public init(using seed: UInt64) {
    self.state = seed
  }
  
  private mutating func next() -> UInt32 {
    state = (SeededGenerator.a &* state &+ SeededGenerator.c) % SeededGenerator.m
    return UInt32(truncatingIfNeeded: state >> 15)
  }
  
  public mutating func next() -> UInt64 {
    return UInt64(next() as UInt32) << 32 | UInt64(next() as UInt32)
  }
}

// Examples
// var lcr = SeededGenerator(using: 16997325)
// let randInt = lcr.next()