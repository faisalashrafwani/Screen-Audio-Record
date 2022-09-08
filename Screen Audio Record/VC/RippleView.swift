
import UIKit

class RippleView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        print("toucher: \(touches)")
        
        for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            let x = t.gestureRecognizers?.first?.numberOfTouches
            if (x == 2) {
                let location = t.location(in: self)
                //RIPPLE BORDER
                rippleBorder(location: location, color: UIColor.darkGray)
            }
            
        }
    }
    
}
