//
//  AppDelegate.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Social

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    var window: UIWindow?
    var isKeyboardOpen:Bool = false
    var activityLoader : NVActivityIndicatorView!
    var customTabbarVc : CustomTabBarController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        
        GIDSignIn.sharedInstance().clientID = GOOGLE.CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
        
        if isUserLogin()
        {
            AppModel.shared.currentUser = UserModel.init(dict: getLoginUserData()!)
            AppModel.shared.token = AppModel.shared.currentUser.accessToken
            APIManager.sharedInstance.serviceCallToGetUserDetail {
                
            }
            navigateToDashboard()
        }
        return true
    }

    @objc func keyboardDidShow(_ notif:NSNotification){
        isKeyboardOpen = true
    }
    
    @objc func keyboardDidHide(_ notif:NSNotification){
        isKeyboardOpen = false
    }
    
    func storyboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func sharedDelegate() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    //MARK:- Facebook Login
    func loginWithFacebook()
    {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook))
        {
            fbLoginManager.loginBehavior = FBSDKLoginBehavior.systemAccount
        }
        else
        {
            fbLoginManager.loginBehavior = FBSDKLoginBehavior.native;
        }
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: window?.rootViewController) { (result, error) in
            if let error = error {
                showAlert("Error", message: error.localizedDescription, completion: {})
                return
            }
            
            guard let token = result?.token else {
                return
            }
            
            guard let accessToken = token.tokenString else {
                return
            }
            
            let request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "picture.width(500).height(500), email, id, name, first_name"])
            self.showLoader()
            let connection : FBSDKGraphRequestConnection = FBSDKGraphRequestConnection()
            
            connection.add(request, completionHandler: { (connection, result, error) in
                self.removeLoader()
                if result != nil
                {
                    let dict = result as! [String : AnyObject]
                    print(dict)
                    
                    var userDict : [String : Any] = [String : Any]()
                    
                    if let fbId = dict["id"]
                    {
                        userDict["_id"] = fbId as! String
                    }
                    
                    if let email = dict["email"]
                    {
                        userDict["email"] = email as! String
                    }
                    
                    if let first_name = dict["first_name"]
                    {
                        userDict["firstName"] = first_name as! String
                    }
                    
                    if let lastName = dict["name"]
                    {
                        var last_name : String = lastName as! String
                        let first_name : String = userDict["firstName"] as! String
                        last_name = last_name.replacingOccurrences(of: first_name, with: "")
                        userDict["lastName"] = last_name
                    }
                    
                    if let picture = dict["picture"] as? [String : Any]
                    {
                        if let data = picture["data"] as? [String : Any]
                        {
                            if let url = data["url"]
                            {
                                userDict["picture"] = url as! String
                            }
                        }
                    }
                    
                    AppModel.shared.currentUser = UserModel.init(dict: userDict)
                    AppModel.shared.token = accessToken
                    
                    let vc : CreateProfileVC = self.storyboard().instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                    let nav : UINavigationController = self.window?.rootViewController as! UINavigationController
                    nav.pushViewController(vc, animated: true)
                    
                }
                else
                {
                    print(error?.localizedDescription)
                }
            })
            connection.start()
            
            
        }
        
    }
    
    
    //MARK:- Google Login
    func loginWithGoogle()
    {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn .sharedInstance().delegate = self
        GIDSignIn .sharedInstance().uiDelegate = self
        
        GIDSignIn .sharedInstance() .signIn()
        
//        let vc : CreateProfileVC = self.storyboard().instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
//        let nav : UINavigationController = self.window?.rootViewController as! UINavigationController
//        nav.pushViewController(vc, animated: true)
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!)
    {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            print(user.userID)                  // For client-side use only!
            print(user.authentication.idToken) // Safe to send to the server
            print(user.profile.name)
            print(user.profile.givenName)
            print(user.profile.familyName)
            print(user.profile.email)
            print(user.profile.imageURL(withDimension: 500))
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print(error.localizedDescription)
    }
    
    //MARK:- Navigate To Login
    func navigateToLogin()
    {
        let navigationVC = self.storyboard().instantiateViewController(withIdentifier: "ViewControllerNavigation") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = navigationVC
    }
    
    //MARK:- Navigate To Dashboard
    func navigateToDashboard()
    {
        customTabbarVc = self.storyboard().instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        
        if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
        {
            rootNavigatioVC.pushViewController(customTabbarVc, animated: false)
        }
    }
    
    //MARK:- Other func.
    func showLoader()
    {
        removeLoader()
        window?.isUserInteractionEnabled = false
        activityLoader = NVActivityIndicatorView(frame: CGRect(x: ((window?.frame.size.width)!-50)/2, y: ((window?.frame.size.height)!-50)/2, width: 50, height: 50))
        activityLoader.type = .ballSpinFadeLoader
        activityLoader.color = colorFromHex(hex: COLOR.APP_COLOR)
        window?.addSubview(activityLoader)
        activityLoader.startAnimating()
    }
    
    func removeLoader()
    {
        window?.isUserInteractionEnabled = true
        if activityLoader == nil
        {
            return
        }
        activityLoader.stopAnimating()
        activityLoader.removeFromSuperview()
        activityLoader = nil
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.contains("com.googleusercontent.apps"))
        {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

