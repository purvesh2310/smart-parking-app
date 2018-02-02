import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GIDSignInDelegate {
    
    private let reuseIdentifier = "ParkingLotPin"
    let parkingLotNotificationKey = "parkingLotNotificationKey"

    let locationManager = CLLocationManager()
    var session:LRSession?
    var serverURL: String?
    let regionRadius: CLLocationDistance = 150000
    var parkingLotDic = [String: AnyObject]()
    var usersObject:NSObject?
    var arrayOfParkingLot: [ParkingLotAnnotation] = []
    var currentLocationLatitude:CLLocationDegrees?
    var currentLocationLongitude:CLLocationDegrees?
    var socialLoginHelper = SocialLoginHelper()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initLocationManager()
        mapView.delegate = self
        
        GIDSignIn.sharedInstance().delegate = self
        
        let navigationTitleView = AppUtil.setTitleInNavigationBar(150, titleTextViewWidth: 180, titleText: "Nearby facilities", iconImgName: "location-white-icon")
        
        navigationItem.titleView = navigationTitleView
        
        serverURL = AppHelper.getServerURL()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "performSegue:", name: parkingLotNotificationKey, object: nil)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let statusBarView = AppUtil.getStatusBarView(-20.0)
        self.navigationController?.navigationBar.addSubview(statusBarView)
        
        if (locationManager.location == nil) {
            let defaultLocation:NSDictionary = AppHelper.getDefaultLocation()
            
            currentLocationLatitude = CLLocationDegrees((defaultLocation["defaultLatitude"])!.floatValue)
            currentLocationLongitude = CLLocationDegrees((defaultLocation["defaultLongitude"])!.floatValue)
            showParkingLotAnnotationOnMap(currentLocationLatitude!, currentLongitude:currentLocationLongitude!)
        }
        
        if socialLoginHelper.checkForFacebookAccessTokenValidity() != true {
            performSegueWithIdentifier("goBacktoSignIn", sender: self)
            
        }
}

    func showParkingLotAnnotationOnMap(currentLatitude:CLLocationDegrees,currentLongitude:CLLocationDegrees) {
        do {
            session = LRSession(server: serverURL)
            let facilityService:LRFacilityService_v62 = LRFacilityService_v62(session: session)
            var facilityListData : AnyObject?
            
            facilityListData = try facilityService.getNearestFacilitiesWithLatitude(currentLatitude, longitude: currentLongitude, limit: 10)
            if(facilityListData != nil) {
            
                
                for facility in facilityListData as! [Dictionary<String, AnyObject>] {
                    
                    let facilityId = facility["facilityId"] as! NSNumber
                    let latitude = facility["latitude"] as! Double
                    let longitude = facility["longitude"] as! Double
                    let name = facility["name"] as! String
                    let totalNumberOfSpots = facility["totalNumberOfSpots"] as! NSNumber
                    let numberOfEmptySpots = facility["numberOfEmptySpots"] as! NSNumber
                    let fId = facilityId.longLongValue

                    let zoneData:NSObject = try facilityService.getFacilityZonesWithFacilityId(fId)
                    let zoneDataAsArray:NSArray = zoneData as! [Dictionary<String, AnyObject>]
                    
                    var availableZones:String! = ""
                    for (var counter = 0; counter<zoneDataAsArray.count; counter++) {
                        let zone = zoneDataAsArray[counter]
                        let zoneName = zone["name"] as! String
                        
                        availableZones = availableZones + zoneName
                        if counter != zoneDataAsArray.count - 1 {
                            availableZones = availableZones + ","
                        }
                    }

                    let parkingLot = ParkingLotAnnotation(title: name, availableSpot: numberOfEmptySpots, totalSpot: totalNumberOfSpots,
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),facilityId: facilityId, availableZones:availableZones)
                    
                    arrayOfParkingLot.append(parkingLot)
                }
                self.mapView.showAnnotations(arrayOfParkingLot, animated: true)
            } else {
                AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again.")
            }

        } catch let error as NSError {
            NSLog("\(error)")
            switch error.code {
            case -1009:
                AppUtil.showAlertWithMessage("Error", msg: "The Internet connection appears to be offline.")
            case -1004:
                AppUtil.showAlertWithMessage("Error", msg: "Could not connect to the server.")
            default:
                AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again.")
            }
        }
        
        setInitialRegion()
    } // End of showParkingLotAnnotationOnMap

    // Location Manager helper stuff
    func initLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationCoord=annotation.coordinate;
        let currentLocationCoord=locationManager.location?.coordinate;

            if annotationCoord.longitude == currentLocationCoord?.longitude && annotationCoord.latitude == currentLocationCoord?.latitude
            {
                let pin = mapView.dequeueReusableAnnotationViewWithIdentifier("str")
                return pin
            }
            
            let pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) ?? ParkingLotPinAnnotationView(annotation: annotation, reuseIdentifier:reuseIdentifier)
            
            pin.canShowCallout = false
        
            return pin
            
    } // End of viewForAnnotation

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let mapPin = view as? ParkingLotPinAnnotationView {
            updatePinPosition(mapPin)
        }
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let mapPin = view as? ParkingLotPinAnnotationView {
            if mapPin.preventDeselection {
                mapView.selectAnnotation(view.annotation!, animated: false)
            }
        }
    }

    // Making callout view in center of the screen
    func updatePinPosition(pin:ParkingLotPinAnnotationView) {
        
        let defaultShift:CGFloat = 50
        let pinPosition = CGPointMake(pin.frame.midX, pin.frame.maxY)
        let y = pinPosition.y - defaultShift
        let controlPoint = CGPointMake(pinPosition.x, y)
        let controlPointCoordinate = mapView.convertPoint(controlPoint, toCoordinateFromView: mapView)
        mapView.setCenterCoordinate(controlPointCoordinate, animated: true)
    }
    
    func performSegue(notification: NSNotification) {
        
        let parkingLotDict = notification.object as! NSDictionary
        self.performSegueWithIdentifier("sendToFacilityViewSummary", sender: parkingLotDict)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        currentLocationLatitude = location?.coordinate.latitude
        currentLocationLongitude = location?.coordinate.longitude
        
        showParkingLotAnnotationOnMap(currentLocationLatitude!, currentLongitude: currentLocationLongitude!)
        self.locationManager.stopUpdatingLocation()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "sendToFacilityViewSummary" {
            let parkingLotDict: NSDictionary = sender as! NSDictionary
            let facilityViewSummaryController = segue.destinationViewController as! FacilityViewSummaryViewController
            facilityViewSummaryController.parkingLotDic = parkingLotDict as! [String : String]
            facilityViewSummaryController.session = session
        }
    }
    
    // Setting initial region for Map
    func setInitialRegion() {
        let center = CLLocationCoordinate2D(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)
        let region = MKCoordinateRegionMakeWithDistance(center,regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(region, animated: true)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Delegate method for Google to refresh the Access Token after silent login
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error != nil {
            NSLog("\(error)")
        } else {
            GIDSignIn.sharedInstance().currentUser.authentication.refreshTokensWithHandler({ (auth, error) -> Void in
                if error != nil {
                    NSLog("\(error)")
                } else {
                    NSLog("Google Access Token Refreshed")
                }
            })
        }
    }
    
}
