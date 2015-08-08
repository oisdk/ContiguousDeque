// MARK: Definition

public struct ContiguousListSlice<Element> {
  internal var contents: ArraySlice<Element>
}

extension ContiguousListSlice : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "[" + ", ".join(map {String(reflecting: $0)}) + "]"
  }
}

// MARK: Init

extension ContiguousListSlice : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    contents = ArraySlice(arrayLiteral.reverse())
  }
  public init(_ array: [Element]) {
    contents = ArraySlice(array.reverse())
  }
  public init<S: SequenceType where S.Generator.Element == Element>(_ seq: S) {
    contents = ArraySlice(seq.reverse())
  }
  public init() {
    contents = []
  }
  internal init(alreadyReversed: ArraySlice<Element>) {
    contents = alreadyReversed
  }
}

// MARK: Indexable

extension ContiguousListSlice : Indexable {
  public var endIndex: ContiguousListIndex {
    return ContiguousListIndex(contents.startIndex.predecessor())
  }
  public var startIndex: ContiguousListIndex {
    return ContiguousListIndex(contents.endIndex.predecessor())
  }
  public subscript(idx: ContiguousListIndex) -> Element {
    get { return contents[idx.val] }
    set { contents[idx.val] = newValue }
  }
}

// MARK: SequenceType

extension ContiguousListSlice : SequenceType {
  
  public typealias SubSequence = ContiguousListSlice<Element>
  
  public func dropFirst() -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropLast())
  }
  public func dropLast() -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropFirst())
  }
  public func dropFirst(n: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropLast(n))
  }
  public func dropLast(n: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropFirst(n))
  }
  public func generate() -> IndexingGenerator<ContiguousListSlice> {
    return IndexingGenerator(self)
  }
  public func prefix(maxLength: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffix(maxLength))
  }
  public func suffix(maxLength: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefix(maxLength))
  }
  public func split(
    maxSplit: Int,
    allowEmptySlices: Bool,
    @noescape isSeparator: Element -> Bool
    ) -> [ContiguousListSlice<Element>] {
      var result: [ContiguousListSlice<Element>] = []
      var curent:  ContiguousListSlice<Element>  = []
      curent.reserveCapacity(maxSplit)
      for element in self {
        if isSeparator(element) {
          if !curent.isEmpty || allowEmptySlices {
            result.append(curent)
            curent.removeAll(keepCapacity: true)
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
  public func underestimateCount() -> Int {
    return contents.underestimateCount()
  }
  public func reverse() -> ArraySlice<Element> {
    return contents
  }
}

// MARK: CollectionType

extension ContiguousListSlice : CollectionType {
  public var count: Int {
    return contents.count
  }
  public var first: Element? {
    return contents.last
  }
  public var last: Element? {
    return contents.first
  }
  public var isEmpty: Bool {
    return contents.isEmpty
  }
  public mutating func popFirst() -> Element? {
    return contents.popLast()
  }
  public mutating func popLast() -> Element? {
    return contents.isEmpty ? nil : contents.removeFirst()
  }
  public func prefixThrough(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return prefixUpTo(i.successor())
  }
  public func prefixUpTo(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffixFrom(i.val.successor()))
  }
  public func prefixThrough(i: Int) -> ContiguousListSlice<Element> {
    return prefixUpTo(i.successor())
  }
  public func prefixUpTo(i: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffix(i))
  }
  public mutating func removeFirst() -> Element {
    return contents.removeLast()
  }
  public mutating func removeLast() -> Element {
    return contents.removeFirst()
  }
  public func suffixFrom(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefixThrough(i.val))
  }
  public func suffixFrom(i: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefixUpTo(contents.endIndex - i))
  }
  public subscript(idxs: Range<ContiguousListIndex>) -> ContiguousListSlice<Element> {
    get {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      return ContiguousListSlice(alreadyReversed: contents[start..<end])
    } set {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      contents[start..<end] = newValue.contents
    }
  }
  public subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
  public subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
    get {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      return ContiguousListSlice(alreadyReversed: contents[str..<end] )
    } set {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      contents[str..<end] = newValue.contents
    }
  }
}

// MARK: RangeReplaceableCollectionType

extension ContiguousListSlice : RangeReplaceableCollectionType {
  public mutating func append(with: Element) {
    contents.insert(with, atIndex: contents.startIndex)
  }
  public mutating func prepend(with: Element) {
    contents.append(with)
  }
  public mutating func extend<S : CollectionType where S.Generator.Element == Element>(newElements: S) {
    contents.replaceRange(contents.startIndex..<contents.startIndex, with: newElements.reverse())
  }
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    extend(Array(newElements))
  }
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    contents.extend(newElements.reverse())
  }
  public mutating func insert(newElement: Element, atIndex i: ContiguousListIndex) {
    contents.insert(newElement, atIndex: i.val.successor())
  }
  public mutating func insert(newElement: Element, atIndex i: Int) {
    print(debugDescription)
    print(i)
    contents.insert(newElement, atIndex: contents.endIndex - i)
  }
  public mutating func removeAll(keepCapacity keepCapacity: Bool) {
    contents.removeAll(keepCapacity: keepCapacity)
  }
  public mutating func removeAtIndex(index: ContiguousListIndex) -> Element {
    return contents.removeAtIndex(index.val)
  }
  public mutating func removeAtIndex(index: Int) -> Element {
    return contents.removeAtIndex(contents.endIndex.predecessor() - index)
  }
  public mutating func removeFirst(n: Int) {
    contents.removeRange((contents.endIndex - n)..<contents.endIndex)
  }
  public mutating func removeLast(n: Int) {
    contents.removeFirst(n)
  }
  public mutating func removeRange(subRange: Range<ContiguousListIndex>) {
    let str = subRange.endIndex.val.successor()
    let end   = subRange.startIndex.val.successor()
    contents.removeRange(str..<end)
  }
  public mutating func removeRange(subRange: Range<Int>) {
    let str = contents.endIndex - subRange.endIndex
    let end = contents.endIndex - subRange.startIndex
    contents.removeRange(str..<end)
  }
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<ContiguousListIndex>, with newElements: C) {
      let str = subRange.endIndex.val.successor()
      let end = subRange.startIndex.val.successor()
      contents.replaceRange((str..<end), with: newElements.reverse())
  }
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<Int>, with newElements: C) {
      let str = contents.endIndex - subRange.endIndex
      let end = contents.endIndex - subRange.startIndex
      contents.replaceRange((str..<end), with: newElements.reverse())
  }
  public mutating func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}
