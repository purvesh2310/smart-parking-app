import UIKit

class ParkingLotCallout: UIView {
  
    @IBOutlet weak var lblParkingLotTitle: UILabel!
    @IBOutlet weak var lblIsAvailable: UILabel!
    @IBOutlet weak var lblSpotsOpen: UILabel!
    @IBOutlet weak var lblZones: UILabel!
    @IBOutlet weak var viewLotButton: UIButton!
    @IBOutlet weak var lblTotalSpots: UILabel!
    @IBOutlet weak var lblFacilityId: UILabel!
    
    
    var parkingLotDic = [String: String]()
    
    let parkingLotNotificationKey = "parkingLotNotificationKey"

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        let view = super.hitTest(viewPoint, withEvent: event)
        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
  
    //Perform post notification when view lot button tap
    @IBAction func btnViewLotTapped(sender: AnyObject) {
        parkingLotDic["title"] = lblParkingLotTitle.text
        parkingLotDic["spots"] = lblSpotsOpen.text
        parkingLotDic["zones"] = lblZones.text
        parkingLotDic["facilityid"] = lblFacilityId.text
        
        NSNotificationCenter.defaultCenter().postNotificationName(parkingLotNotificationKey, object: parkingLotDic)
    }

}
