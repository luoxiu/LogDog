extension Array {
    
    subscript(safe range: Range<Int>) -> Array<Element> {
        let r = range.clamped(to: self.indices)
        return Array(self[r])
    }
}

