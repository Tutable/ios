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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

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
    //Firebase Chat end
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        UIApplication.shared.statusBarView?.backgroundColor = colorFromHex(hex: COLOR.APP_COLOR)
//        UIApplication.shared.statusBarStyle = .lightContent
    
        application.statusBarStyle = .lightContent
        
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
        
        //Firebase chat start
        FirebaseApp.configure()
        
        //create Table
        appUsersRef = Database.database().reference().child("USERS")
        inboxListRef = Database.database().reference().child("INBOX")
        messageListRef = Database.database().reference().child("MESSAGES")
        
        setDataToPreference(data: false as AnyObject, forKey: "isLastSeenUpdate")
        //Firebase Chat end
        
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
                    print(finalDict)
                    APIManager.sharedInstance.serviceCallToSocialLogin(finalDict, completion: { (code) in
                        if code == 100
                        {
                            setSocialLoginUser()
                            if isStudentLogin()
                            {
                                self.navigateToDashboard()
                            }
                        }
                    })
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
            print(finalDict)
            APIManager.sharedInstance.serviceCallToSocialLogin(finalDict, completion: { (code) in
                if code == 100
                {
                    setSocialLoginUser()
                    if isStudentLogin()
                    {
                        self.navigateToDashboard()
                    }
                }
            })
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
        setLoginUserData(AppModel.shared.currentUser.dictionary())
        customTabbarVc = self.storyboard().instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        
        if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
        {
            rootNavigatioVC.pushViewController(customTabbarVc, animated: false)
        }
        getCategory()
        
        print("==================\n\nDeviceID : " + getDeviceToken() + "\n\n==================")
        
        setupFirebase()
    }
    
    //MARK:- Logout
    func logoutApp()
    {
        let deviceToken : String = getDeviceToken()
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
        
        navigateToLogin()
        setDeviceToken(value: deviceToken)
        
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
        else if AppModel.shared.currentUser.qualification == ""
        {
            redirectionType = 3
        }
        else if AppModel.shared.currentUser.school == ""
        {
            redirectionType = 3
        }
        else if AppModel.shared.currentUser.degreeAsset == ""
        {
            redirectionType = 3
        }
        
        
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
            loginWithFirebase()
        }
    }
    
    func registerWithFirebae()
    {
        Auth.auth().createUser(withEmail: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email) { (user, error) in
            if error == nil
            {
                AppModel.shared.isFCMConnected = true
                AppModel.shared.firebaseCurrentUser = FirebaseUserModel.init(dict: AppModel.shared.currentUser.dictionary())
                AppModel.shared.firebaseCurrentUser.fcmToken = getDeviceToken()
                self.appUsersRef.child(AppModel.shared.firebaseCurrentUser.id).setValue(AppModel.shared.firebaseCurrentUser.dictionary())
                self.callAllHandler()
            }
            else
            {
                print(error?.localizedDescription)
            }
        }
    }
    
    func loginWithFirebase()
    {
        Auth.auth().signIn(withEmail: AppModel.shared.currentUser.email, password: AppModel.shared.currentUser.email) { (user, error) in
            if error == nil
            {
                AppModel.shared.isFCMConnected = true
                self.appUsersHandler()
            }
            else
            {
                print(error?.localizedDescription)
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
            userFcmToken = Messaging.messaging().fcmToken!
        }
        return userFcmToken
    }
    
    func callAllHandler()
    {
        appUsersHandler()
        inboxListHandler()
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
            }
        }
    }
    
    func updateCurrentUserData()
    {
        appUsersRef.child(AppModel.shared.firebaseCurrentUser.id).setValue(AppModel.shared.firebaseCurrentUser.dictionary())
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
                        AppModel.shared.firebaseCurrentUser.last_seen = getCurrentTimeStampValue()
                        updateCurrentUserData()
                    }
                }
            }
        }
    }
    
    func inboxListHandler()
    {
        inboxListRef.removeObserver(withHandle: inboxListRefHandler)
        inboxListRefHandler = inboxListRef.observe(DataEventType.value) { (snapshot : DataSnapshot) in
            AppModel.shared.INBOXLIST = [InboxListModel]()
            if snapshot.exists()
            {
                for child in snapshot.children {
                    let channel:DataSnapshot = child as! DataSnapshot
                    if let channelDict = channel.value as? [String : AnyObject]{
                        if AppModel.shared.validateInbox(dict: channelDict)
                        {
                            let msgList : InboxListModel = InboxListModel.init(dict: channelDict)
                            AppModel.shared.INBOXLIST.append(msgList)
                        }
                    }
                }
            }
        }
    }
    
    func createChannel(connectUserId : String) -> String
    {
        if connectUserId != ""
        {
            var strIDArray : [String] = [connectUserId, AppModel.shared.firebaseCurrentUser.id]
            //            strIDArray = strIDArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
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
                let dict : [String : Any] = ["conversationKey": tappedChannelId, "owner": connectUserId, "user": AppModel.shared.firebaseCurrentUser.id, "date" : getCurrentTimeStampValue(), "lastMessage": MessageModel.init(dict: [String:Any]())]
                let messgaeListModel : InboxListModel = InboxListModel.init(dict: dict)
                inboxListRef.child(tappedChannelId).setValue(messgaeListModel.dictionary())
            }
            
            
            return tappedChannelId
        }
        return ""
    }
    
    func onChannelTap(connectUser : FirebaseUserModel)
    {
        let tappedChannelID = createChannel(connectUserId: connectUser.id)
        if tappedChannelID != ""
        {
            let rootNavigationVc : UINavigationController = self.window?.rootViewController as! UINavigationController
            if #available(iOS 10.0, *) {
                let vc : ChatViewController = self.storyboard().instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.channelId = tappedChannelID
                vc.receiver = connectUser
                rootNavigationVc.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
            }
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
        let arrtemp : [String] = channelId.components(separatedBy: "-")
        if (arrtemp[0] == AppModel.shared.firebaseCurrentUser.id) || (arrtemp[1] == AppModel.shared.firebaseCurrentUser.id)
        {
            return true
        }
        return false
    }
    
    func onSendMessage(message : MessageModel, chanelId : String)
    {
        message.status = 2
        messageListRef.child(chanelId).child(message.key).child("status").setValue(message.status)
        
        updateLastMessageInInbox(message: message, chanelId: chanelId)
    }
    
    func updateLastMessageInInbox(message : MessageModel, chanelId : String)
    {
        message.status = 3
        inboxListRef.child(chanelId).child("date").setValue(message.date)
        inboxListRef.child(chanelId).child("lastMessage").setValue(message.dictionary())
    }
    
    func onGetMessage(message : MessageModel, chanelId : String)
    {
        /*
         let myBadgeKey : String = getCurrentUserBadgeKey(chanelId)
         let index = AppModel.shared.INBOXLIST.index { (inbox) -> Bool in
         inbox.conversationKey == chanelId
         }
         
         if index != nil
         {
         let inboxList : InboxListModel = AppModel.shared.INBOXLIST[index!]
         if myBadgeKey == "badge1" {
         inboxList.badge1 = 0
         }
         else
         {
         inboxList.badge2 = 0
         }
         //inboxList.lastMessage = message
         inboxListRef.child(chanelId).child(myBadgeKey).setValue(0)
         }
         //inboxListRef.child(chanelId).child("lastMessage").child("badge1")
         */
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
        if UIApplication.shared.applicationState == .inactive
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
            let vc : NotificationVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            if let rootNavigatioVC : UINavigationController = self.window?.rootViewController as? UINavigationController
            {
                rootNavigatioVC.pushViewController(vc, animated: false)
            }
        }
    }
}

