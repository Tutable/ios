//
//  ChatViewController.swift
//  LIT NITE
//
//  Created by Keyur on 23/02/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData
import IQKeyboardManagerSwift

@available(iOS 10.0, *)
class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var lastSeenLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var msgTextView: UITextView!
//    @IBOutlet weak var constraintHeightTblView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightMsgTextView: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomMsgTextView: NSLayoutConstraint!
    
    @IBOutlet var sendImageContainerVIew: UIView!
    @IBOutlet weak var receiverImgBtn: UIButton!
    @IBOutlet weak var sendImgView: UIImageView!
    @IBOutlet weak var imageAddCaptionTxt: UITextField!
    
    var channelId : String!
    var receiver : FirebaseUserModel!
    
    var messagesRef:DatabaseReference!
    var messagesRefHandler : UInt = 0
    var updateMessagesRefHandler : UInt = 0
    var messages:[MessageModel] = [MessageModel]()
    var coreDataMsgDict : [String : Bool] = [String : Bool] ()
    var newSendMessagesArr:[String : Bool] = [String : Bool] () //message id
    
    var offscreenCellSender : [String : Any] = [String : Any] ()
    var offscreenCellSenderImg : [String : Any] = [String : Any] ()
    var offscreenCellReceiver : [String : Any] = [String : Any] ()
    var offscreenCellReceiverImg : [String : Any] = [String : Any] ()
    var lastSeenTimer : Timer!
    
    var uploadImage : UIImage!
    
    var isAppear:Bool = false
    var otherUserStatus : UIColor = colorFromHex(hex: COLOR.APP_COLOR)
    var loginUserStatus : UIColor = colorFromHex(hex: COLOR.APP_COLOR)
    
    var typeTimer : Timer = Timer()
    var strPalceholder : String = "Please type your message.."
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().enable = true
        isAppear = false
        AppDelegate().sharedDelegate().stopTyping()
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
        isAppear = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = false
        self.fetchFirebaseMessages()
        self.onUpdateFirebaseMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLastSeen), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateStories), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_STORIES), object: nil)
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        tblView.register(UINib.init(nibName: "SendChatMessageTVC", bundle: nil), forCellReuseIdentifier: "SendChatMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverChatMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverChatMessageTVC")
        tblView.register(UINib.init(nibName: "SenderImageMessageTVC", bundle: nil), forCellReuseIdentifier: "SenderImageMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverImageMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageTVC")
        
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView()
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        
        msgView.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.LIGHT_GRAY))
        msgView.addCornerRadiusOfView(msgView.frame.size.height/2)
        msgTextView.delegate = self
        msgTextView.text = strPalceholder
        msgTextView.textColor = colorFromHex(hex: COLOR.LIGHT_GRAY)
        msgTextView.textContainerInset = UIEdgeInsetsMake(2, 5, 0, 5)
        messagesRef = Database.database().reference().child("MESSAGES").child(channelId)
 
        continueFetchData()
    }
    
    
    
    func continueFetchData()
    {
        //deleteAllMessageFromCoreData()
        fetchCoreDataMessages()
        updateUserLastSeen()
    }
    
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            
            DispatchQueue.main.async {
                self.constraintBottomMsgTextView.constant = height
                delay(0.01, closure: {
                    if self.tblView != nil &&  self.messages.count > 0
                    {
                        self.tblView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    }
                })
            }
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        self.constraintBottomMsgTextView.constant = 0
        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.scrollTableviewToBottom), userInfo: nil, repeats: false)
    }
    
    //MARK:- Update func
    
    @objc func updateUserLastSeen()
    {
        if tblView == nil
        {
            return
        }
        if channelId == nil || channelId.count == 0
        {
            return
        }
        
        let index = AppModel.shared.USERS.index { (temp) -> Bool in
            temp.id == receiver.id
        }
        if index != nil
        {
            receiver = AppModel.shared.USERS[index!]
        }
        
        if receiver.name == ""
        {
            userNameLbl.text = "CHAT"
        }
        else
        {
            var fname : String = receiver.name
            if fname.contains(" ")
            {
                let tempArr : [String] = fname.components(separatedBy: " ")
                fname = tempArr[0]
            }
            userNameLbl.text = "TALKING TO " + fname
        }
        userNameLbl.text = userNameLbl.text?.uppercased()
        
        if receiver.isType == 1
        {
            lastSeenLbl.text = "typing..."
        }
        else if receiver.last_seen.count == 0 {
            lastSeenLbl.text = "Online"
            if lastSeenTimer != nil && lastSeenTimer.isValid
            {
                lastSeenTimer.invalidate()
            }
            otherUserStatus = colorFromHex(hex: COLOR.APP_COLOR)
        }
        else
        {
            lastSeenLbl.text = getDifferenceFromCurrentTimeInHourInDays(Double(receiver.last_seen)!)
            lastSeenTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateUserLastSeen), userInfo: nil, repeats: false)
            if getDifferenceFromCurrentTime(Double(receiver.last_seen)!) < 60
            {
                otherUserStatus = colorFromHex(hex: COLOR.ORANGE_COLOR)
            }
            else
            {
                otherUserStatus = colorFromHex(hex: COLOR.LIGHT_GRAY)
            }
        }
