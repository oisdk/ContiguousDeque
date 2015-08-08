import XCTest
import Foundation
@testable import ContiguousDeque

internal func makeListTuple<S : SequenceType>(from: S) -> (S, ContiguousList<S.Generator.Element>) {
  return (from, ContiguousList(from))
}
internal func makeListTuple<T>(from: [T]) -> ([T], ContiguousList<T>) {
  return (from, ContiguousList(from))
}

class ContiguousListTests: XCTestCase {
  
  func testDebugDesciption() {
    
    let expectation = "[1, 2, 3, 4, 5]"
    
    let reality = ContiguousList([1, 2, 3, 4, 5]).debugDescription
    
    XCTAssert(expectation == reality)
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [2, 3, 4, 5, 6]
    
    let reality: ContiguousList = [2, 3, 4, 5, 6]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testArrayInit() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testDropFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .map{ (ar, de) in (ar.dropFirst(), de.dropFirst()) }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testDropFirstN() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.dropFirst($0), de.dropFirst($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testDropLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .map { ($0.0.dropLast(), $0.1.dropLast()) }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testDropLastN() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.dropLast($0), de.dropLast($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testPrefix() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.prefix($0), de.prefix($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testPrefixUpTo() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in ar.indices.map { (ar.prefixUpTo($0), de.prefixUpTo($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testPrefixUpToNative() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in zip(ar.indices, de.indices).map { (a, d) in (ar.prefixUpTo(a), de.prefixUpTo(d)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testPrefixThrough() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        ar.indices
          .dropLast()
          .map { (ar.prefixThrough($0), de.prefixThrough($0)) }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
    }
  }
  
  func testPrefixThroughNative() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        zip(ar.indices, de.indices)
          .dropLast()
          .map { (a, d) in (ar.prefixThrough(a), de.prefixThrough(d)) }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
    }
  }
  
  func testSuffix() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.suffix($0), de.suffix($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testSuffixFrom() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in ar.indices.map { (ar.suffixFrom($0), de.suffixFrom($0)) } }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testSuffixFromNative() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in zip(ar.indices, de.indices).map {(a, d) in (ar.suffixFrom(a), de.suffixFrom(d))}}
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testSplit() {
    
    let divr = Int(arc4random_uniform(10)) + 2
    
    let splitFunc = { $0 % divr == 0 }
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        [true, false].flatMap { empties in
          (0...10).flatMap { zip(
            ar.split($0, allowEmptySlices: empties, isSeparator: splitFunc),
            de.split($0, allowEmptySlices: empties, isSeparator: splitFunc))
          }
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testIndexing() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        ar.indices
          .forEach { i in
            XCTAssert(ar[i] == de[i])
            var (array, list) = (ar, de)
            let n = Int(arc4random_uniform(10000))
            (array[i], list[i]) = (n, n)
            XCTAssert(array.elementsEqual(list))
        }
    }
  }
  
  func testNativeIndexing() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        zip(ar.indices, de.indices)
          .forEach { (ia, id) in
            XCTAssert(ar[ia] == de[id])
            var (array, list) = (ar, de)
            let n = Int(arc4random_uniform(10000))
            (array[ia], list[id]) = (n, n)
            XCTAssert(array.elementsEqual(list))
        }
    }
  }
  
  func testCount() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.count == de.count)
    }
  }
  
  func testFirst() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.first == de.first)
    }
  }
  
  func testLast() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.last == de.last)
    }
  }
  
  func testIsEmpty() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.isEmpty == de.isEmpty)
    }
  }
  
  func testPopLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (var ar, var de) in
        while let deqEl = de.popLast() {
          XCTAssert(ar.popLast() == deqEl)
          XCTAssert(ar.elementsEqual(de))
        }
    }
  }
  
  func testPopFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (var ar, var de) in
        while let deqEl = de.popFirst() {
          XCTAssert(ar.popFirst() == deqEl)
          XCTAssert(ar.elementsEqual(de))
        }
    }
  }
  
  func testReverse() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .map { (ar, de) in (ar.reverse(), de.reverse()) }
      .forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
    
  }
  
  func testIndsRange() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        ar.indices.flatMap { start in
          (start...ar.endIndex).map { end in
            (ar[start..<end], de[start..<end])
          }
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testIndsRangeNative() {
    
    let tuples = (0...10)
      .map(randomArray)
      .map(makeListTuple)
      
    let toTest = tuples
      .flatMap { (ar, de) in
        zip(ar.indices, de.indices).flatMap { (aStart, dStart) in
          zip(
            (aStart...ar.endIndex),
            (dStart...de.endIndex)
            ).map { (aEnd, dEnd) in
            (ar[aStart..<aEnd], de[dStart..<dEnd])
          }
        }
      }
    
    for (ar, de) in toTest {
      XCTAssert(ar.elementsEqual(de))
    }
  }
  
  func testIndsRangeSet() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var list: ContiguousList<Int> = de
            let replacement = randomArray(end - start)
            array[start..<end] = ArraySlice(replacement)
            list[start..<end] = ContiguousListSlice(replacement)
            XCTAssert(array.elementsEqual(list))
          }
        }
    }
  }
  
  func testIndsRangeSetNative() {
    
    let tuples = (0...10)
      .map(randomArray)
      .map(makeListTuple)
    
    tuples
      .flatMap { (ar, de) in
        zip(ar.indices, de.indices).flatMap { (aStart, dStart) in
          zip(
            (aStart...ar.endIndex),
            (dStart...de.endIndex)
            ).forEach { (aEnd, dEnd) in
              var array: [Int] = ar
              var list: ContiguousList<Int> = de
              let replacement = randomArray(aEnd - aStart)
              array[aStart..<aEnd] = ArraySlice(replacement)
              list[dStart..<dEnd] = ContiguousListSlice(replacement)
              XCTAssert(array.elementsEqual(list))
          }
        }
    }
    
  }
  
  func testEmptyInit() {
    
    XCTAssert(ContiguousList<Int>().isEmpty)
    
  }
  
  func testAppend() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        (0...10).map { (n: Int) -> ([Int], ContiguousList<Int>) in
          var (array, list) = (ar, de)
          for _ in 0..<n {
            let x = Int(arc4random_uniform(UInt32.max))
            array.append(x)
            list.append(x)
          }
          return (array, list)
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testExtend() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar, de) in
        (0...10).map { (n: Int) -> ([Int], ContiguousList<Int>) in
          var (array, list) = (ar, de)
          for _ in 0..<n {
            let x = randomArray(Int(arc4random_uniform(8)))
            array.extend(x)
            list.extend(x)
          }
          return (array, list)
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testInsert() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        (0...ar.endIndex).map { (i: Int) -> ([Int], ContiguousList<Int>) in
          var array: [Int] = ar
          var list: ContiguousList<Int> = de
          let x = Int(arc4random_uniform(UInt32.max))
          array.insert(x, atIndex: i)
          list.insert(x, atIndex: i)
          return (array, list)
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testInsertNative() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        zip(
          (0...ar.endIndex),
          (de.startIndex...de.endIndex)
          ).map { (i: Int, d: ContiguousListIndex) -> ([Int], ContiguousList<Int>) in
          var array: [Int] = ar
          var list: ContiguousList<Int> = de
          let x = Int(arc4random_uniform(UInt32.max))
          array.insert(x, atIndex: i)
          list.insert(x, atIndex: d)
          return (array, list)
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testPrepend() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        (0...10).map { (n: Int) -> ([Int], ContiguousList<Int>) in
          var (array, list) = (ar, de)
          for _ in 0..<n {
            let x = Int(arc4random_uniform(UInt32.max))
            array = [x] + array
            list.prepend(x)
          }
          return (array, list)
        }
      }.forEach { (ar: [Int], de: ContiguousList<Int>) in
        XCTAssert(ar.elementsEqual(de))
    }
  }
  
  func testPrextend() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        (0...10).map { i in
          var (array, list) = (ar, de)
          let x = randomArray(i)
          array = x + array
          list.prextend(x)
          return (array, list)
        }
      }.forEach { (ar: [Int], de: ContiguousList<Int>) in
        XCTAssert(ar.elementsEqual(de))
    }
  }
  
  func testRemoveAll() {
    var list = ContiguousList(randomArray(8))
    list.removeAll()
    XCTAssert(list.isEmpty)
  }
  
  func testRemove() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        ar.indices
          .forEach { i in
            var (array, list) = (ar, de)
            XCTAssert(array.removeAtIndex(i) == list.removeAtIndex(i))
            XCTAssert(array.elementsEqual(list))
        }
    }
  }
  
  func testRemoveNative() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        zip(ar.indices, de.indices)
          .forEach { (i, d) in
            var (array, list) = (ar, de)
            XCTAssert(array.removeAtIndex(i) == list.removeAtIndex(d))
            XCTAssert(array.elementsEqual(list))
        }
    }
  }
  
  func testRemoveFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (var ar, var de) in
        while !de.isEmpty {
          XCTAssert(ar.removeFirst() == de.removeFirst())
          XCTAssert(ar.elementsEqual(de))
        }
    }
  }
  
  func testRemoveLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (var ar, var de) in
        while !de.isEmpty {
          XCTAssert(ar.removeLast() == de.removeLast())
          XCTAssert(ar.elementsEqual(de))
        }
    }
  }
  
  func testRemoveFirstN() {
    
    (1...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        (0...ar.endIndex).map { (n: Int) -> ([Int], ContiguousList<Int>) in
          var (array, list) = (ar, de)
          array.removeFirst(n)
          list.removeFirst(n)
          return (array, list)
        }
      }.forEach { (ar, de) in XCTAssert(ar.elementsEqual(de)) }
  }
  
  func testRemoveLastN() {
    
    (1...10)
      .map(randomArray)
      .map(makeListTuple)
      .flatMap { (ar: [Int], de: ContiguousList<Int>) in
        (0...ar.endIndex).map { (n: Int) -> ([Int], ContiguousList<Int>) in
          var (array, list) = (ar, de)
          array.removeRange((ar.endIndex - n)..<ar.endIndex)
          list.removeLast(n)
          return (array, list)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de), ar.debugDescription + " != " + de.debugDescription)
    }
  }
  
  func testRemoveRange() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var list: ContiguousList<Int> = de
            array.removeRange(start..<end)
            list.removeRange(start..<end)
            XCTAssert(array.elementsEqual(list), array.debugDescription + " != " + list.debugDescription)
          }
        }
    }
  }
  
  func testRemoveRangeNative() {

    let tuples = (0...10)
      .map(randomArray)
      .map(makeListTuple)
    
    tuples
      .flatMap { (ar, de) in
        zip(ar.indices, de.indices).flatMap { (aStart, dStart) in
          zip(
            (aStart...ar.endIndex),
            (dStart...de.endIndex)
            ).forEach { (aEnd, dEnd) in
              var array: [Int] = ar
              var list: ContiguousList<Int> = de
              array.removeRange(aStart..<aEnd)
              list.removeRange(dStart..<dEnd)
              XCTAssert(array.elementsEqual(list))
          }
        }
    }
  }
  
  func testReplaceRange() {
    (0...10)
      .map(randomArray)
      .map(makeListTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var list: ContiguousList<Int> = de
            let replacement = randomArray(Int(arc4random_uniform(20)))
            array.replaceRange(start..<end, with: replacement)
            list.replaceRange(start..<end, with: replacement)
            XCTAssert(array.elementsEqual(list), array.debugDescription + " != " + list.debugDescription)
          }
        }
    }
  }
  
  func testReplaceRangeNative() {
    
    let tuples = (0...10)
      .map(randomArray)
      .map(makeListTuple)
    
    tuples
      .flatMap { (ar, de) in
        zip(ar.indices, de.indices).flatMap { (aStart, dStart) in
          zip(
            (aStart...ar.endIndex),
            (dStart...de.endIndex)
            ).forEach { (aEnd, dEnd) in
              var array: [Int] = ar
              var list: ContiguousList<Int> = de
              let replacement = randomArray(Int(arc4random_uniform(20)))
              array.replaceRange(aStart..<aEnd, with: replacement)
              list.replaceRange(dStart..<dEnd, with: replacement)
              XCTAssert(array.elementsEqual(list), array.debugDescription + " != " + list.debugDescription)
          }
        }
    }
    
  }
  
  func testReserveCapacity() {
    var d = ContiguousList<Int>()
    d.reserveCapacity(20)
  }

}