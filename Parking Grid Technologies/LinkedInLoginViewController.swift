import UIKit

class LinkedInLoginViewController: UIViewController, UIWebViewDelegate {
    
    var linkedInKey:String = ""
    var linkedInSecret:String = ""
    var authorizationEndPoint:String = ""
    var accessTokenEndPoint:String = ""
    var responseType:String = ""
    var scope:String = ""
    var redirectURL:String = ""
    let linkedinAppDetailsDict:NSDictionary = AppHelper.getLinkedinAppDetails()

    let socialLoginHelper:SocialLoginHelper = SocialLoginHelper()
    let loadingView: UIView = UIView()
    
    @IBOutlet weak var linkedInLoginWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkedInKey = linkedinAppDetailsDict.objectForKey("linkedInKey") as! String
        linkedInSecret = linkedinAppDetailsDict.objectForKey("linkedInSecret") as! String
        authorizationEndPoint = linkedinAppDetailsDict.objectForKey("authorizationEndPoint") as! String
        accessTokenEndPoint = linkedinAppDetailsDict.objectForKey("accessTokenEndPoint") as! String
        redirectURL = linkedinAppDetailsDict.objectForKey("authorizedRedirectUrl") as! String
        redirectURL = redirectURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        responseType = linkedinAppDetailsDict.objectForKey("responseType") as! String
        scope = linkedinAppDetailsDict.objectForKey("scope") as! String
        
        linkedInLoginWebView.delegate = self
        
        let statusBarView = AppUtil.getStatusBarView(0.0)
        self.view.addSubview(statusBarView)
        
        startAuthorization()
        
        AppUtil.showActivityIndicatory(view,loadingView: loadingView)
        loadingView.hidden = true
    }
    
    func startAuthorization() {
        
        // Create a random string based on the time interval (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        // Create a URL request and load it in the web view.
        let request = NSURLRequest(URL: NSURL(string: authorizationURL)!)
        linkedInLoginWebView.loadRequest(request)
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url = request.URL!
        let host = linkedinAppDetailsDict.objectForKey("host") as! String
        
        if url.host == host {
            if url.absoluteString.rangeOfString("code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.componentsSeparatedByString("?")
                let code = urlParts[1].componentsSeparatedByString("=")[1]
                loadingView.hidden = false
                requestForAccessToken(code)
            }
        }
        return true
    }
    
    
    func requestForAccessToken(authorizationCode: String) {
        
        let grantType = "authorization_code"
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedInSecret)"
        
        // Convert the POST parameters into a NSData object.
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(URL: NSURL(string: accessTokenEndPoint)!)
        
        // Indicate that we're about to make a POST request.
        request.HTTPMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.HTTPBody = postData
        
        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // Make the request.
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    let expires_in:Int64 = (dataDictionary["expires_in"] as! NSNumber).longLongValue
                    
                    let currTime:Int64 = Int64(NSDate().timeIntervalSince1970*1000)
                    let expTime = currTime + expires_in*1000
                    
                    NSUserDefaults.standardUserDefaults().setObject(String(expTime), forKey: "LIAccessTokenExpiryDate")
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "LIAccessToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.getDataFromLinkedIn(accessToken)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                    self.loadingView.hidden = true
                }
            }
        }
        task.resume()
        
    }// End of requestForAccessToken
    
    
    @IBAction func dismissLinkedLoginWebView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  
    
    
    func getDataFromLinkedIn(accessToken:String){
        
        // Specify the URL string that we'll get the profile info from.
        let targetURLString = "https://api.linkedin.com/v1/people/~:(id,email-address,first-name,last-name,formatted-name,public-profile-url,picture-urls::(original))?format=json"
        
        // Initialize a mutable URL request object.
        let request = NSMutableURLRequest(URL: NSURL(string: targetURLString)!)
        
        // Indicate that this is a GET request.
        request.HTTPMethod = "GET"
        
        // Add the access token as an HTTP header field.
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Initialize a NSURLSession object.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // Make the request.
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    self.createAccountWithLinkedIn(dataDictionary as! NSDictionary, accessToken: accessToken)
                    
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                    self.loadingView.hidden = true
                }
            }
        }
        task.resume()
    } // End of getDataFromLinkedIn()
    
    
    // Create/update account if user logs in via LinkedIn
    func createAccountWithLinkedIn(dataDictionary:NSDictionary, accessToken:String) {
        
        let firstName = dataDictionary["firstName"] as! String
        let lastName = dataDictionary["lastName"] as! String
        let emailAddress = dataDictionary["emailAddress"] as! String
        
        var profilePictureURL:String = ""
        
        let profilePictureArray = dataDictionary.valueForKey("pictureUrls")?.valueForKey("_total") as! Int
        if(profilePictureArray != 0) {
            let profielPictureArray = dataDictionary.valueForKey("pictureUrls")!.valueForKey("values") as! NSMutableArray
            profilePictureURL = profielPictureArray[0] as! String
        }
        
        let userCreationSuccess:Bool = socialLoginHelper.createUserWithSocialLogin(firstName, lastName: lastName, emailAddress: emailAddress, portraitURL: profilePictureURL, accessToken: accessToken, loginType: "LINKEDIN")
        
        if userCreationSuccess == true {
             dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("sendToNearbyFacilities", sender: nil)
            }
        } else {
            loadingView.hidden = true
        }
        
    } // End of createAccountWithLinkedIn
}
