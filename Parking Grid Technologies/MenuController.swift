import UIKit

class MenuController: UITableViewController {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var btnSignup: UIButton!
    let MyKeychainWrapper = KeychainWrapper()
    
    var serverURL: String?
    var offset:CGFloat = 0
    var isLoggedIn:Int?
    var prefs:NSUserDefaults?
    var session:LRSession?
    
    override func viewDidLoad() {

        prefs = NSUserDefaults.standardUserDefaults()
        isLoggedIn = prefs!.integerForKey("ISLOGGEDIN") as Int
        
        super.viewDidLoad()

        serverURL = AppHelper.getServerURL()
        
        self.menuTableView.layoutMargins=UIEdgeInsetsZero
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.btnSignOut.layer.cornerRadius = 6
        self.btnSignup.layer.cornerRadius = 6

        if isLoggedIn == 1 {
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.setImageUsingExternalURL()
            }
            
            btnSignup.removeFromSuperview()

        } else {
            removeObjectsFromSuperView()
        }
    }   // End of viewDidLoad
    
    
    override func viewWillAppear(animated: Bool) {
        setFooterViewInSideMenu()
    }
    
    // Loading user profile image from Server
    func setImageUsingExternalURL() {
        
        let fullName = String(prefs!.valueForKey("fullName")!)
        self.userFullName.text = fullName
        
        session = LRSession(server: serverURL)

        var password:String? 
        
        let emailAddress:String = String(prefs!.valueForKey("USERNAME")!)
        
        // Setting the password based on the login type of user
        if emailAddress == "GOOGLE" {
            if GIDSignIn.sharedInstance().currentUser != nil {
                password = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            }
        } else if emailAddress == "FACEBOOK"{
            password = FBSDKAccessToken.currentAccessToken().tokenString
        } else{
            password = MyKeychainWrapper.myObjectForKey("v_Data") as? String
        }
        
        let auth = LRBasicAuthentication(username: emailAddress, password: password)
        session = LRSession(server: serverURL, authentication: auth)
        
        let driverService:LRDriverService_v62 = LRDriverService_v62(session: session)
        
        do {
            let userId = Int64(String(prefs!.valueForKey("userId")!))
            var portraitURL:String = try driverService.getUserPortraitUrlWithUserId(userId!)
            portraitURL = serverURL! + "/image" + portraitURL
            let imgURL: NSURL = NSURL(string: portraitURL)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
             completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    self.profileImageView.image = UIImage(data: data!)
                }
            })
        } catch let error as NSError{
            NSLog("\(error)")
            switch error.code {
                case 2:
                    AppUtil.showAlertWithMessage("Error", msg: "Could not fetch profile picture. Please try again. If problem persists, try logging in again")
                default:
                    AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
            }
        }
        
    } // End of setImageUsingExternalURL
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 3{
            let helpURL:String! = AppHelper.getHelpURL()
            if let url = NSURL(string: helpURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    
    @IBAction func signOutTapped(sender: AnyObject) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        
        // Removing all NSUserDefaults of App on Signout operation
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        performSegueWithIdentifier("sendToSignUpScreen", sender:nil)
        
    }  // End of signOutTapped
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.layoutMargins = UIEdgeInsetsZero;
        cell.backgroundColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0)
    }
    
//     Setting height of cells based on the LoggedIn/LoggedOut condition
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if isLoggedIn != 1 {
            if indexPath.row == 0 {
                return 20
            } else {
                return 44
            }
        } else {
            if indexPath.row == 0 {
                return 130
                
            } else {
                return 44
            }
        }
    } // End of heightForRowAtIndexPath delegate method
    
    func removeObjectsFromSuperView() {
        
        profileCell.hidden = true
        btnSignOut.removeFromSuperview()
    }
    
    // set footer view
    func setFooterViewInSideMenu() {

        self.tableView.tableFooterView = nil
        self.tableView.tableFooterView?.backgroundColor = UIColor.blueColor()
        self.footerView.frame = CGRectMake(0, 0, self.menuTableView.frame.size.width, self.view.bounds.size.height - self.tableView.contentSize.height - offset)

        self.tableView.tableFooterView = self.footerView
    }

}