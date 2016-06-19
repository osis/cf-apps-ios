import Foundation
import UIKit

class LoadingIndicatorView: UIActivityIndicatorView {
    required init() {
        super.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.startAnimating()
        self.frame = CGRectMake(0, 0, 320, 44)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}