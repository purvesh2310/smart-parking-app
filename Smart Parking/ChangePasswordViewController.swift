import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var txtOldUsername: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnCancelChangePassword: UIButton!
    @IBOutlet weak var changePasswordScrollView: UIScrollView!
    
    var session:LRSession?
    var serverURL: String?
    var prefs:NSUserDefaults?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnChangePassword.layer.cornerRadius = 6
        btnCancelChangePassword.layer.cornerRadius = 6

        serverURL = AppHelper.getServerURL()
        
        prefs = NSUserDefaults.standardUserDefaults()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }
    
    // Perform password updation operation when change password button tapped
    @IBAction func changePasswordBtnTapped(sender: AnyObject) {
        
        let oldPassword:String = txtOldUsername.text!
        let newPassword:String = txtNewPassword.text!
        let confirmPassword:String = txtConfirmPassword.text!

        if oldPassword == "" || newPassword == "" ||  confirmPassword == "" {
             showAlertWithMessage("Error", msg: "Please fill out all the fields")
            
        } else if(oldPassword == newPassword){
             showAlertWithMessage("Error", msg: "New password must be different from older one.")
            
        }else if newPassword != confirmPassword {
             showAlertWithMessage("Error", msg: "Passwords do not not match")
            
        } else {
            
            let username = String(prefs!.valueForKey("USERNAME")!)
            
            let auth = LRBasicAuthentication(username: username, password: oldPassword)
            session = LRSession(server: serverURL, authentication: auth)
            let userService:LRUserService_v62 = LRUserService_v62(session: session)
            
            do {
                let userObject:NSObject = try userService.getUserByEmailAddressWithCompanyId(AppHelper.getCompanyId(), emailAddress: username)
            
                let userId:Int64 = Int64(userObject.valueForKey("userId") as! Int)
                
                try userService.updatePasswordWithUserId(userId, password1: newPassword, password2: confirmPassword, passwordReset: false)

                 showAlertWithMessage("Success", msg: "Your password has been changed successfully.")
            
            } catch let error as NSError {
                 NSLog("\(error)")
                switch error.code {
                    case 2:
                         showAlertWithMessage("Error", msg: "Please enter correct old password.")
                    case -1001:
                         showAlertWithMessage("Error", msg: "The request timed out. Please try again")
                    default:
                         showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
                }
            }
        }
    } // End of changePasswordBtnTapped
    
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
    
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        
   
    }
    
    // Adjust scrolling when keyboard appears on the screen for editing
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        var contentInset:UIEdgeInsets = self.changePasswordScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.changePasswordScrollView.contentInset = contentInset
    }

    // Dismiss keyboard on a tap gesture on the screen
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backBtnTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancelBtnTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
