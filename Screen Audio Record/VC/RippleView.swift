
import UIKit

class RippleView: UIView {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)   //(touches, with: event)
    for touch: AnyObject in touches {
      let t: UITouch = touch as! UITouch
        let location = t.location(in: self)

      //RIPPLE BORDER
        rippleBorder(location: location, color: UIColor.red)

    }
  }

}
