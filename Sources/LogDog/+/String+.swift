import Foundation

extension String {
    
    struct Path {
        let raw: String
        
        var filename: String {
            NSString(string: raw).lastPathComponent
        }
        
        var filenameWithoutExtension: String {
            NSString(string: filename).deletingPathExtension
        }
    }
    
    var asPath: Path {
        Path(raw: self)
    }
}
