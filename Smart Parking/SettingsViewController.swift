import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet var settingsTableView: UITableView!
   
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var cellAccount: UITableViewCell!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        if self.revealViewController() != nil {
            btnMenu.target = self.revealViewController()
            btnMenu.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        settingsTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let navigationTitleView = AppUtil.setTitleInNavigationBar(100, titleTextViewWidth: 80, titleText: "Settings", iconImgName: "big-setting-icon")
        
        navigationItem.titleView = navigationTitleView
        
        let barview = AppUtil.getStatusBarView(-20)
        self.navigationController?.navigationBar.addSubview(barview)
    }

    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        // Change the color of all cells
        cell.layoutMargins=UIEdgeInsetsZero;
        cell.backgroundColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0)

        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int

        if isLoggedIn != 1 {
           cellAccount.removeFromSuperview()
        }
    }
    
    
}
