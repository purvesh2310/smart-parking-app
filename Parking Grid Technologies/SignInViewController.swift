import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var signInScrollView: UIScrollView!
    @IBOutlet weak var btnGoBack: UIButton!
    
    var session:LRSession?
    var serverURL: String?
    var userObject:NSObject?
    
    var emailAddress:String = ""
    var password:String = ""
    
    let userNotificationKey = "userNotificationKey"
    let MyKeychainWrapper = KeychainWrapper()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let attrs = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSUnderlineStyleAttributeName : 1]
        
        let attributedString = NSMutableAttributedString(string:"")
        
        let buttonTitleStr = NSMutableAttributedString(string:"Home", attributes:attrs)
        attributedString.appendAttributedString(buttonTitleStr)
        btnGoBack.setAttributedTitle(attributedString, forState: .Normal)
        
        btnSignIn.layer.cornerRadius = 6

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let barview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        barview.backgroundColor = UIColor(red: 0.521, green: 0.521, blue: 0.521, alpha: 1.0)
        self.view.addSubview(barview)
        
        txtUsername.leftView = UIImageView(image: UIImage(named: "user-gray-icon")!)
        txtUsername.leftView!.frame = CGRectMake(0, 0,30,15)
        txtUsername.leftView!.contentMode = UIViewContentMode.ScaleAspectFit
        txtUsername.leftViewMode = UITextFieldViewMode.Always
        
        txtPassword.leftView = UIImageView(image: UIImage(named: "lock-icon")!)
        txtPassword.leftView!.frame = CGRectMake(0, 0,30,15);
        txtPassword.leftView!.contentMode = UIViewContentMode.ScaleAspectFit
        txtPassword.leftViewMode = UITextFieldViewMode.Always
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    // Peform Sign in operation when signin button is tapped
    @IBAction func signInButtonTapped(sender: AnyObject) {
        
        emailAddress = txtUsername.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        password = txtPassword.text!
        
        if emailAddress == "" || password == "" {
             AppUtil.showAlertWithMessage("Error", msg: "Please enter Username and Password")
            
        } else {
            var isSignedIn:Bool = false
            isSignedIn = signInUser(emailAddress, password: password)
            if (isSignedIn == true) {
                performSegueWithIdentifier("goToMapWithSignIn", sender: nil)
            }
        }
    } // End of signInButtonTapped
    

    // Adjust scrolling when keyboard appears on the screen for editing
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        var contentInset:UIEdgeInsets = self.signInScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.signInScrollView.contentInset = contentInset
    }
    
    // Re-adjust scrolling when keyboard hides from the screen
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.signInScrollView.contentInset = contentInset
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
        
    }
    
    @IBAction func btnGoBackTapped(sender: AnyObject) {
         navigationController?.popViewControllerAnimated(true)
    }
    
    func swipeRight(){
        navigationController?.popViewControllerAnimated(true)
    }
   
    
    // Dismiss keyboard on a tap gesture on the screen
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func signInUser(emailAddress:String, password:String) -> Bool{

        serverURL = AppHelper.getServerURL()
        
        let auth = LRBasicAuthentication(username: emailAddress, password: password)
        session = LRSession(server: serverURL, authentication: auth)
        let userService:LRUserService_v62 = LRUserService_v62(session: session)
        
        do{
            userObject = try userService.getUserByEmailAddressWithCompanyId(AppHelper.getCompanyId(), emailAddress: emailAddress)

            let userId:Int = userObject!.valueForKey("userId") as! Int
            let firstName = userObject!.valueForKey("firstName") as! String
            let lastName = userObject!.valueForKey("lastName")as! String
            let fullName:String = firstName + " " + lastName
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
            prefs.setInteger(userId, forKey: "userId")
            prefs.setObject(emailAddress, forKey: "USERNAME")
            prefs.setObject(fullName, forKey: "fullName")
            prefs.setObject(0, forKey: "ISSOCIALLOGIN")
            
            MyKeychainWrapper.mySetObject(password, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()

            return true
            
        } catch let error as NSError {
            NSLog("\(error)")
            switch error.code {
            case 2:
                AppUtil.showAlertWithMessage("Sign in Failed!", msg: "Invalid Username/Password")
            case -1001:
                AppUtil.showAlertWithMessage("Sign in Failed!", msg: "The request timed out. Please try again")
            default:
                AppUtil.showAlertWithMessage("Sign in Failed!", msg: "Something went wrong. Please try again")
            }
        }
        return false
    }
    
}