import Foundation

class SocialLoginHelper {
    
    let MyKeychainWrapper = KeychainWrapper()
    
    var session:LRSession?
    var serverURL: String = AppHelper.getServerURL()
    
    // Checking validity of the LinkedIn access token, logging out the user if token expired
    func checkForLinkedInAccessTokenValidity(){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let liAccessToken:String? = prefs.objectForKey("LIAccessToken") as? String
        
        if liAccessToken != nil {
            let liAccessTokenExpiry:String = prefs.objectForKey("LIAccessTokenExpiryDate") as! String
            let expiryLongvalue:Int64 = Int64(liAccessTokenExpiry)!
            let currTime:Int64 = Int64(NSDate().timeIntervalSince1970*1000)

            if (currTime >= expiryLongvalue){
                NSLog("LinkedIn Access Token Expired")
                let appDomain = NSBundle.mainBundle().bundleIdentifier
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
            }
        }
    }
    
    // Checking validity of Facebook access token and refreshing the token if possible
    func checkForFacebookAccessTokenValidity() -> Bool {
       
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String? = prefs.objectForKey("USERNAME") as? String
        if username == "FACEBOOK" {
            if((FBSDKAccessToken.currentAccessToken()) != nil) {
                
                let expTime:Int64 = Int64(FBSDKAccessToken.currentAccessToken().expirationDate.timeIntervalSince1970*1000)
                let currTime:Int64 = Int64(NSDate().timeIntervalSince1970*1000)
            
                if(currTime >= expTime){
                    let appDomain = NSBundle.mainBundle().bundleIdentifier
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
                    FBSDKLoginManager().logOut()
                    return false
                } else {
                    FBSDKAccessToken.refreshCurrentAccessToken({ (connection, result, error) -> Void in
                        if error != nil {
                            NSLog("\(error)")
                        } else {
                            NSLog("Facebook Access Token Refreshed")
                        }
                    })
                    return true
                }
            }
            return false
        } else {
            return true
        }

    }
    
    // Create or Update the user in server when user logs in with social media platform
    func createUserWithSocialLogin(firstName:String, lastName:String, emailAddress:String, portraitURL:String, accessToken: String, loginType:String) -> Bool{
        
        session = LRSession(server: self.serverURL)
        let driverService:LRDriverService_v62 = LRDriverService_v62(session: self.session)
        do{
            let userObj: NSObject = try driverService.signinWithSocialPlatformWithFirstName(firstName, lastName: lastName, emailAddress: emailAddress, portraitURL: portraitURL, accessToken: accessToken, loginType: loginType)
            
            let userId:Int = userObj.valueForKey("userId") as! Int
            let fullName:String = firstName + " " + lastName
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
            prefs.setInteger(userId, forKey: "userId")
            prefs.setObject(loginType, forKey: "USERNAME")
            prefs.setObject(fullName, forKey: "fullName")
            prefs.setObject(emailAddress, forKey: "EMAIL")
            prefs.setObject(1, forKey: "ISSOCIALLOGIN")
            
            // Set Google's User default to make sure that token gets refreshed
            if loginType == "GOOGLE"{
                 prefs.setObject(1, forKey: "GID_AppHasRunBefore")
            }
            
            prefs.synchronize()
            
            self.MyKeychainWrapper.mySetObject(accessToken, forKey:kSecValueData)
            self.MyKeychainWrapper.writeToKeychain()
            
            return true
            
        } catch let error as NSError{
            NSLog("\(error)")
            
            let appDomain = NSBundle.mainBundle().bundleIdentifier
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
            
            switch error.code {
            case 2:
                AppUtil.showAlertWithMessage("Error", msg: "Could not sign in. Please try again")
            default:
                AppUtil.showAlertWithMessage("Error", msg: "Something went wrong. Please try again")
            }
            
            return false
        }
    }

}