import UIKit

class ChangeUsernameViewController: UIViewController {

    @IBOutlet weak var btnChangeUsername: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var txtUsername: UITextField!

    var session:LRSession?
    var serverURL: String?
    var prefs:NSUserDefaults?
    let MyKeychainWrapper = KeychainWrapper()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        btnChangeUsername.layer.cornerRadius = 6
        btnCancel.layer.cornerRadius = 6
        serverURL = AppHelper.getServerURL()
        prefs = NSUserDefaults.standardUserDefaults()
    }

    // Perform user updation operation when change username button tapped
    @IBAction func updateUsernameBtnTapped(sender: AnyObject) {
        
        let password:String? = MyKeychainWrapper.myObjectForKey("v_Data") as? String

        let newUsername:String = txtUsername.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let oldUsername = String(prefs!.valueForKey("USERNAME")!)
        
        let isValidEmail:Bool = AppUtil.isValidEmail(newUsername)

        if newUsername == "" {
             showAlertWithMessage("Error", msg: "Please enter email address")
            
        } else if (newUsername == oldUsername) {
             showAlertWithMessage("Error", msg: "This email address is already exist")
            
        } else if (isValidEmail == false) {
            showAlertWithMessage("Error", msg: "Please enter valid email address")
            
        } else {

            let auth = LRBasicAuthentication(username: oldUsername, password: password)
            session = LRSession(server: serverURL, authentication: auth)
            let userService:LRUserService_v62 = LRUserService_v62(session: session)

            do {
                let userObject:NSObject = try userService.getUserByEmailAddressWithCompanyId(AppHelper.getCompanyId(), emailAddress: oldUsername)
                
                let userId:Int64 = Int64(userObject.valueForKey("userId") as! Int)
                
                try userService.updateEmailAddressWithUserId(userId, password: "test", emailAddress1: newUsername, emailAddress2: newUsername, serviceContext: nil)
                
                 showAlertWithMessage("Success", msg: "Your username changed successfully.")
                
            } catch let error as NSError {
                 NSLog("\(error)")
                switch error.code {
                case 2:
                     showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
                case -1001:
                     showAlertWithMessage("Error", msg: "The request timed out. Please try again")
                default:
                     showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
                }
            }
        }
    } // End of updateUsernameBtnTapped
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
         navigationController?.popViewControllerAnimated(true)
    }
    
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
            self.performSegueWithIdentifier("sendToSignInScreen", sender: nil)
            let appDomain = NSBundle.mainBundle().bundleIdentifier
            // Removing all NSUserDefaults of App on Signout operation
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        }
    }
    
    @IBAction func backBtnTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
