/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues, with the first queue beginning at the start of the Deque, and the second
beginning at the end (in reverse):
```
First queue   Second queue
v              v
[0, 1, 2, 3] | [3, 2, 1, 0]
```
This allows for O(*1*) prepending, appending, and removal of first and last elements.

This implementation of a Deque uses two reversed `ArraySlice`s as the queues. (this
means that the first array has reversed semantics, while the second does not) This allows
for O(*1*) indexing.
*/
// MARK: Definition

public struct ContiguousDequeSlice<Element> {
  internal var front, back: ArraySlice<Element>
}

extension ContiguousDequeSlice {
  public typealias SubSequence = ContiguousDequeSlice<Element>
  public typealias Generator = ContiguousDequeSliceGenerator<Element>
}

extension ContiguousDequeSlice : CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      "[" +
        ", ".join(front.reverse().map { String(reflecting: $0) }) +
        " | " +
        ", ".join(back.map { String(reflecting: $0) }) + "]"
  }
}

// MARK: Init

extension ContiguousDequeSlice {
  internal init(_ front: ArraySlice<Element>, _ back: ArraySlice<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
}

extension ContiguousDequeSlice {
  internal init(balancedF: ArraySlice<Element>, balancedB: ArraySlice<Element>) {
    (front, back) = (balancedF, balancedB)
  }
  public init(_ from: ContiguousDeque<Element>) {
    (front, back) = (ArraySlice(from.front), ArraySlice(from.back))
  }
}

extension ContiguousDequeSlice {
  internal init(array: [Element]) {
    let half = array.endIndex / 2
    self.init(
      balancedF: ArraySlice(array[0..<half].reverse()),
      balancedB: ArraySlice(array[half..<array.endIndex])
    )
  }
}

extension ContiguousDequeSlice : ArrayLiteralConvertible {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init(array: Array(seq))
  }
  public init(arrayLiteral: Element...) {
    self.init(array: arrayLiteral)
  }
}

// MARK: Check

extension ContiguousDequeSlice {
  internal var balance: Balance {
    let (f, b) = (front.count, back.count)
    if f == 0 {
      if b > 1 {
        return .FrontEmpty
      }
    } else if b == 0 {
      if f > 1 {
        return .BackEmpty
      }
    }
    return .Balanced
  }
}

extension ContiguousDequeSlice {
  
  /**
  This is the function that maintains an invariant: If either queue has more than one
  element, the other must not be empty. This ensures that all operations can be performed
  efficiently. It is caried out whenever a mutating funciton which may break the invariant
  is performed.
  */
  
  internal mutating func check() {
    switch balance {
    case .FrontEmpty:
      front.reserveCapacity(back.count - 1)
      let newBack = back.removeLast()
      front = ArraySlice(back.reverse())
      back = [newBack]
    case .BackEmpty:
      back.reserveCapacity(front.count - 1)
      let newFront = front.removeLast()
      back = ArraySlice(front.reverse())
      front = [newFront]
    case .Balanced: return
    }
  }
}

// MARK: SequenceType

public struct ContiguousDequeSliceGenerator<Element> : GeneratorType, SequenceType {
  private var fGen: IndexingGenerator<ReverseRandomAccessCollection<ArraySlice<Element>>>?
  private var sGen: IndexingGenerator<ArraySlice<Element>>
  mutating public func next() -> Element? {
    if fGen == nil { return sGen.next() }
    return fGen!.next() ?? {
      fGen = nil
      return sGen.next()
      }()
  }
}

extension ContiguousDequeSlice : SequenceType {
  
  public func generate() -> ContiguousDequeSliceGenerator<Element> {
    return ContiguousDequeSliceGenerator(fGen: front.reverse().generate(), sGen: back.generate())
  }
  
  public func underestimateCount() -> Int {
    return front.underestimateCount() + back.underestimateCount()
  }
  
  public func dropFirst() -> ContiguousDequeSlice<Element> {
    if front.isEmpty { return ContiguousDequeSlice() }
    return ContiguousDequeSlice(front.dropLast(), ArraySlice(back))
  }
  
  public func dropFirst(n: Int) -> ContiguousDequeSlice<Element> {
    if n < front.endIndex {
      return ContiguousDequeSlice(
        balancedF: front.dropLast(n),
        balancedB: ArraySlice(back)
      )
    } else {
      let i = n - front.endIndex
      if i >= back.endIndex { return [] }
      return ContiguousDequeSlice(
        balancedF: [back[i]],
        balancedB: back.dropFirst(i.successor())
      )
    }
  }
  
