import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let locationManager = CLLocationManager()
    var window: UIWindow?
    let socialLoginObj:SocialLoginHelper = SocialLoginHelper()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let isConnectionAvailable:Bool = Reachability.isConnectedToNetwork()
        
        if isConnectionAvailable == false {
            AppUtil.showAlertWithMessage("Internet connection failed", msg: "Please check your internet connection.")
            
        }
     
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        
        // Navigation bar customization
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = UIColor(red: 0.3843, green: 0.6980, blue: 0.9568, alpha: 1.0)
        navigationBarAppearace.tintColor = UIColor.whiteColor()
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let googleAppDetailsDict:NSDictionary = AppHelper.getGoogleAppDetails()
        
        let googleAppClientId = googleAppDetailsDict.objectForKey("clientId") as! String
        let googleAppScope = googleAppDetailsDict.objectForKey("scope") as! String
        
        GIDSignIn.sharedInstance().clientID = googleAppClientId
        GIDSignIn.sharedInstance().scopes.append(googleAppScope)
        
       let mainStoryboard: UIStoryboard? = self.window?.rootViewController?.storyboard
       let viewController = mainStoryboard!.instantiateViewControllerWithIdentifier("signUpView") as! SignupViewController
        
        viewController.silentSignInForGoogle()

        socialLoginObj.checkForLinkedInAccessTokenValidity()
        
        // Checking and setting root view controller of the App based on user login
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if isLoggedIn == 1 {
            let viewController = mainStoryboard!.instantiateViewControllerWithIdentifier("SWRevealView") as UIViewController
            self.window!.rootViewController = viewController
        }

         return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation) || GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}