import UIKit

class AccountSettingsViewController: UITableViewController {

    @IBOutlet var accountSettingsTableView: UITableView!
    
    var isSocialLogIn:Int?
    
    override func viewDidLoad() {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
         isSocialLogIn = prefs.integerForKey("ISSOCIALLOGIN")
        
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let navigationTitleView = AppUtil.setTitleInNavigationBar(155, titleTextViewWidth: 180, titleText: "Account settings", iconImgName: "account-setting")
        
        navigationItem.titleView = navigationTitleView
        
        accountSettingsTableView.tableFooterView = UIView(frame: CGRect.zero)
    } //End of viewDidLoad

    @IBAction func goBackToSettings(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Change the color of all cells
        cell.layoutMargins=UIEdgeInsetsZero;
        cell.backgroundColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Hiding the Username/Password change options if login is done via Social Platforms
        if isSocialLogIn == 1 {
            if indexPath.row == 0 || indexPath.row == 1 {
                return 0.0
            } else {
                return 44.0
            }
        } else {
            return 44.0
        }
    }
    
}
