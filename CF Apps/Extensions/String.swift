import Foundation

extension String {
    func isValidURL() -> Bool {
        let regex = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regex])
        
        return predicate.evaluate(with: self)
    }
}
