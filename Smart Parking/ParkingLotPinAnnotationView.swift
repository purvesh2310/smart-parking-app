import UIKit
import MapKit

class ParkingLotPinAnnotationView: MKPinAnnotationView {
    
    private var calloutView:ParkingLotCallout?
    private var hitOutside:Bool = true
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    // custom callout will be display when tap on pin
    override func setSelected(selected: Bool, animated: Bool) {
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)

        if (calloutView == nil) {
            calloutView = NSBundle.mainBundle().loadNibNamed("Callout", owner: nil, options: nil)[0] as? ParkingLotCallout
            
            let parkingLotAnnotation: ParkingLotAnnotation = self.annotation as! ParkingLotAnnotation
            let availableSpots = parkingLotAnnotation.availableSpot as Int
            let isAvailable:String!
            if (availableSpots > 0) {
                isAvailable = "Available"
            } else {
                isAvailable = "Unavailable"
            }
            
            calloutView?.lblParkingLotTitle.text = parkingLotAnnotation.title
            calloutView?.lblIsAvailable.text = isAvailable
            calloutView?.lblFacilityId.text = String(parkingLotAnnotation.facilityId)
            calloutView?.lblSpotsOpen.text = String(availableSpots)
            calloutView?.lblTotalSpots.text = "/" + String(parkingLotAnnotation.totalSpot)
            calloutView?.lblZones.text = String(parkingLotAnnotation.availableZones!)
            
        }
        
        if (self.selected && !calloutViewAdded) {
            addSubview(calloutView!)
            calloutView!.center = CGPointMake(10, -calloutView!.frame.size.height / 2.0)
        }
        
        if (!self.selected) {
            calloutView?.removeFromSuperview()
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        
        if let callout = calloutView {
            if (hitView == nil && self.selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        
        hitOutside = hitView == nil
        
        return hitView;
    }
}
