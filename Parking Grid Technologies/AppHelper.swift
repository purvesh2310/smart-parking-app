import Foundation

class AppHelper{
    
    static let propertyFileName: String = "AppConfig"
    static let socialLoginPropertyFileName: String = "SocialLoginConfig"
    
    // Get URL of Liferay server
    static func getServerURL() -> String {
        let dict: NSDictionary = getServerConfigProperties()
        
        let networkProtocol = (dict["networkProtocol"]) as! String
        let serverName = (dict["serverName"]) as! String
        
        let serverURL: String = networkProtocol + "://" + serverName
        
        return serverURL
    }
    
    // Get Liferay server configuration properties like Servername, port etc.
    static func getServerConfigProperties () -> NSDictionary {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        
        let networkProtocol = dict.objectForKey("networkProtocol") as! String
        let serverName = dict.objectForKey("serverName") as! String
        
        let propertyDictionary:[String:String] = ["networkProtocol":networkProtocol,
            "serverName":serverName]
        
        return propertyDictionary
    }
    
    // Load application configuration property file
    static func loadAppConfigPropertyFile(fileName:String) -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return dict!
    }
    
    // Get compnay id of Liferay portal from App config file
    static func getCompanyId() -> Int64 {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let companyId:Int64 = Int64(dict.objectForKey("companyId") as! String)!
        return companyId
    }
    
    // Get group id of the Liferay site from App config file
    static func getGroupId() -> Int64 {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let groupId:Int64 = Int64(dict.objectForKey("groupId") as! String)!
        return groupId
    }
    
    //Get help URL from App config file
    static func getHelpURL() -> String {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let helpURL = dict.objectForKey("helpURL") as! String
        return helpURL
    }
    
    //Get report a problem URL from App config file
    static func getReportProblemURL() -> String {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let reportProblemURL = dict.objectForKey("reportProblemURL") as! String
        return reportProblemURL
    }
    
    //Get report a problem URL from App config file
    static func getRateUsURL() -> String {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let rateUsURL = dict.objectForKey("rateUsURL") as! String
        return rateUsURL
    }
    
    
    static func getDefaultLocation() -> NSDictionary {
        let dict:NSDictionary = loadAppConfigPropertyFile(propertyFileName)
        let defaultLocation = dict.objectForKey("defaultLocation") as! NSDictionary
        return defaultLocation

    }
    
    //Get Google app details
    static func getGoogleAppDetails() -> NSDictionary {
        let dict:NSDictionary = loadAppConfigPropertyFile(socialLoginPropertyFileName)
        let googleDetailsDict = dict.objectForKey("google") as! NSDictionary
        return googleDetailsDict
    }
    
    //Get linkedin app details
    static func getLinkedinAppDetails() -> NSDictionary {
        let dict:NSDictionary = loadAppConfigPropertyFile(socialLoginPropertyFileName)
        let linkedinDetailsDict = dict.objectForKey("linkedIn") as! NSDictionary
        return linkedinDetailsDict
    }

}