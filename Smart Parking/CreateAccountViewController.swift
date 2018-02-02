import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var accountScrollView: UIScrollView!
    @IBOutlet weak var btnCreateAccount: UIButton!
    
    var emailAddress:String = ""
    var password:String = ""
    var userObject:NSObject?

    var session:LRSession?
    var serverURL: String?
    
    let MyKeychainWrapper = KeychainWrapper()
   
    override func viewDidLoad() {

        super.viewDidLoad()

        serverURL = AppHelper.getServerURL()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        btnCreateAccount.layer.cornerRadius = 6
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let barview = AppUtil.getStatusBarView(-20)
        self.navigationController?.navigationBar.addSubview(barview)
        
        txtPhoneNumber.keyboardType = UIKeyboardType.NumberPad
    }
    
    // Create account on Create Account button tap
    @IBAction func createAccountTapped(sender: AnyObject) {
        
        let firstname:String = txtFirstName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let lastname:String = txtLastName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        emailAddress = txtEmailAddress.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let isValidEmail:Bool = AppUtil.isValidEmail(emailAddress)
        
        let phoneNumber:String = txtPhoneNumber.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let phoneNumberLength:Int = phoneNumber.characters.count
        
        password = txtPassword.text!
        let confirmPassword:String = txtConfirmPassword.text!
        var error: NSError?

        if firstname == "" || lastname == "" || emailAddress == "" || password == "" || confirmPassword == "" {
            showAlertWithMessage("Error", msg:  "Please fill out mandatory fields")
        } else if isValidEmail == false {
            showAlertWithMessage("Account Creation Failed!", msg:  "Please enter valid email id.")
        } else if password != confirmPassword {
            showAlertWithMessage("Account Creation Failed!", msg:  "Passwords do not match")
        } else if phoneNumberLength != 0 && phoneNumberLength != 10  {
            showAlertWithMessage("Account Creation Failed!", msg:  "Phone number must contain 10 digits")
        } else {
            session = LRSession(server: serverURL)
            let driverService:LRDriverService_v62 = LRDriverService_v62(session: session)
            
            do {
                let userObject:NSObject = try driverService.createDriverAccountWithFirstName(firstname, lastName: lastname, userOrgName: "", emailAddress: emailAddress, password: password, captchaText: "")
                
                let userId = Int64(userObject.valueForKey("userId") as! Int)
                 driverService.updateUserPhoneNumberWithUserId(userId, phoneNumber: phoneNumber, error: &error)
                
                 showAlertWithMessage("Success", msg: "Your account created successfully.")

            } catch let error as NSError{
                 NSLog("\(error)")
                switch error.code {
                case 2:
                    AppUtil.showAlertWithMessage("Account Creation Failed!", msg: "Email address is already exits.")
                  default:
                     showAlertWithMessage("Account Creation Failed!", msg:  "Something went wrong. Please try again.")
                }
            }
        }
    }
    
    
    // Adjust scrolling when keyboard appears on the screen for editing
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        var contentInset:UIEdgeInsets = self.accountScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.accountScrollView.contentInset = contentInset
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Dismiss keyboard on a tap gesture on the screen
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlertWithMessage(title:String, msg:String){
        
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = msg
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }

    // Redirecting user to signin screen on successful account creation
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.title == "Success"){
            let signInObject = SignInViewController()
            var isSignedIn:Bool = false
            isSignedIn = signInObject.signInUser(emailAddress, password: password)
            if (isSignedIn == true) {
                performSegueWithIdentifier("sendToNearbyFacilities", sender: nil)
            }
        }
    }

    @IBAction func backBtnTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }

    
}