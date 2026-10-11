public enum UDSCollectionUtilities {
    /// Returns the element at `index`, or `nil` when the index is outside the collection.
    public static func element<C: Collection>(at index: C.Index, in collection: C) -> C.Element? {
        guard collection.indices.contains(index) else { return nil }
        return collection[index]
    }

    /// Returns an element using a zero-based offset, or `nil` for a negative or out-of-range offset.
    public static func element<C: Collection>(atOffset offset: Int, in collection: C) -> C.Element? {
        guard offset >= 0,
              let index = collection.index(collection.startIndex, offsetBy: offset, limitedBy: collection.endIndex),
              index != collection.endIndex else { return nil }
        return collection[index]
    }

    /// Removes `nil` elements while preserving order.
    public static func compacted<Values: Sequence, Element>(_ values: Values) -> [Element]
    where Values.Element == Element? {
        values.compactMap { $0 }
    }
}

public enum UDSValueUtilities {
    /// Constrains a comparable value to a closed range.
    public static func clamped<Value: Comparable>(_ value: Value, to range: ClosedRange<Value>) -> Value {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

public extension Collection where Element: Hashable {
    /// Keeps the first occurrence of each element and preserves input order.
    var udsUnique: [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

public extension Array {
    /// Splits the array into consecutive chunks. Nonpositive sizes return no chunks.
    func udsChunks(ofSize size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map { start in
            Array(self[start..<Swift.min(start + size, count)])
        }
    }
}
