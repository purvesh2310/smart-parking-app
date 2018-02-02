import Foundation

class AppUtil {
    
    static func getStatusBarView(yPoistion : CGFloat) -> UIView{
        
        let statusBarView = UIView(frame: CGRect(x: 0.0, y: yPoistion, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        statusBarView.backgroundColor = UIColor(red: 0.521, green: 0.521, blue: 0.521, alpha: 1.0)
        
        return statusBarView
    }
    
    // Sets the title in the navigation bar with icon
    static func setTitleInNavigationBar(NavTitleViewWidth:Int, titleTextViewWidth:Int, titleText:String, iconImgName:String) ->  UIView{
        
        let navigationTitleView = UIView(frame: CGRect(x: 0, y: 0, width: NavTitleViewWidth, height: 20))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: iconImgName)
        imageView.image = image
        
        let titleView = UILabel(frame: CGRect(x: 25, y: 0, width: titleTextViewWidth, height: 20))
        titleView.text = titleText
        titleView.textColor = UIColor.whiteColor()
        
        navigationTitleView.addSubview(imageView)
        navigationTitleView.addSubview(titleView)
        
        return navigationTitleView
    }
    
    static func showAlertWithMessage(title:String, msg:String){
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = msg
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()

    }
    
    static func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    // Adds the loading indicator to the given UIview
    static func showActivityIndicatory(uiView: UIView, loadingView: UIView) {
        
        loadingView.frame = CGRectMake(0, 0, 60, 60)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 0.313 , green: 0.313, blue: 0.313, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        uiView.addSubview(loadingView)
        actInd.startAnimating()
    }
    
}