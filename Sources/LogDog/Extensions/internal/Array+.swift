extension Array {
    
    subscript(safe range: Range<Int>) -> Array<Element> {
        let r = range.clamped(to: indices)
        return Array(self[r])
    }
}
