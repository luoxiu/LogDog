extension Array {
    
    subscript(safe range: Range<Int>) -> Array<Element> {
        let clamped = range.clamped(to: indices)
        return Array(self[clamped])
    }
}
