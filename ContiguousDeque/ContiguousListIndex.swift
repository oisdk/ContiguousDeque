public struct ContiguousListIndex {
  internal let val: Int
  internal init(_ val: Int) { self.val = val }
}

extension ContiguousListIndex : Equatable, ForwardIndexType {
  public func successor() -> ContiguousListIndex {
    return ContiguousListIndex(val.predecessor())
  }
}

public func == (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val == rhs.val
}
public func < (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val > rhs.val
}
public func > (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val < rhs.val
}

extension ContiguousListIndex : BidirectionalIndexType {
  public func predecessor() -> ContiguousListIndex {
    return ContiguousListIndex(val.successor())
  }
}

extension ContiguousListIndex : RandomAccessIndexType {
  public func distanceTo(other: ContiguousListIndex) -> Int {
    return val - other.val
  }
  public func advancedBy(n: Int) -> ContiguousListIndex {
    return ContiguousListIndex(val - n)
  }
}