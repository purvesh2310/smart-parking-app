import Foundation


class Facility{
    
      // MARK: Properties
    var clientId:NSNumber
    var facilityId:NSNumber
    var facilityTypeId:NSNumber
    var latitude:Double?
    var longitude:Double?
    var name:String?
    var numberOfEmptySpots:NSNumber
    var totalNumberOfSpots:NSNumber
    var layoutImageUrl:String

    
    // MARK: Initialization
    
    init?(facilityId:NSNumber, clientId:NSNumber, facilityTypeId:NSNumber,latitude:Double, longitude:Double, name:String, numberOfEmptySpots:NSNumber, totalNumberOfSpots:NSNumber, layoutImageUrl:String){
        
        self.facilityId = facilityId
        self.clientId = clientId
        self.facilityTypeId = facilityTypeId
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.numberOfEmptySpots = numberOfEmptySpots
        self.totalNumberOfSpots = totalNumberOfSpots
        self.layoutImageUrl = layoutImageUrl
    }
    
    
}
