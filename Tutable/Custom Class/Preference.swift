//
//  Preference.swift
//  Check-Up
//
//  Created by Amisha on 13/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class Preference: NSObject {

    static let sharedInstance = Preference()
    
    let REQUEST_TOKEN_KEY       =   "REQUEST_TOKEN"
    let AUTH_TOKEN_KEY          =   "AUTH_TOKEN"
    let IS_USER_LOGIN_KEY       =   "IS_USER_LOGIN"
    let USER_DATA_KEY           =   "USER_DATA"
    let USER_ID_KEY             =   "USER_ID"
    let USER_LATITUDE_KEY       =   "USER_LATITUDE"
    let USER_LONGITUDE_KEY      =   "USER_LONGITUDE"
    let USER_TYPE               =   "USER_TYPE"
}


func setDataToPreference(data: AnyObject, forKey key: String)
{
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
}

func getDataFromPreference(key: String) -> AnyObject?
{
    return UserDefaults.standard.object(forKey: key) as AnyObject?
}

func removeDataFromPreference(key: String)
{
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}

func removeUserDefaultValues()
{
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
}

//MARK: - User login boolean
func setIsUserLogin(isUserLogin: Bool)
{
    setDataToPreference(data: isUserLogin as AnyObject, forKey: Preference.sharedInstance.IS_USER_LOGIN_KEY)
}

func isUserLogin() -> Bool
{
    let isUserLogin = getDataFromPreference(key: Preference.sharedInstance.IS_USER_LOGIN_KEY)
    return isUserLogin == nil ? false:(isUserLogin as! Bool)
}

func setLoginUserData(_ dictData: [String : Any])
{
    setDataToPreference(data: dictData as AnyObject, forKey: Preference.sharedInstance.USER_DATA_KEY)
    setIsUserLogin(isUserLogin: true)
}

func getLoginUserData() -> [String : Any]?
{
    if let data = getDataFromPreference(key: Preference.sharedInstance.USER_DATA_KEY)
    {
        return data as? [String : Any]
    }
    return nil
}

func setDeviceToken(value: String)
{
    setDataToPreference(data: value as AnyObject, forKey: "push_device_token")
}

func getDeviceToken() -> String
{
    if let deviceToken = getDataFromPreference(key: "push_device_token")
    {
        return deviceToken as! String
    }
    return ""
}

func setUserType(type : Int)
{
    setDataToPreference(data: type as AnyObject, forKey: Preference.sharedInstance.USER_TYPE)
}

func isStudentLogin() -> Bool
{
    if getDataFromPreference(key: Preference.sharedInstance.USER_TYPE) as? Int == 2
    {
        return true
    }
    else
    {
        return false
    }
}

func setPoliceCertificate(_ strUrl : String)
{
    setDataToPreference(data: strUrl as AnyObject, forKey: "police_certificate")
}

func getPoliceCertificate() -> String
{
    if let strUrl : String = getDataFromPreference(key: "police_certificate") as? String
    {
        return strUrl
    }
    return ""
}

func setChildreanCertificate(_ strUrl : String)
{
    setDataToPreference(data: strUrl as AnyObject, forKey: "childrean_certificate")
}

func getChildreanCertificate() -> String
{
    if let strUrl : String = getDataFromPreference(key: "childrean_certificate") as? String
    {
        return strUrl
    }
    return ""
}
