import UIKit

class ChangePhoneViewController: UIViewController {
    
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnCancel: UIButton!

    var session:LRSession?
    var serverURL: String?
    var prefs:NSUserDefaults?
    let MyKeychainWrapper = KeychainWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnChange.layer.cornerRadius = 6
        btnCancel.layer.cornerRadius = 6
        serverURL = AppHelper.getServerURL()
        prefs = NSUserDefaults.standardUserDefaults()
        
        txtPhoneNumber.keyboardType = UIKeyboardType.NumberPad
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Peform Sign in operation when change button is tapped
    @IBAction func changePhoneBtnTapped(sender: AnyObject) {

        var error: NSError?
        
        let newPhoneNumber:String = txtPhoneNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let phoneNumberLength:Int = newPhoneNumber.characters.count
        
        if newPhoneNumber == "" {
             showAlertWithMessage("Error", msg: "Please enter phone number")
            
        } else if phoneNumberLength != 10 {
            showAlertWithMessage("Error", msg: "Phone number must contain 10 digits")
          
        } else {
            
            var username:String
            var password:String? = MyKeychainWrapper.myObjectForKey("v_Data") as? String
            
            let isSocialLogIn:Int = prefs!.integerForKey("ISSOCIALLOGIN") as Int
            if isSocialLogIn == 1 {
                username = prefs!.valueForKey("USERNAME") as! String
            } else {
                username = String(prefs!.valueForKey("EMAIL")!)
            }
            
            // Setting the password based on the login type of user
            if username == "GOOGLE" {
                password = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            } else if username == "FACEBOOK"{
                password = FBSDKAccessToken.currentAccessToken().tokenString
            } else {
                password = MyKeychainWrapper.myObjectForKey("v_Data") as? String
            }
            
            let userId = Int64(String(prefs!.valueForKey("userId")!))
            
            let auth = LRBasicAuthentication(username: username, password: password)
            session = LRSession(server: serverURL, authentication: auth)
            let driverService:LRDriverService_v62 = LRDriverService_v62(session: session)
            driverService.updateUserPhoneNumberWithUserId(userId!, phoneNumber: newPhoneNumber, error: &error)

            if(error != nil) {
                 NSLog("\(error)")
                switch error!.code {
                    case -1009:
                        showAlertWithMessage("Error", msg: "The Internet connection appears to be offline")
                    case -1001:
                        showAlertWithMessage("Error",msg: "The request timed out. Please try again")
                    case 2:
                        showAlertWithMessage("Error", msg: "Could not update the phone number. Please try again. If problem persists, try logging in again")
                    default:
                        showAlertWithMessage("Error",msg: "Something went wrong. Please try again")
                }
            } else {
                showAlertWithMessage("Success", msg: "Your phone number changed successfully")
            }
        } 
    } //End of changePhoneBtnTapped
    
    
    func showAlertWithMessage(title:String, msg:String){
        
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = msg
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.title == "Success"){
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func backBtnTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