  public func dropLast() -> ContiguousDequeSlice<Element> {
    if back.isEmpty { return ContiguousDequeSlice() }
    return ContiguousDequeSlice(ArraySlice(front), back.dropLast())
  }
  
  public func dropLast(n: Int) -> ContiguousDequeSlice<Element> {
    if n < back.endIndex {
      return ContiguousDequeSlice(
        balancedF: ArraySlice(front),
        balancedB: back.dropLast(n)
      )
    } else {
      let i = n - back.endIndex
      if i >= front.endIndex { return [] }
      return ContiguousDequeSlice(
        balancedF: front.dropFirst(i.successor()),
        balancedB: [front[i]]
      )
    }
  }
  
  public func prefix(maxLength: Int) -> ContiguousDequeSlice<Element> {
    if maxLength == 0 { return [] }
    if maxLength <= front.endIndex {
      let i = front.endIndex - maxLength
      return ContiguousDequeSlice(
        balancedF: front.suffix(maxLength.predecessor()),
        balancedB: [front[i]]
      )
    } else {
      let i = maxLength - front.endIndex
      return ContiguousDequeSlice(
        balancedF: ArraySlice(front),
        balancedB: back.prefix(i)
      )
    }
  }
  
  public func suffix(maxLength: Int) -> ContiguousDequeSlice<Element> {
    if maxLength == 0 { return [] }
    if maxLength <= back.endIndex {
      return ContiguousDequeSlice(
        balancedF: [back[back.endIndex - maxLength]],
        balancedB: back.suffix(maxLength.predecessor())
      )
    } else {
      return ContiguousDequeSlice(
        balancedF: front.prefix(maxLength - back.endIndex),
        balancedB: ArraySlice(back)
      )
    }
  }
  public func split(
    maxSplit: Int,
    allowEmptySlices: Bool,
    @noescape isSeparator: Element -> Bool
    ) -> [ContiguousDequeSlice<Element>] {
      var result: [ContiguousDequeSlice<Element>] = []
      var curent:  ContiguousDequeSlice<Element>  = []
      curent.front.reserveCapacity(1)
      curent.back.reserveCapacity(maxSplit - 1)
      for element in self {
        if isSeparator(element) {
          if !curent.isEmpty || allowEmptySlices {
            result.append(curent)
            curent.removeAll(true)
          }
        } else {
          curent.append(element)
        }
      }
      if !curent.isEmpty || allowEmptySlices {
        result.append(curent)
      }
      return result
  }
}

// MARK: Indexable

extension ContiguousDequeSlice : Indexable {
  public var startIndex: Int { return 0 }
  public var endIndex: Int { return front.endIndex + back.endIndex }
  public subscript(idx: Int) -> Element {
    get {
      return idx < front.endIndex ?
        front[front.endIndex.predecessor() - idx] :
        back[idx - front.endIndex]
    } set {
      idx < front.endIndex ?
        (front[front.endIndex.predecessor() - idx] = newValue) :
        (back[idx - front.endIndex] = newValue)
    }
  }
}

// MARK: CollectionType

extension ContiguousDequeSlice : MutableSliceable {
  public var count: Int {
    return endIndex
  }
  public var first: Element? {
    return front.last ?? back.first
  }
  public var last: Element? {
    return back.last ?? front.first
  }
  public var isEmpty: Bool {
    return front.isEmpty && back.isEmpty
  }
  public mutating func popFirst() -> Element? {
    defer { check() }
    return front.popLast() ?? back.popLast()
  }
  public mutating func popLast() -> Element? {
    defer { check() }
    return back.popLast() ?? front.popLast()
  }
  public func prefixUpTo(end: Int) -> ContiguousDequeSlice<Element> {
    return prefix(end)
  }
  public func prefixThrough(position: Int) -> ContiguousDequeSlice<Element> {
    return prefix(position.successor())
  }
  public func reverse() -> ContiguousDequeSlice<Element> {
    return ContiguousDequeSlice(balancedF: back, balancedB: front)
  }
  public func suffixFrom(start: Int) -> ContiguousDequeSlice<Element> {
    return dropFirst(start)
  }
  public subscript(idxs: Range<Int>) -> ContiguousDequeSlice<Element> {
    get {
      if idxs.startIndex == idxs.endIndex { return [] }
      switch (idxs.startIndex < front.endIndex, idxs.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - idxs.endIndex
        let end   = front.endIndex - idxs.startIndex
        return ContiguousDequeSlice(
          balancedF: front[start.successor()..<end],
          balancedB: [front[start]]
        )
      case (true, false):
        let frontTo = front.endIndex - idxs.startIndex
        let backTo  = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice(
          balancedF: front[0 ..< frontTo],
          balancedB: back [0 ..< backTo]
        )
      case (false, false):
        let start = idxs.startIndex - front.endIndex
        let end   = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice(
          balancedF: [back[start]],
          balancedB: back[start.successor() ..< end]
        )
      case (false, true): return []
      }
    } set {
      for (index, value) in zip(idxs, newValue) {
        self[index] = value
      }
    }
  }
}

