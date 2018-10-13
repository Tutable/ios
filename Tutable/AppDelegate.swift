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
import Fabric
import Crashlytics
import UserNotifications  //iOS 10 for local and remote notifications

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

import CoreData
import Foundation
import MessageUI
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate, URLSessionDelegate {

    var window: UIWindow?
    var isKeyboardOpen:Bool = false
    var activityLoader : NVActivityIndicatorView!
    var customTabbarVc : CustomTabBarController!
    
    //Firebase chat start
    var appUsersRef:DatabaseReference!
    var appUsersRefHandler:UInt = 0;
    
    var inboxListRef : DatabaseReference!
    var inboxListRefHandler:UInt = 0
    var inboxNewMessageNoti : [String : Bool] = [String : Bool] ()
    
    var messageListRef : DatabaseReference!
    var messageListRefHandler:UInt = 0
    var userFcmToken : String = ""
    var ProfilePic = UIImage()
    var pathStr = ""
    //Firebase Chat end
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        application.statusBarStyle = .lightContent
        
        //print(UIDevice.current.identifierForVendor?.uuidString)
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        
        GIDSignIn.sharedInstance().clientID = GOOGLE.CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
        
        // Fabric
        Fabric.with([Crashlytics.self])
        self.logUser()

        // Push Notification
        registerPushNotification(application)
        
        // Load Firebase Development DB file.
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
            else { assert(false, "Couldn't load config file") }
        FirebaseApp.configure(options: fileopts)
        
//        // Load Firebase Live DB file.
//        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
//        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
//            else { assert(false, "Couldn't load config file") }
//        FirebaseApp.configure(options: fileopts)
        
        //Firebase chat start
       // FirebaseApp.configure()
        
        //create Table
        appUsersRef = Database.database().reference().child("USERS")
        inboxListRef = Database.database().reference().child("INBOX")
        messageListRef = Database.database().reference().child("MESSAGES")
        
        setDataToPreference(data: false as AnyObject, forKey: "isLastSeenUpdate")
        //Firebase Chat end
        
        //Stripe
        STPPaymentConfiguration.shared().publishableKey = STRIPE.STRIPE_PUB_KEY
        
        //User Login
        if isUserLogin() && getLoginUserData() != nil
        {
            AppModel.shared.currentUser = UserModel.init(dict: getLoginUserData()!)
            AppModel.shared.token = AppModel.shared.currentUser.accessToken
            APIManager.sharedInstance.serviceCallToGetUserDetail {
                
            }
            if !isStudentLogin()
            {
                APIManager.sharedInstance.serviceCallToGetCertificate {}
            }
            navigateToDashboard()
        }
        return true
    }

    var statusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("tutableapp@gmail.com")
        if AppModel.shared.currentUser != nil
        {
            Crashlytics.sharedInstance().setUserIdentifier(AppModel.shared.currentUser.id)
            Crashlytics.sharedInstance().setUserName(AppModel.shared.currentUser.name)
        }
        else
        {
            Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.identifierForVendor?.uuidString)
            Crashlytics.sharedInstance().setUserName("Tutable iOS")
        }
        Crashlytics.setValue(APP_VERSION, forKey: "version")
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
                        userDict["id"] = fbId as! String
                    }
                    
                    if let email = dict["email"]
                    {
                        userDict["email"] = email as! String
                    }
                    
                    if let name = dict["name"]
                    {
                        userDict["firstName"] = name
                    }
                    
                    userDict["accessToken"] = accessToken
                    
                    
                    var finalDict : [String : Any] = [String : Any]()
                    finalDict["name"] = userDict["firstName"]
                    if let picture = dict["picture"] as? [String : Any]
                    {
                        if let data = picture["data"] as? [String : Any]
                        {
                            if let url = data["url"]
                            {
                                finalDict["picture"] = url as! String
                            }
                        }
                    }
                    finalDict["facebook"] = userDict
                    finalDict["email"] = userDict["email"]
                    print(finalDict)
                    self.socialLoginResponse(finalDict)
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
            
            
            var userDict : [String : Any] = [String : Any]()
            if let gId = user.userID {
                userDict["id"] = gId
            }
            if let email = user.profile.email {
                userDict["email"] = email
            }            
            if let first_name = user.profile.name {
                userDict["firstName"] = first_name
            }
            if var last_name = user.profile.familyName {
                let first_name : String = userDict["firstName"] as! String
                last_name = last_name.replacingOccurrences(of: first_name, with: "")
                userDict["lastName"] = last_name
            }
            userDict["accessToken"] = user.authentication.idToken
            
            var finalDict : [String : Any] = [String : Any]()
            finalDict["name"] = userDict["firstName"]
            if let picture = user.profile.imageURL(withDimension: 500)
            {
                finalDict["picture"] = picture.absoluteString
            }
            finalDict["google"] = userDict
            finalDict["email"] = userDict["email"]
            print(finalDict)
            socialLoginResponse(finalDict)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print(error.localizedDescription)
    }
    
    func socialLoginResponse(_ finalDict :[String : Any])
    {
        if isStudentLogin()
        {
            APIManager.sharedInstance.serviceCallToStudentSocialLogin(finalDict, completion: { (code) in
                if code == 100
                {
                    setSocialLoginUser()
                    if AppModel.shared.currentUser.dob == 0.0
                    {
                        let vc : EditStudentProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "EditStudentProfileVC") as! EditStudentProfileVC
                        vc.isBackBtnDisplay = false
                        if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
                        {
                            self.calledForLoginUser()
                            rootNavigatioVC.pushViewController(vc, animated: false)
                        }
                    }
                    else
                    {
                        self.navigateToDashboard()
                    }
                }
            })
        }
        else
        {
            APIManager.sharedInstance.serviceCallToTeacherSocialLogin(finalDict, completion: { (code) in
                if code == 100
                {
                    setSocialLoginUser()
                    APIManager.sharedInstance.serviceCallToGetCertificate {
                        let redirectionType : Int = AppDelegate().sharedDelegate().redirectAfterTeacherRegistration()
                        if redirectionType == 0
                        {
                            AppDelegate().sharedDelegate().navigateToDashboard()
                        }
                        else if redirectionType == 1
                        {
                            let vc : AddTeacherProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "AddTeacherProfileVC") as! AddTeacherProfileVC
                            vc.isBackDisplay = false
                            if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
                            {
                                self.calledForLoginUser()
                                rootNavigatioVC.pushViewController(vc, animated: false)
                            }
                        }
                        else if redirectionType == 2
                        {
                            let vc : TeacherCertificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherCertificationVC") as! TeacherCertificationVC
                            vc.isBackDisplay = false
                            if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
                            {
                                self.calledForLoginUser()
                                rootNavigatioVC.pushViewController(vc, animated: false)
                            }
                        }
                        else if redirectionType == 3
                        {
                            let vc : TeacherQulificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherQulificationVC") as! TeacherQulificationVC
                            vc.isBackDisplay = false
                            if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
                            {
                                self.calledForLoginUser()
                                rootNavigatioVC.pushViewController(vc, animated: false)
                            }
                        }
                    }
                }
            })
        }
    }
    
    
    //MARK:- Navigate To Login
    func navigateToRoot()
    {
        let navigationVC = self.storyboard().instantiateViewController(withIdentifier: "ViewControllerNavigation") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = navigationVC
    }
    
    //MARK:- Navigate To Dashboard
    func navigateToDashboard()
    {
        setLoginUserData(AppModel.shared.currentUser.dictionary())
        customTabbarVc = self.storyboard().instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        
        if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
        {
//          calledForLoginUser()
            rootNavigatioVC.pushViewController(customTabbarVc, animated: false)
        }
        calledForLoginUser()
    }
    
    func navigateToProfile()
    {
        setLoginUserData(AppModel.shared.currentUser.dictionary())
        customTabbarVc = self.storyboard().instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
        {
            
            rootNavigatioVC.pushViewController(customTabbarVc, animated: false)
        }
        calledForLoginUser()
    }
    
    func calledForLoginUser()
    {
        getCategory()
        setupFirebase()
        setDataToPreference(data: true as AnyObject, forKey: "isLastSeenUpdate")
    }
    
    //MARK:- Logout
    func logoutApp()
    {
        if AppModel.shared.firebaseCurrentUser != nil
        {
            AppModel.shared.firebaseCurrentUser.fcmToken = ""
            updateLastSeen(isOnline: false)
            updateCurrentUserData()
        }
        let deviceToken : String = getDeviceToken()
        let about : String = getAboutContent()
        let tearms : String = getTearmsConditionContent()
        let help : String = getHelpContent()
        AppModel.shared.currentUser = nil
        AppModel.shared.currentClass = nil
        AppModel.shared.firebaseCurrentUser = nil
        removeUserDefaultValues()
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        
        navigateToRoot()
        setDeviceToken(value: deviceToken)
        setAboutContent(about)
        setTearmsConditionContent(tearms)
        setHelpContent(help)
    }
    
    func redirectAfterTeacherRegistration() -> Int
    {
        var redirectionType : Int = 0
        if AppModel.shared.currentUser.picture == ""
        {
            redirectionType = 1
        }
        else if AppModel.shared.currentUser.name == ""
        {
            redirectionType = 1
        }
        else if AppModel.shared.currentUser.dob == 0
        {
            redirectionType = 1
        }
        else if AppModel.shared.currentUser.bio == ""
        {
            redirectionType = 1
        }
        else if AppModel.shared.currentUser.address == LocationModel.init()
        {
            redirectionType = 1
        }
        else if getPoliceCertificate() == ""
        {
            redirectionType = 2
        }
//        else if AppModel.shared.currentUser.qualification == ""
//        {
//            redirectionType = 3
//        }
//        else if AppModel.shared.currentUser.school == ""
//        {
//            redirectionType = 3
//        }
//        else if AppModel.shared.currentUser.degreeAsset == ""
//        {
//            redirectionType = 3
//        }
        
        
        return redirectionType
    }
    
    
    //MARK:- Get Category
    func getCategory()
    {
        if !isUserLogin()
        {
            return
        }
        var isCall : Bool = false
        if getCategoryList().count == 0
        {
            isCall = true
        }
        else
        {
            if getDataFromPreference(key: "category_fetched") == nil
            {
                isCall = true
            }
            else
            {
                let oldDate : String = getDataFromPreference(key: "category_fetched") as! String
                let newDate : String = getDateStringFromDate(date: Date())
                if newDate != oldDate
                {
                    isCall = true
                }
            }
            if getCategoryList().count > 0
            {
                let data : [[String : Any]] = getCategoryList()
                AppModel.shared.categoryData = [CategoryModel]()
                for temp in data
                {
                    AppModel.shared.categoryData.append(CategoryModel.init(dict: temp))
                }
            }
        }
        
        if isCall
        {
            APIManager.sharedInstance.serviceCallToGetCategory {
                setDataToPreference(data: getDateStringFromDate(date: Date()) as AnyObject, forKey: "category_fetched")
                if getCategoryList().count > 0
                {
                    let data : [[String : Any]] = getCategoryList()
                    AppModel.shared.categoryData = [CategoryModel]()
                    for temp in data
                    {
                        AppModel.shared.categoryData.append(CategoryModel.init(dict: temp))
                    }
                }
            }
        }
    }
    
    //MARK:- Firebase
    func setupFirebase()
    {
        if let _ : [String : Any] = getLoginUserData()
        {
            //loginWithFirebase()
            loginWithFirebase2()
        }
    }
    
    func registerWithFirebae()
    {
        Auth.auth().createUser(withEmail: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email) { (user, error) in
            if error == nil
            {
                AppModel.shared.isFCMConnected = true
                AppModel.shared.firebaseCurrentUser = FirebaseUserModel.init(dict: AppModel.shared.currentUser.dictionary())
                AppModel.shared.firebaseCurrentUser.fcmToken = self.getFcmToken()
                
                self.updateCurrentUserData()
                self.callAllHandler()
            }
            else
            {
//                print(error?.localizedDescription)
            }
        }
    }
    
    
    
    //MARK:- Register with Firebase
    func registerWithFirebase2()
    {
        guard let str = AppModel.shared.currentUser.picture else{
            return
        }
        
        var newStr = ""
        if str.contains("http://") || str.contains("https://")
        {
            newStr = str
        }
        else
        {
            newStr = BASE_URL + str
        }
        
        
        
        let url = URL.init(string: newStr)
        if url != nil{
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { () -> Void in
                    self.ProfilePic = image
                    USER.registerUser(withName: AppModel.shared.currentUser.name, email: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email, profilePic: self.ProfilePic, fcmToken: self.getFcmToken(),notificationCount: 0,location: ["latitude":0,"longitude": 0]) { (handler) in
                        if handler == nil{
                            
                            print("registerd")
                        }
                        else{
                            
                        }
                    }
                }
                }.resume()
            
            
        }
        
        if ProfilePic == nil{
            ProfilePic = #imageLiteral(resourceName: "profile_avatar_in_post")
        }
        
    }
    
    
    
    
    //MARK:- Login with Firebase
    func loginWithFirebase2()
    {
        USER.loginUser(email: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email) { (handler) in
            if handler == nil{
                if let currentUserID = AppModel.shared.currentUser.id{
                   
                    guard let str = AppModel.shared.currentUser.picture else{
                        return
                    }
                    var newStr = ""
                    if str.contains("http://") || str.contains("https://")
                    {
                        newStr = str
                    }
                    else
                    {
                        newStr = BASE_URL + str
                    }
                    
                    let url = URL.init(string: newStr)
                    if url != nil{
                        
                        URLSession.shared.dataTask(with: url!) { (data, response, error) in
                            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                                let data = data, error == nil,
                                let image = UIImage(data: data)
                                else { return }
                            DispatchQueue.main.async() { () -> Void in
                                self.ProfilePic = image
                                let storageRef = Storage.storage().reference().child("usersProfilePics").child("\((AppModel.shared.currentUser.id)!).jpg")
                                let imageData = UIImageJPEGRepresentation(self.ProfilePic, 0.1)
                                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                                    if err == nil {
                                        storageRef.downloadURL(completion: { (url, error) in
                                            if error == nil{
                                                guard let path = url?.absoluteString else{
                                                    return
                                                }
                                                self.pathStr = path
                                                let location =  ["latitude":0,"longitude": 0]
                                                var type = ""
                                                if let typeValue = UserDefaults.standard.value(forKey: "type") as? String{
                                                   type = typeValue
                                                }
                                                Database.database().reference().child("users").child(currentUserID).child("credentials").updateChildValues(["fcmToken":self.getFcmToken(),"name":AppModel.shared.currentUser.name,"email":AppModel.shared.currentUser.email,"profilePicLink": self.pathStr,"location":location,"notificationCount":0,"type":type])
                                                print("Logged in")
                                            }
                                        })
                                    }
                                })
                            }
                            }.resume()
                        
                        
                    }
                }
                
            }
            else{
                self.registerWithFirebase2()
            }
        }
    }
    
    func loginWithFirebase()
    {
        Auth.auth().signIn(withEmail: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email) { (user, error) in
            if error == nil
            {
                AppModel.shared.isFCMConnected = true
                AppModel.shared.firebaseCurrentUser = FirebaseUserModel.init(dict: AppModel.shared.currentUser.dictionary())
                AppModel.shared.firebaseCurrentUser.fcmToken = self.getFcmToken()
                self.updateCurrentUserData()
                self.callAllHandler()
            }
            else
            {
//                print(error?.localizedDescription)
                if user == nil
                {
                    self.registerWithFirebae()
                }
            }
        }
    }
    
    func getFcmToken() -> String
    {
        if userFcmToken == ""
        {
            if let token = Messaging.messaging().fcmToken
            {
                userFcmToken = token
            }
        }
        return userFcmToken
    }
    
    func callAllHandler()
    {
        appUsersHandler()
 //       inboxListHandler()
        self.updateCurrentUserData()
    }
    
    func appUsersHandler()
    {
        appUsersRef.removeObserver(withHandle: appUsersRefHandler)
        
        appUsersRefHandler = appUsersRef.observe(DataEventType.value) { (snapshot : DataSnapshot) in
            
            AppModel.shared.USERS = [FirebaseUserModel]()
            var isCurrUserExist:Bool = false
            if snapshot.exists()
            {
                for child in snapshot.children {
                    
                    let user:DataSnapshot = child as! DataSnapshot
                    if let userDict = user.value as? [String : AnyObject]{
                        if AppModel.shared.validateUser(dict: userDict){
                            let userModel = FirebaseUserModel.init(dict: userDict)
                            if( AppModel.shared.firebaseCurrentUser != nil && AppModel.shared.firebaseCurrentUser.id == user.key)
                            {
                                AppModel.shared.firebaseCurrentUser = userModel
                                isCurrUserExist = true
                            }
                            else
                            {
                                AppModel.shared.USERS.append(userModel)
                            }
                        }
                    }
                }
            }
            if isCurrUserExist == true
            {
                self.updateCurrentUserData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
            }
        }
    }
    
    func updateCurrentUserData()
    {
        appUsersRef.child(AppModel.shared.firebaseCurrentUser.id).setValue(AppModel.shared.firebaseCurrentUser.dictionary())
    }
    
    @objc func startTyping()
    {
        if AppModel.shared.firebaseCurrentUser.isType == 0
        {
            AppModel.shared.firebaseCurrentUser.isType = 1
            AppDelegate().sharedDelegate().updateCurrentUserData()
        }
    }
    
    @objc func stopTyping()
    {
        if AppModel.shared.firebaseCurrentUser.isType == 1
        {
            AppModel.shared.firebaseCurrentUser.isType = 0
            AppDelegate().sharedDelegate().updateCurrentUserData()
        }
    }
    
    func updateLastSeen(isOnline : Bool)
    {
        if AppModel.shared.firebaseCurrentUser != nil
        {
            if AppModel.shared.firebaseCurrentUser.id.count > 0
            {
                if getDataFromPreference(key: "isLastSeenUpdate") != nil && getDataFromPreference(key: "isLastSeenUpdate") as! Bool == true
                {
                    if isOnline
                    {
                        AppModel.shared.firebaseCurrentUser.last_seen = ""
                        updateCurrentUserData()
                    }
                    else
                    {
                        AppModel.shared.firebaseCurrentUser.isType = 0
                        AppModel.shared.firebaseCurrentUser.last_seen = getCurrentTimeStampValue()
                        updateCurrentUserData()
                    }
                }
            }
        }
    }
    
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
//    func inboxListHandler()
//    {
//
//        inboxListRef.removeObserver(withHandle: inboxListRefHandler)
//        inboxListRefHandler = inboxListRef.observe(DataEventType.value) { (snapshot : DataSnapshot) in
//            AppModel.shared.INBOXLIST = [InboxListModel]()
//            if snapshot.exists()
//            {
//                var arrNewMsg : [String] = [String] ()
//                for child in snapshot.children {
//                    let channel:DataSnapshot = child as! DataSnapshot
//                    if let channelDict = channel.value as? [String : AnyObject]{
//                        if (self.isMyChanel(channelId: channelDict["id"] as! String)) && AppModel.shared.validateInbox(dict: channelDict)
//                        {
//                            let msgList : InboxListModel = InboxListModel.init(dict: channelDict)
//                            AppModel.shared.INBOXLIST.append(msgList)
//                            if msgList.lastMessage.status == 2 && self.inboxNewMessageNoti[msgList.lastMessage.msgId] == nil && msgList.lastMessage.otherUserId == AppModel.shared.firebaseCurrentUser.id
//                            {
//                                if let otherUser : FirebaseUserModel = self.getConnectUserDetail(channelId: msgList.id)
//                                {
//                                    msgList.lastMessage.status = 3
//                                    self.inboxNewMessageNoti[msgList.lastMessage.msgId] = true
//                                    arrNewMsg.append(msgList.id)
//
//                                    let vc : UIViewController = UIApplication.topViewController()!
//                                    if (vc is ChatViewController) && (vc as! ChatViewController).channelId == msgList.id {
//                                    }
//                                    else
//                                    {
//                                        if #available(iOS 10.0, *) {
//                                            self.showLocalPush(title: "New Message", subTitle: otherUser.name + ((msgList.lastMessage.text.decoded != "") ? (" : " + msgList.lastMessage.text.decoded) : " has sent story."), user: otherUser)
//                                        } else {
//                                            // Fallback on earlier versions
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                for i in 0..<arrNewMsg.count
//                {
//                    self.inboxListRef.child(arrNewMsg[i]).child("lastMessage").child("status").setValue(3)
//                }
//            }
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_INBOX_LIST), object: nil)
//            self.updateInboxMessageBadge()
//        }
//    }////comment on 4-Oct-2018
    
    func createChannel(connectUserId : String) -> String
    {
        if connectUserId != ""
        {
            var strIDArray : [String] = [connectUserId, AppModel.shared.firebaseCurrentUser.id]
            strIDArray = strIDArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            let tappedChannelId = strIDArray[0] + "-" + strIDArray[1]
            var isNewChannel : Bool = true
            
            let index = AppModel.shared.INBOXLIST.index { (channel) -> Bool in
                channel.id == tappedChannelId
            }
            
            if index != nil
            {
                isNewChannel = false
            }
            
            if isNewChannel
            {
                let dict : [String : Any] = ["id": tappedChannelId, "badge1": 0, "badge2": 0, "lastMessage": MessageModel.init(dict: [String:Any]())]
                let messgaeListModel : InboxListModel = InboxListModel.init(dict: dict)
                inboxListRef.child(tappedChannelId).setValue(messgaeListModel.dictionary())
            }
            return tappedChannelId
        }
        return ""
    }
    
    func onChannelTap(connectUser : FirebaseUserModel)
    {
        if connectUser == nil
        {
            return
        }
        let tappedChannelID = createChannel(connectUserId: connectUser.id)
        if tappedChannelID != ""
        {
            let rootNavigationVc : UINavigationController = self.window?.rootViewController as! UINavigationController
            if #available(iOS 10.0, *) {
                let vc : ChatViewController = STORYBOARD.MESSAGE.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.channelId = tappedChannelID
                vc.receiver = connectUser
                rootNavigationVc.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func getConnectUserDetail(channelId : String) -> FirebaseUserModel?
    {
        var otherUser : FirebaseUserModel?
        let arrtemp : [String] = channelId.components(separatedBy: "-")
        if(AppModel.shared.firebaseCurrentUser != nil && arrtemp[0] == AppModel.shared.firebaseCurrentUser.id){
            otherUser = getUserById(uID: arrtemp[1])
        }
        else{
            otherUser = getUserById(uID: arrtemp[0])
        }
        return otherUser
    }
    func getUserById(uID : String) -> FirebaseUserModel?
    {
        if AppModel.shared.firebaseCurrentUser != nil && uID == AppModel.shared.firebaseCurrentUser.id
        {
            return AppModel.shared.firebaseCurrentUser
        }
        let index = AppModel.shared.USERS.index { (user) -> Bool in
            user.id == uID
        }
        
        if index == nil
        {
            return nil
        }
        else
        {
            return AppModel.shared.USERS[index!]
        }
    }
    func getCurrentUserBadgeKey(_ channelID : String) -> String
    {
        let arrTemp : [String] = channelID.components(separatedBy: "-")
        if arrTemp[0] == AppModel.shared.firebaseCurrentUser.id {
            return "badge1"
        }
        return "badge2"
    }
    
    func getOtherUserBadgeKey(channelID : String) -> String
    {
        let arrTemp : [String] = channelID.components(separatedBy: "-")
        if arrTemp[0] == AppModel.shared.firebaseCurrentUser.id {
            return "badge2"
        }
        return "badge1"
    }
    
    func getOtherUserID(channelID : String) -> String
    {
        let arrTemp : [String] = channelID.components(separatedBy: "-")
        if arrTemp[0] == AppModel.shared.firebaseCurrentUser.id {
            return arrTemp[1]
        }
        return arrTemp[0]
    }
    
    func isMyChanel(channelId : String) -> Bool
    {
        if channelId == "" || AppModel.shared.firebaseCurrentUser == nil
        {
            return false
        }
        let arrtemp : [String] = channelId.components(separatedBy: "-")
        if (arrtemp[0] == AppModel.shared.firebaseCurrentUser.id) || (arrtemp[1] == AppModel.shared.firebaseCurrentUser.id)
        {
            return true
        }
        return false
    }
    
//    func onSendMessage(message : MessageModel, chanelId : String)
//    {
//        message.status = 2
//        messageListRef.child(chanelId).child(message.key).child("status").setValue(message.status)
//
////        updateLastMessageInInbox(message: message, chanelId: chanelId)
//
//        let otherUserBadgeKey : String = getOtherUserBadgeKey(channelID: chanelId)
//        var otherUserBadge : Int = 1
//        let index = AppModel.shared.INBOXLIST.index { (inbox) -> Bool in
//            inbox.id == chanelId
//        }
//
//        if index != nil
//        {
//            let inboxList : InboxListModel = AppModel.shared.INBOXLIST[index!]
//            if otherUserBadgeKey == "badge1" {
//                inboxList.badge1 = inboxList.badge1 + 1
//                otherUserBadge = inboxList.badge1
//            }
//            else
//            {
//                inboxList.badge2 = inboxList.badge2 + 1
//                otherUserBadge = inboxList.badge2
//            }
//            inboxList.lastMessage = message
//        }
//        inboxListRef.child(chanelId).child(otherUserBadgeKey).setValue(otherUserBadge)
//
//        let index1 = AppModel.shared.USERS.index { (user) -> Bool in
//            user.id == message.otherUserId
//        }
//        if index1 != nil
//        {
//            if AppModel.shared.USERS[index1!].last_seen != ""
//            {
//                sendPush(title: "Tutable", body: ("You have new Message from " + AppModel.shared.firebaseCurrentUser.name), user: AppModel.shared.USERS[index1!], type: "1")
//
//                message.status = 3
//            }
//        }
//        inboxListRef.child(chanelId).child("lastMessage").setValue(message.dictionary())
//
//    }////comment on 4-Oct-2018
    
    func sendPush(title:String, body:String, user:FirebaseUserModel, type : String)
    {
        let url  = NSURL(string: "https://fcm.googleapis.com/fcm/send")
        
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("key=AAAALnVHhAA:APA91bEBmP8SvYENsJx7V60NDO4PUPp6tkyend81vgvhse94PFV8xBQe3DQ3C7copj64q2GDPcwLAS4fecFK-5iwtYAwW-nG9G_hBqXjEoXflhjP8f9VVvgJf9Ni5c-vcciiLq0T4eAV", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "POST"
        
        //badge
        let userBadge : Int = user.badge + 1
        self.appUsersRef.child(user.id).child("badge").setValue(userBadge)
        
        let sessionConfig = URLSessionConfiguration.default
        
        let token = user.fcmToken
        let json = ["to":token!,
                    "priority":"high",
                    "content_available":true,
                    "notification":["sound" : "default", "badge" : String(userBadge), "body":body,"title":title]] as [String : Any]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = jsonData
            
            let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            let datatask = urlSession.dataTask(with: request as URLRequest) { (data, response, error) in
                if data != nil
                {
                    let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Body: \(String(describing: strData))")
                    print(response ?? "",data ?? "")
                    print(error ?? "")
                    
                }
                
            }
            
            datatask.resume()
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    @available(iOS 10.0, *)
    func showLocalPush(title : String, subTitle : String, user : FirebaseUserModel)
    {
        
        let index = AppModel.shared.USERS.index(where: { (tempUser) -> Bool in
            tempUser.id == user.id
        })
        
        if index != nil
        {
            
            let uploadContent = UNMutableNotificationContent()
            uploadContent.title = title
            uploadContent.body = subTitle
            uploadContent.userInfo = ["user" : user.dictionary()]
            uploadContent.categoryIdentifier = "CHAT"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let uploadRequestIdentifier = "myChatIdentifier"
            let uploadRequest = UNNotificationRequest(identifier: uploadRequestIdentifier, content: uploadContent, trigger: trigger)
            UNUserNotificationCenter.current().add(uploadRequest, withCompletionHandler: nil)
        }
    }
    
//    func updateLastMessageInInbox(message : MessageModel, chanelId : String)
//    {
//        message.status = 3
//        inboxListRef.child(chanelId).child("date").setValue(message.date)
//        inboxListRef.child(chanelId).child("lastMessage").setValue(message.dictionary())
//    }////comment on 4-Oct-2018
//
//    func onGetMessage(message : MessageModel, chanelId : String)
//    {
//        let myBadgeKey : String = getCurrentUserBadgeKey(chanelId)
//        let index = AppModel.shared.INBOXLIST.index { (inbox) -> Bool in
//            inbox.id == chanelId
//        }
//        if index != nil
//        {
//            let inboxList : InboxListModel = AppModel.shared.INBOXLIST[index!]
//            if myBadgeKey == "badge1" {
//                inboxList.badge1 = 0
//            }else{
//                inboxList.badge2 = 0
//            }
//            inboxListRef.child(chanelId).child(myBadgeKey).setValue(0)
//        }
//    }//comment on 4-Oct-2018
    
//    func updateInboxMessageBadge()
//    {
//        var unreadBadge : Int = 0
//
//        for temp in AppModel.shared.INBOXLIST
//        {
//            if (isMyChanel(channelId: temp.id))
//            {
//                if getCurrentUserBadgeKey(temp.id) == "badge1"
//                {
//                    unreadBadge = unreadBadge + temp.badge1
//                }
//                else
//                {
//                    unreadBadge = unreadBadge + temp.badge2
//                }
//            }
//        }
//        AppModel.shared.firebaseCurrentUser.badge = unreadBadge
//        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NOTIFICATION.UPDATE_MESSAGE_BADGE), object: nil)
//    }//comment on 4-Oct-2018
    
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
        DispatchQueue.main.async {
            self.window?.isUserInteractionEnabled = true
        }
       
        if activityLoader == nil
        {
            return
        }
        activityLoader.stopAnimating()
        activityLoader.removeFromSuperview()
        activityLoader = nil
    }
    
    func getDateTimeValueFromSlot(_ slot : [String : Any]) -> String
    {
        var timestamp : Double = 0.0
        var timeSlot : String = ""
        for temp in slot
        {
            timestamp = Double(temp.key)!
            timeSlot = temp.value as! String
        }
        var strDateTime : String = getDateStringFromDate(date: getDateFromTimeStamp(timestamp), format: "MMM dd") + ", "
        let timeArr : [String] = timeSlot.components(separatedBy: "-")
        let startTime : String = timeArr[0]
        let endTime : String = timeArr[1]
        
        if Int(startTime)! > 12
        {
            strDateTime = strDateTime + String(Int(startTime)! - 12) + " pm to "
        }
        else
        {
            strDateTime = strDateTime + startTime + " am to "
        }
        
        if Int(endTime)! > 12
        {
            strDateTime = strDateTime + String(Int(endTime)! - 12) + " pm"
        }
        else
        {
            strDateTime = strDateTime + endTime + " am"
        }
        return strDateTime
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.contains("com.googleusercontent.apps"))
        {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // MARK: - Core Data stack
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TutableModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @available(iOS 10.0, *)
    func sortAllCoreData()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        var messagesArr: [NSManagedObject] = [NSManagedObject] ()
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA.MESSAGE.TABLE_NAME)
        
        do {
            messagesArr = try managedContext.fetch(fetchRequest)
            deleteAllMessageFromCoreData("")
            
            let entity = NSEntityDescription.entity(forEntityName: COREDATA.MESSAGE.TABLE_NAME,
                                                    in: managedContext)!
            
            for tempMsg in messagesArr
            {
                var message = NSManagedObject(entity: entity, insertInto: managedContext)
                message = tempMsg
                do {
                    try managedContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @available(iOS 10.0, *)
    func deleteAllMessageFromCoreData(_ channelId : String)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA.MESSAGE.TABLE_NAME)
        do {
            let messagesArr: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            
            for msg in messagesArr
            {
                if channelId == ""
                {
                    managedContext.delete(msg)
                }
                else if msg.value(forKey: COREDATA.MESSAGE.key) as! String == channelId
                {
                    managedContext.delete(msg)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        updateLastSeen(isOnline: false)
        deleteAllData("Message")
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        updateLastSeen(isOnline: true)
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        updateLastSeen(isOnline: false)
    }

    //MARK:- Notification
    func registerPushNotification(_ application: UIApplication)
    {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        if getDeviceToken() == ""
        {
            setDeviceToken(value: token)
        }
    }
    
    func updateDeviceToken()
    {
        if getDeviceToken() == ""
        {
            return
        }
        let dict : [String : Any] = ["deviceId":getDeviceToken()]
        if isStudentLogin()
        {
            APIManager.sharedInstance.serviceCallToUpdateStudentDetail(dict, pictureData: Data(), completion: {
                
            })
        }
        else
        {
            APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: Data(), pictureData: Data(), completion: {
                
            })
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        // This notification is not auth related, developer should handle it.
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        //application.applicationIconBadgeNumber = Int((userInfo["aps"] as! [String : Any])["badge"] as! String)!
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        userFcmToken = fcmToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        _ = notification.request.content.userInfo
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.content.categoryIdentifier == "CHAT"
        {
            if let dict : [String : Any] = userInfo["user"] as? [String : Any]
            {
                let user : FirebaseUserModel = FirebaseUserModel.init(dict: dict)
                onChannelTap(connectUser: user)
            }
        }
        else if UIApplication.shared.applicationState == .inactive
        {
            _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(delayForNotification(tempTimer:)), userInfo: userInfo, repeats: false)
        }
        else
        {
            notificationHandler(userInfo as! [String : Any])
        }
        
        completionHandler()
    }
    
    @objc func delayForNotification(tempTimer:Timer)
    {
        notificationHandler(tempTimer.userInfo as! [String : Any])
    }
    
    //Redirect to screen
    func notificationHandler(_ dict : [String : Any])
    {
        print(dict)
        if isUserLogin()
        {
            if dict["gcm.message_id"] != nil
            {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NOTIFICATION.REDIRECT_TO_MESSAGE), object: nil)
            }
            else
            {
                let vc : NotificationVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
                {
                    rootNavigatioVC.pushViewController(vc, animated: false)
                }
            }
        }
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
