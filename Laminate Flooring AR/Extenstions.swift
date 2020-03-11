import Foundation
import UIKit

extension UIButton {
    
    func bounceAnimation() {
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}


extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}



