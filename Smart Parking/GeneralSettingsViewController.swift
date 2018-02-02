import UIKit

class GeneralSettingsViewController: UITableViewController {
    
    @IBOutlet var generalSettingsTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let navigationTitleView = AppUtil.setTitleInNavigationBar(150, titleTextViewWidth: 180, titleText: "General settings", iconImgName: "gen-setting")
        
        navigationItem.titleView = navigationTitleView
        generalSettingsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    
    @IBAction func goBackToSettings(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Change the color of all cells
        cell.layoutMargins=UIEdgeInsetsZero;
        cell.backgroundColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0
        {
            let helpURL:String! = AppHelper.getHelpURL()
            if let url = NSURL(string: helpURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        } else if indexPath.row == 1 {
            let reportProblemURL:String! = AppHelper.getReportProblemURL()
            if let url = NSURL(string: reportProblemURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        } else if indexPath.row == 2 {
            let rateUsURL:String! = AppHelper.getRateUsURL()
            if let url = NSURL(string: rateUsURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        }

    }
    
}
