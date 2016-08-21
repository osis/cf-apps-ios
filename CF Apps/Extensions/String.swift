import Foundation

extension String {
    func bumpLastChar() -> String {
        var s = String(self)
        let scalar = self.unicodeScalars.last!
        
        var v = scalar.value
        if (v != 0x20) {
            v += 1
        }
        
        s.removeAtIndex(s.endIndex.predecessor())
        s.append(UnicodeScalar(v))
        
        return s
    }
}