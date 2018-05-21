import Foundation

extension String {
    func isValidURL() -> Bool {
        let regex = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regex])
        
        return predicate.evaluate(with: self)
    }
}
