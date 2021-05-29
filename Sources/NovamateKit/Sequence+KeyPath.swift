public extension Sequence {
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted(by: { x, y in
            x[keyPath: keyPath] < y[keyPath: keyPath]
        })
    }

    func filter<Value: Equatable>(by keyPath: KeyPath<Element, Value>, equalTo value: Value) -> [Element] {
        filter { element in
            element[keyPath: keyPath] == value
        }
    }

    func first<Value: Equatable>(where keyPath: KeyPath<Element, Value>, equalTo value: Value) -> Element? {
        first { element in
            element[keyPath: keyPath] == value
        }
    }
}
