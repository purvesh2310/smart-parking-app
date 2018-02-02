import UIKit

class SignupViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
        
    let loadingView: UIView = UIView()
    let socialLoginHelper:SocialLoginHelper = SocialLoginHelper()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnSignUp.layer.cornerRadius = 6
    
        btnSignIn.layer.cornerRadius = 6
        btnSkip.layer.cornerRadius = 12
        btnSkip.layer.borderWidth = 1
        btnSkip.backgroundColor = UIColor(red: 133/255, green: 133/255, blue:133/255, alpha: 0.6)
        btnSkip.layer.borderColor = UIColor( red: 255/255, green: 255/255, blue:255/255, alpha: 1.0 ).CGColor
        
        let barview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        barview.backgroundColor = UIColor(red: 0.521, green: 0.521, blue: 0.521, alpha: 1.0)
        self.view.addSubview(barview)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        configureForGoogle()
        
        AppUtil.showActivityIndicatory(view,loadingView: loadingView)
        loadingView.hidden = true
        
    }
    
    func configureForGoogle(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func silentSignInForGoogle(){
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func swipeLeft() {
        self.performSegueWithIdentifier("sendToSignInScreen", sender: self)
    }
    
   override func viewWillAppear(animated: Bool) {
    
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Delegate method of Google to create/update the user if logs in via Google account
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let _ = error {
            print(error)
            loadingView.hidden = true
            if error.code == -1 {
                AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
            }
        }
        else {
            
            let name:String = GIDSignIn.sharedInstance().currentUser.profile.name
            let email = GIDSignIn.sharedInstance().currentUser.profile.email
            
            let imgURL: NSURL = GIDSignIn.sharedInstance().currentUser.profile.imageURLWithDimension(100)
    
            let fullNameArr = name.characters.split{$0 == " "}.map(String.init)
            let firstName:String = fullNameArr[0]
            let lastName:String = fullNameArr[1]

            if (GIDSignIn.sharedInstance().currentUser != nil) {
                let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                let userCreationSuccess:Bool = socialLoginHelper.createUserWithSocialLogin(firstName, lastName: lastName, emailAddress: email, portraitURL: imgURL.absoluteString, accessToken: accessToken, loginType: "GOOGLE")
                
                if userCreationSuccess == true {
                    self.performSegueWithIdentifier("sendToNearbyFacilities", sender: nil)
                } else {
                     self.loadingView.hidden = true
                }
                
            }
        }
        
    }
    
    @IBAction func signInWithGoogle(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
        loadingView.hidden = false
    }

    @IBAction func signInWithFacebook(sender: AnyObject) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web

        if((FBSDKAccessToken.currentAccessToken()) == nil){
        fbLoginManager.logInWithReadPermissions(["public_profile", "email"],
            fromViewController:self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                
                if fbloginresult.grantedPermissions != nil {
                    self.loadingView.hidden = false
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                    }
                }
            }
        })
        } else {
            getFBUserData()
        }
    }
    
    // Fetches data from Facebook and create/update account if user logs in via Facebook
    func getFBUserData() {
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.width(200).height(200), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let userEmail : String = result.valueForKey("email") as! String
                    let firstName : String = result.valueForKey("first_name") as! String
                    let lastName : String = result.valueForKey("last_name") as! String
                    let profilePicURL: String = result.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                    
                    let userCreationSuccess:Bool = self.socialLoginHelper.createUserWithSocialLogin(firstName, lastName: lastName, emailAddress: userEmail, portraitURL: profilePicURL, accessToken: FBSDKAccessToken.currentAccessToken().tokenString, loginType: "FACEBOOK")
                    
                    if userCreationSuccess == true {
                         self.performSegueWithIdentifier("sendToNearbyFacilities", sender: nil)
                    } else {
                         self.loadingView.hidden = true
                    }
                }
            })
        }
    }
    
    // Method for performing unwind segue to Signup screen
    @IBAction func unwindToSignupScreen(segue:UIStoryboardSegue) {
    }
    
}
