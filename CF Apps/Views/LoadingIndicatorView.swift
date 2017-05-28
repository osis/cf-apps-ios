import Foundation
import UIKit

class LoadingIndicatorView: UIActivityIndicatorView {
    required init() {
        super.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.startAnimating()
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
