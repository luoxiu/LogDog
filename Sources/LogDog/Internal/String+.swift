import Foundation

extension String {
    
    var basename: String {
        guard let index = lastIndex(of: "/") else {
            return self
        }
        
        let from = self.index(after: index)
        return String(self[from...])
    }
}