// MARK: RangeReplaceableCollectionType

extension ContiguousDequeSlice : RangeReplaceableCollectionType {
  public init() {
    (front, back) = ([], [])
  }
  public mutating func append(with: Element) {
    back.append(with)
    check()
  }
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    back.extend(with)
    check()
  }
  public mutating func insert(newElement: Element, atIndex i: Int) {
    i < front.endIndex ?
      front.insert(newElement, atIndex: front.endIndex - i) :
      back .insert(newElement, atIndex: i - front.endIndex)
    check()
  }
  public mutating func prepend(with: Element) {
    front.append(with)
    check()
  }
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    front.extend(with.reverse())
    check()
  }
  public mutating func removeAll(keepCapacity: Bool = false) {
    front.removeAll(keepCapacity: keepCapacity)
    back .removeAll(keepCapacity: keepCapacity)
  }
  public mutating func removeAtIndex(i: Int) -> Element {
    defer { check() }
    return i < front.endIndex ?
      front.removeAtIndex(front.endIndex.predecessor() - i) :
      back .removeAtIndex(i - front.endIndex)
  }
  public mutating func removeFirst() -> Element {
    if front.isEmpty { return back.removeLast() }
    defer { check() }
    return front.removeLast()
  }
  public mutating func removeFirst(n: Int) {
    if n < front.endIndex {
      front.removeRange((front.endIndex - n)..<front.endIndex)
    } else {
      let i = n - front.endIndex
      if i < back.endIndex {
        self = ContiguousDequeSlice(
          balancedF: [back[i]],
          balancedB: ArraySlice(back.dropFirst(i.successor()))
        )
      } else {
        removeAll()
      }
    }
  }
  public mutating func removeLast() -> Element {
    if back.isEmpty { return front.removeLast() }
    defer { check() }
    return back.removeLast()
  }
  public mutating func removeLast(n: Int) {
    if n < back.endIndex {
      back.removeRange((back.endIndex - n)..<back.endIndex)
    } else {
      let i = n - back.endIndex
      if i < front.endIndex {
        self = ContiguousDequeSlice(
          balancedF: ArraySlice(front.dropFirst(i.successor())),
          balancedB: [front[i]]
        )
      } else {
        removeAll()
      }
    }
  }
  public mutating func removeRange(subRange: Range<Int>) {
    if subRange.startIndex == subRange.endIndex { return }
    defer { check() }
    switch (subRange.startIndex < front.endIndex, subRange.endIndex <= front.endIndex) {
    case (true, true):
      let start = front.endIndex - subRange.endIndex
      let end   = front.endIndex - subRange.startIndex
      front.removeRange(start..<end)
    case (true, false):
      let frontTo = front.endIndex - subRange.startIndex
      let backTo  = subRange.endIndex - front.endIndex
      front.removeRange(front.startIndex..<frontTo)
      back.removeRange(back.startIndex..<backTo)
    case (false, false):
      let start = subRange.startIndex - front.endIndex
      let end   = subRange.endIndex - front.endIndex
      back.removeRange(start..<end)
    case (false, true): return
    }
  }
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<Int>, with newElements: C) {
      defer { check() }
      switch (subRange.startIndex < front.endIndex, subRange.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - subRange.endIndex
        let end   = front.endIndex - subRange.startIndex
        front.replaceRange(start..<end, with: newElements.reverse())
      case (true, false):
        let frontTo = front.endIndex - subRange.startIndex
        let backTo  = subRange.endIndex - front.endIndex
        front.removeRange(front.startIndex..<frontTo)
        back.replaceRange(back.startIndex..<backTo, with: newElements)
      case (false, false):
        let start = subRange.startIndex - front.endIndex
        let end   = subRange.endIndex - front.endIndex
        back.replaceRange(start..<end, with: newElements)
      case (false, true):
        back.replaceRange(0..<0, with: newElements)
      }
  }
  mutating public func reserveCapacity(n: Int) {
    let half = n / 2
    front.reserveCapacity(half)
    back.reserveCapacity(n - half)
  }
}
