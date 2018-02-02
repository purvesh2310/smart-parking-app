import Foundation
import MapKit

//Custom annotation class
class ParkingLotAnnotation: NSObject, MKAnnotation{
    let title: String?
    let availableSpot: NSNumber
    let totalSpot: NSNumber
    let coordinate: CLLocationCoordinate2D
    let facilityId: NSNumber
    let availableZones: String?
    
    init(title: String, availableSpot: NSNumber, totalSpot:NSNumber, coordinate: CLLocationCoordinate2D, facilityId:NSNumber, availableZones:String) {
        self.title = title
        self.availableSpot = availableSpot
        self.totalSpot  = totalSpot
        self.coordinate = coordinate
        self.facilityId = facilityId
        self.availableZones = availableZones
        
        super.init()
    }
}