//        tblView.reloadData()
    }
    
    @objc func onUpdateStories()
    {
        if tblView == nil
        {
            return
        }
        fetchCoreDataMessages()
    }
    
    //MARK:- messages
    
    @available(iOS 10.0, *)
    func fetchCoreDataMessages(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        messages = [MessageModel]()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: COREDATA.MESSAGE.TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "channeld == %@",channelId)
        // Add Sort Descriptors
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "channeld", ascending: true), NSSortDescriptor(key: "msgId", ascending: true)]
        
        // Initialize Asynchronous Fetch Request
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousFetchResult) -> Void in
            DispatchQueue.main.async {
                if let result = asynchronousFetchResult.finalResult {
                    
                    // Update Items
                    let messagesArr: [NSManagedObject] = result as! [NSManagedObject]
                    
                    for i in 0..<messagesArr.count
                    {
                        let msg : NSManagedObject = messagesArr[i]
                        
                        let dict : [String : Any] = ["msgId": msg.value(forKey: COREDATA.MESSAGE.msgID) as! String, "key" : msg.value(forKey: COREDATA.MESSAGE.key) as! String, "otherUserId": msg.value(forKey: COREDATA.MESSAGE.otherUserId) as! String, "date": msg.value(forKey: COREDATA.MESSAGE.date) as! String, "text": msg.value(forKey: COREDATA.MESSAGE.text) as! String, "status":msg.value(forKey: COREDATA.MESSAGE.status) as! Int]
                        let tempMsg : MessageModel = MessageModel.init(dict: dict)
                        self.messages.append(tempMsg)
                        self.coreDataMsgDict[tempMsg.msgId] = true
                        if i == messagesArr.count-1
                        {
                            AppDelegate().sharedDelegate().updateLastMessageInInbox(message: tempMsg, chanelId: self.channelId)
                        }
                    }
                    self.tblView.reloadData()
                    self.scrollTableviewToBottom()
                }
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            let asynchronousFetchResult = try managedContext.execute(asynchronousFetchRequest)
            
            print(asynchronousFetchResult)
            
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    
    func fetchFirebaseMessages()
    {
        messagesRefHandler =  messagesRef.observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            if(self.isAppear == false){
                return
            }
            if(snapshot.exists())
            {
                let msgDict = snapshot.value as? [String : AnyObject] ?? [:]
                let message : MessageModel = MessageModel.init(dict: msgDict)
                
                if let _ = self.newSendMessagesArr[message.msgId]
                {}
                else{
                    if let _ = self.coreDataMsgDict[message.msgId]{
                        //skip firebase message if its save in core data
                    }
                    else if (message.status != 1 || message.otherUserId != AppModel.shared.firebaseCurrentUser.id)
                    {
                        self.addMessage(message)
                        if message.otherUserId == AppModel.shared.firebaseCurrentUser.id
                        {
                            AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                        }
                        
                    }
                }
            }
        }
    }
    func onUpdateFirebaseMessages(){
        updateMessagesRefHandler = messagesRef.observe(DataEventType.childChanged) { (snapshot : DataSnapshot) in
            if(self.isAppear == false){
                return
            }
            if(snapshot.exists())
            {
                let msgDict = snapshot.value as? [String : AnyObject] ?? [:]
                let message : MessageModel = MessageModel.init(dict: msgDict)
                
                if let _ = self.coreDataMsgDict[message.msgId]
                {
                    self.updateMessage(message)
                }
                else
                {
                    if (message.status != 1 || message.otherUserId != AppModel.shared.firebaseCurrentUser.id){
                        self.addMessage(message)
                        if message.otherUserId == AppModel.shared.firebaseCurrentUser.id
                        {
                            AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                        }
                    }
                    
                }
            }
            
        }
    }
    
    func addMessage(_ newMessage:MessageModel){
        
        messages.append(newMessage)
        coreDataMsgDict[newMessage.msgId] = true
//        self.tblView.reloadData()
        self.tblView.beginUpdates()
        self.tblView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
        self.tblView.endUpdates()
        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.scrollTableviewToBottom), userInfo: nil, repeats: false)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: COREDATA.MESSAGE.TABLE_NAME,
                                                in: managedContext)!
        
        let message = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        message.setValue(newMessage.msgId, forKey: COREDATA.MESSAGE.msgID)
        message.setValue(newMessage.otherUserId, forKey: COREDATA.MESSAGE.otherUserId)
        message.setValue(newMessage.date, forKey: COREDATA.MESSAGE.date)
        message.setValue(newMessage.key, forKey: COREDATA.MESSAGE.key)
        message.setValue(newMessage.status, forKey: COREDATA.MESSAGE.status)
        message.setValue(newMessage.text, forKey: COREDATA.MESSAGE.text)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func updateMessage(_ message:MessageModel){
        
        let index = self.messages.index(where: { (temp) -> Bool in
            temp.msgId == message.msgId
        })
        if(index != nil){
            self.messages[index!] = message
            self.tblView.beginUpdates()
            self.tblView.reloadRows(at: [IndexPath(row:index!, section:0)], with: .automatic)
            self.tblView.endUpdates()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA.MESSAGE.TABLE_NAME)
            fetchRequest.predicate = NSPredicate(format: "%@ = %@ AND %@ = %@",COREDATA.MESSAGE.key,channelId,COREDATA.MESSAGE.msgID,message.msgId)
            do {
                let messagesArr: [NSManagedObject] = try managedContext.fetch(fetchRequest)
                
                if(messagesArr.count == 1)
                {
                    let msgUpdate = messagesArr[0]
                    msgUpdate.setValue(channelId, forKeyPath: COREDATA.MESSAGE.key)
                    msgUpdate.setValue(message.msgId, forKey: COREDATA.MESSAGE.msgID)
                    msgUpdate.setValue(message.otherUserId, forKey: COREDATA.MESSAGE.otherUserId)
                    msgUpdate.setValue(message.date, forKey: COREDATA.MESSAGE.date)
                    msgUpdate.setValue(message.key, forKey: COREDATA.MESSAGE.key)
                    msgUpdate.setValue(message.status, forKey: COREDATA.MESSAGE.status)
                    msgUpdate.setValue(message.text, forKey: COREDATA.MESSAGE.text)
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not update. \(error), \(error.userInfo)")
                    }
                    
                }
                
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
            
        }
    }
    
    // MARK: - Button click event
    
    @IBAction func clickToBack(_ sender: Any)
    {
        self.view.endEditing(true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_INBOX_LIST), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSend(_ sender: Any)
    {
//        self.view.endEditing(true)
        msgTextView.text = msgTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if msgTextView.text != ""
        {
            let newMsgRef : DatabaseReference = messagesRef.childByAutoId()
            let dict : [String : Any] = ["msgId": getCurrentTimeStampValue(), "key" : newMsgRef.key, "otherUserId": receiver.id, "date": getCurrentTimeStampValue(), "text": msgTextView.text.encoded, "status":2]
            let msgModel: MessageModel = MessageModel.init(dict: dict)
            addMessage(msgModel)
            newSendMessagesArr[msgModel.msgId] = true
            newMsgRef.setValue(msgModel.dictionary())
            msgTextView.text = ""
            constraintHeightMsgTextView.constant = 50
            AppDelegate().sharedDelegate().onSendMessage(message: msgModel, chanelId: channelId)
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MessageCell!
        
        let dict : MessageModel = messages[indexPath.row]
        
        if dict.otherUserId != AppModel.shared.firebaseCurrentUser.id {
            //sender message
            cell = tblView.dequeueReusableCell(withIdentifier: "SendChatMessageTVC", for: indexPath) as! MessageCell
            APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.firebaseCurrentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.profilePicBtn])
            cell.statusImgView.backgroundColor = loginUserStatus
            cell.durationLbl.text = getDifferenceFromCurrentTimeInHourInDays(Double(dict.date)!)
        }
        else{
            cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverChatMessageTVC", for: indexPath) as! MessageCell
            APIManager.sharedInstance.serviceCallToGetPhoto(receiver.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.profilePicBtn])
            cell.statusImgView.backgroundColor = otherUserStatus
            cell.durationLbl.text = getDifferenceFromCurrentTimeInHourInDays(Double(dict.date)!)
        }
        
        if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
        {
            cell.headerLbl.text = getdayDifferenceFromCurrentDay(Double(dict.date)!)
        }
        else
        {
            cell.headerLbl.text = ""
        }
        if indexPath.row > 0  && dict.otherUserId == messages[indexPath.row-1].otherUserId
        {
            cell.profilePicView.isHidden = true
            cell.statusImgView.isHidden = true
            cell.arrowBtn.isHidden = true
        }
        else
        {
            cell.profilePicView.isHidden = false
            cell.statusImgView.isHidden = false
            cell.arrowBtn.isHidden = false
        }
        
        var extraSpace : CGFloat = 2
        if indexPath.row != 0 && dict.otherUserId != messages[indexPath.row-1].otherUserId
        {
            extraSpace = 5
        }
        cell.constraintTopSpace.constant = extraSpace
        cell.messageTxtView.text = dict.text.decoded
        cell.messageTxtView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.blue, NSAttributedStringKey.underlineStyle.rawValue : 1]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        msgTextView.resignFirstResponder()
        constraintBottomMsgTextView.constant = 0
    }
    
    // MARK: - TextView delegate
    func textViewDidChange(_ textView: UITextView)
    {
        if textView == msgTextView
        {
            AppDelegate().sharedDelegate().startTyping()
            if msgTextView.contentSize.height > 70 {
                constraintHeightMsgTextView.constant = 70 + 20
            }
            else
            {
                constraintHeightMsgTextView.constant = msgTextView.contentSize.height + 20
                if constraintHeightMsgTextView.constant < 50
                {
                    constraintHeightMsgTextView.constant = 50
                }
            }
            //setTblViewHeight()
            typeTimer.invalidate()
            typeTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(stopTyping), userInfo: nil, repeats: false)
        }
    }
    
    @objc func stopTyping()
    {
        AppDelegate().sharedDelegate().stopTyping()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            clickToSend(self)
            return false
        }
        return true
    }
    
    @objc func scrollTableviewToBottom()
    {
        if self.tblView != nil &&  self.messages.count > 0
        {
            self.tblView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        AppDelegate().sharedDelegate().stopTyping()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == colorFromHex(hex: COLOR.LIGHT_GRAY) {
            textView.text = nil
            textView.textColor = colorFromHex(hex: COLOR.DARK_TEXT)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = strPalceholder
            textView.textColor = colorFromHex(hex: COLOR.LIGHT_GRAY)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
