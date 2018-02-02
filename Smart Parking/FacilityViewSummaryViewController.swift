import UIKit

class FacilityViewSummaryViewController: UIViewController, UIScrollViewDelegate {
    
    var parkingLotDic = [String: String]()
    var session:LRSession?
    var serverURL: String?
    var facilityId: Int64?
    var timer = NSTimer()
    var facilityService:LRFacilityService_v62?
    var lastImageUpdatedTime:Int64 = 0
    
    @IBOutlet weak var lblSpotsOpen: UILabel!
    @IBOutlet weak var lblParkingLotTitle: UILabel!
    @IBOutlet weak var facilityImageScrollView: UIScrollView!
    @IBOutlet weak var facilityImageView: UIImageView!
    @IBOutlet weak var lblAvailableZones: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblUpdated: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.facilityImageScrollView.minimumZoomScale = 1.0
        self.facilityImageScrollView.maximumZoomScale = 5.0

        self.activityIndicator.layer.zPosition = 10
        let transform:CGAffineTransform = CGAffineTransformMakeScale(2, 2)
        self.activityIndicator.transform = transform
        self.activityIndicator.layer.cornerRadius = 6

        self.lblUpdated.alpha = 0
        self.lblUpdated.layer.zPosition = 10
        self.lblUpdated.layer.masksToBounds = true
        self.lblUpdated.layer.cornerRadius = 6;
        
        serverURL = AppHelper.getServerURL()
        session = LRSession(server: serverURL)
        lblSpotsOpen.text = parkingLotDic["spots"]
        lblParkingLotTitle.text = parkingLotDic["title"]
        facilityService = LRFacilityService_v62(session: session)
        
        updateFacilityDetails(false)
        
        timer = NSTimer(timeInterval: 30.0, target: self, selector: "updateFacilityDetailsAtRegularInterval", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    
    
    func updateFacilityDetails(flag:Bool) {
        
            self.activityIndicator.startAnimating()
            
            let facilityId:Int64 = Int64(parkingLotDic["facilityid"]!)!
            
            do{
                let facilityData:NSObject = try facilityService!.getFacilityWithFacilityId(facilityId)
                
                let newlyUpdatedTime = Int64(String(facilityData.valueForKey("lastImageUpdateTime")!))!
                var layoutImageURL:String = String(facilityData.valueForKey("layoutImageURL")!)
                
                // Setting default image if facility image not available
                if (layoutImageURL.isEmpty) {
                    facilityImageView.image = UIImage(named:"no-preview-available")
                    self.displayUpdateMsg(flag)
                    self.activityIndicator.stopAnimating()
                    
                } else if (lastImageUpdatedTime != newlyUpdatedTime) {
                    
                    // Update openspots
                    let openSpots:String = String(facilityData.valueForKey("numberOfEmptySpots")!)
                    lblSpotsOpen.text = openSpots
                     
                    lastImageUpdatedTime = newlyUpdatedTime
                    layoutImageURL = serverURL! + layoutImageURL
                    setImageByExternalURL(layoutImageURL, flag:flag)
                    
                    let zoneData:NSObject = try facilityService!.getFacilityZonesWithFacilityId(facilityId)
                    let zoneDataAsArray:NSArray = zoneData as! [Dictionary<String, AnyObject>]
                    var availableZone:String! = ""
                    
                    for (var counter = 0; counter<zoneDataAsArray.count; counter++){
                        let zone = zoneDataAsArray[counter]
                        let zoneName = zone["name"] as! String
                        
                        availableZone = availableZone + zoneName
                        if counter != zoneDataAsArray.count - 1 {
                            availableZone = availableZone + ","
                        }
                    }
                    lblAvailableZones.text = availableZone
                    
                } else {
                    self.displayUpdateMsg(flag)
                    self.activityIndicator.stopAnimating()
                }
                
            } catch let error as NSError{
                NSLog("\(error)")
                switch error.code {
                case -1009:
                    AppUtil.showAlertWithMessage("Error", msg: "The Internet connection appears to be offline.")
                case -1001:
                    AppUtil.showAlertWithMessage("Error", msg: "The request timed out. Please try again")
                default:
                    AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
            }
        }
    } // End of setUpdatedParkingLotImage

    func setImageByExternalURL(layoutImageURL:String, flag:Bool){
        let imgURL: NSURL = NSURL(string: layoutImageURL)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                    completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if error == nil {
                            self.facilityImageView.image = UIImage(data: data!)
                        }
                        self.displayUpdateMsg(flag)
                        self.activityIndicator.stopAnimating()
                })
            }
        }
    } // end of setImageByExternalURL
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.facilityImageView
    }
    
    
    func displayUpdateMsg(flag:Bool) {
        if (flag == true) {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.lblUpdated.alpha = 1
                
                }, completion: { finished in
                    UIView.animateWithDuration(1, delay: 2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.lblUpdated.alpha = 0
                        }, completion: nil)
            })
        }
    }
    
    func updateFacilityDetailsAtRegularInterval(){
        let isConnectionAvailable:Bool = Reachability.isConnectedToNetwork()
        if (isConnectionAvailable == true) {
             updateFacilityDetails(true)
        }
    }
    
    @IBAction func refreshBtnTapped(sender: AnyObject) {
        
        let isConnectionAvailable:Bool = Reachability.isConnectedToNetwork()
        if (isConnectionAvailable == true) {
            updateFacilityDetails(true)
        } else {
           AppUtil.showAlertWithMessage("Error", msg: "The Internet connection appears to be offline.")
        }
    }

    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
}
