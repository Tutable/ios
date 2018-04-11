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

@available(iOS 10.0, *)
class ChatViewController: UIViewController, UITextViewDelegate, PhotoSelectionDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var lastSeenLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var constraintHeightTblView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightMsgTextView: NSLayoutConstraint!
    
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
    
    var _PhotoSelectionVC:PhotoSelectionVC!
    var uploadImage : UIImage!
    
    var isAppear:Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        isAppear = false
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        isAppear = true
    }
    override func viewDidAppear(_ animated: Bool) {
        self.fetchFirebaseMessages()
        self.onUpdateFirebaseMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLastSeen), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateStories), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_STORIES), object: nil)
        
        tblView.register(UINib.init(nibName: "SendChatMessageTVC", bundle: nil), forCellReuseIdentifier: "SendChatMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverChatMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverChatMessageTVC")
        tblView.register(UINib.init(nibName: "SenderImageMessageTVC", bundle: nil), forCellReuseIdentifier: "SenderImageMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverImageMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageTVC")
        
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        
        msgTextView.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        msgTextView.addCornerRadiusOfView(0)
        msgTextView.delegate = self
        
        messagesRef = Database.database().reference().child("MESSAGES").child(channelId)
 
        continueFetchData()
        
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
    }
    
    func continueFetchData()
    {
        //deleteAllMessageFromCoreData()
        fetchCoreDataMessages()
        updateUserLastSeen()
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
        
        if receiver.firstName == ""
        {
            userNameLbl.text = "Chat"
        }
        else
        {
            userNameLbl.text = receiver.firstName
        }
        
        if receiver.last_seen.count == 0 {
            lastSeenLbl.text = "Online"
            if lastSeenTimer != nil && lastSeenTimer.isValid
            {
                lastSeenTimer.invalidate()
            }
        }
        else
        {
            lastSeenLbl.text = getDifferenceFromCurrentTimeInHourInDays(Double(receiver.last_seen)!)
            lastSeenTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateUserLastSeen), userInfo: nil, repeats: false)
        }
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
                        let dict : [String : Any] = ["msgId": msg.value(forKey: COREDATA.MESSAGE.msgID) as! String, "key" : msg.value(forKey: COREDATA.MESSAGE.key) as! String, "sender": msg.value(forKey: COREDATA.MESSAGE.SENDER) as! String, "userName": msg.value(forKey: COREDATA.MESSAGE.USER_NAME) as! String, "receiver": msg.value(forKey: COREDATA.MESSAGE.RECEIVER) as! String, "ownerName": msg.value(forKey: COREDATA.MESSAGE.OWNER_NAME) as! String, "date": msg.value(forKey: COREDATA.MESSAGE.date) as! String, "text": msg.value(forKey: COREDATA.MESSAGE.text) as! String, "type" : msg.value(forKey: COREDATA.MESSAGE.type) as! Int, "status":msg.value(forKey: COREDATA.MESSAGE.status) as! Int, "local_picture" : msg.value(forKey: COREDATA.MESSAGE.local_picture) as! String, "remote_picture" : msg.value(forKey: COREDATA.MESSAGE.remote_picture) as! String]
                        let tempMsg : MessageModel = MessageModel.init(dict: dict)
                        self.messages.append(tempMsg)
                        self.coreDataMsgDict[tempMsg.msgId] = true
                        if i == messagesArr.count-1
                        {
                            AppDelegate().sharedDelegate().updateLastMessageInInbox(message: tempMsg, chanelId: self.channelId)
                        }
                    }
                    self.tblView.reloadData()
                    self.setTblViewHeight()
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
                    else if (message.status != 1 || message.sender != AppModel.shared.firebaseCurrentUser._id)
                    {
                        self.addMessage(message)
                        if message.receiver == AppModel.shared.firebaseCurrentUser._id
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
                    if (message.status != 1 || message.receiver != AppModel.shared.firebaseCurrentUser._id){
                        self.addMessage(message)
                        if message.receiver == AppModel.shared.firebaseCurrentUser._id
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
        self.tblView.beginUpdates()
        self.tblView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
        self.tblView.endUpdates()
        self.setTblViewHeight()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: COREDATA.MESSAGE.TABLE_NAME,
                                                in: managedContext)!
        
        let message = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        message.setValue(channelId, forKeyPath: COREDATA.MESSAGE.CHANNEL_ID)
        message.setValue(newMessage.msgId, forKey: COREDATA.MESSAGE.msgID)
        message.setValue(newMessage.sender, forKey: COREDATA.MESSAGE.SENDER)
        message.setValue(newMessage.userName, forKey: COREDATA.MESSAGE.USER_NAME)
        message.setValue(newMessage.receiver, forKey: COREDATA.MESSAGE.RECEIVER)
        message.setValue(newMessage.ownerName, forKey: COREDATA.MESSAGE.OWNER_NAME)
        message.setValue(newMessage.date, forKey: COREDATA.MESSAGE.date)
        message.setValue(newMessage.key, forKey: COREDATA.MESSAGE.key)
        message.setValue(newMessage.status, forKey: COREDATA.MESSAGE.status)
        message.setValue(newMessage.text, forKey: COREDATA.MESSAGE.text)
        message.setValue(newMessage.type, forKey: COREDATA.MESSAGE.type)
        message.setValue(newMessage.local_picture, forKey: COREDATA.MESSAGE.local_picture)
        message.setValue(newMessage.remote_picture, forKey: COREDATA.MESSAGE.remote_picture)
        
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
            fetchRequest.predicate = NSPredicate(format: "%@ = %@ AND %@ = %@",COREDATA.MESSAGE.CHANNEL_ID,channelId,COREDATA.MESSAGE.msgID,message.msgId)
            do {
                let messagesArr: [NSManagedObject] = try managedContext.fetch(fetchRequest)
                
                if(messagesArr.count == 1)
                {
                    let msgUpdate = messagesArr[0]
                    msgUpdate.setValue(channelId, forKeyPath: COREDATA.MESSAGE.CHANNEL_ID)
                    msgUpdate.setValue(message.msgId, forKey: COREDATA.MESSAGE.msgID)
                    msgUpdate.setValue(message.sender, forKey: COREDATA.MESSAGE.SENDER)
                    msgUpdate.setValue(message.userName, forKey: COREDATA.MESSAGE.USER_NAME)
                    msgUpdate.setValue(message.receiver, forKey: COREDATA.MESSAGE.RECEIVER)
                    msgUpdate.setValue(message.ownerName, forKey: COREDATA.MESSAGE.OWNER_NAME)
                    msgUpdate.setValue(message.date, forKey: COREDATA.MESSAGE.date)
                    msgUpdate.setValue(message.key, forKey: COREDATA.MESSAGE.key)
                    msgUpdate.setValue(message.status, forKey: COREDATA.MESSAGE.status)
                    msgUpdate.setValue(message.text, forKey: COREDATA.MESSAGE.text)
                    message.setValue(message.type, forKey: COREDATA.MESSAGE.type)
                    message.setValue(message.local_picture, forKey: COREDATA.MESSAGE.local_picture)
                    message.setValue(message.remote_picture, forKey: COREDATA.MESSAGE.remote_picture)
                    
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_INBOX_LIST), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSelectPicture(_ sender: Any)
    {
        self.view.endEditing(true)
        openCustomPopup()
    }
    
    @IBAction func clickToSend(_ sender: Any)
    {
        self.view.endEditing(true)
        msgTextView.text = msgTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if msgTextView.text != ""
        {
            let newMsgRef : DatabaseReference = messagesRef.childByAutoId()
            print(getCurrentTimeStampValue())
            let dict : [String : Any] = ["msgId": getCurrentTimeStampValue(), "key" : newMsgRef.key, "sender": AppModel.shared.firebaseCurrentUser._id, "userName": AppModel.shared.firebaseCurrentUser.firstName, "receiver": receiver._id, "ownerName": receiver.firstName, "date": getCurrentTimeStampValue(), "text": msgTextView.text.encoded, "type" : 1, "status":2, "local_picture" : "", "remote_picture" : ""]
            let msgModel: MessageModel = MessageModel.init(dict: dict)
            addMessage(msgModel)
            newSendMessagesArr[msgModel.msgId] = true
            newMsgRef.setValue(msgModel.dictionary())
            msgTextView.text = ""
            AppDelegate().sharedDelegate().onSendMessage(message: msgModel, chanelId: channelId)
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let dict : MessageModel = messages[indexPath.row]
        if dict.sender == AppModel.shared.firebaseCurrentUser._id
        {
            var cell:SendChatMessageTVC!
            cell = offscreenCellSender["SendChatMessageTVC"] as? SendChatMessageTVC
            if cell == nil {
                cell = tblView.dequeueReusableCell(withIdentifier: "SendChatMessageTVC") as! SendChatMessageTVC
                offscreenCellSender["SendChatMessageTVC"] = cell
            }
            cell.messageTxtView.text = dict.text.decoded
            
            let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
            cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
            cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
            
            var headerHeight : CGFloat = 0
            if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
            {
                headerHeight = 30
            }
            
            return 70 - 35 + cell.ConstraintHeightMessageView.constant + headerHeight
        }
        else
        {
            var cell:ReceiverChatMessageTVC!
            cell = offscreenCellReceiver["ReceiverChatMessageTVC"] as? ReceiverChatMessageTVC
            if cell == nil {
                cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverChatMessageTVC") as! ReceiverChatMessageTVC
                offscreenCellReceiver["ReceiverChatMessageTVC"] = cell
            }
            
            
            cell.messageTxtView.text = dict.text.decoded
            
            let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
            cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
            cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
            var headerHeight : CGFloat = 0
            if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
            {
                cell.headerView.isHidden = false
                cell.headerLbl.text = getdayDifferenceFromCurrentDay(Double(dict.date)!)
                headerHeight = 30
            }
            return 70 - 35 + cell.ConstraintHeightMessageView.constant + headerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MessageCell!
        
        let dict : MessageModel = messages[indexPath.row]
        
        if dict.sender == AppModel.shared.firebaseCurrentUser._id {
            //sender message
            cell = tblView.dequeueReusableCell(withIdentifier: "SendChatMessageTVC", for: indexPath) as! MessageCell
            setUserProfileImage(AppModel.shared.currentUser, button: cell.profilePicBtn)
            cell.messageTxtView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.white]
        }
        else{
            cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverChatMessageTVC", for: indexPath) as! MessageCell
            if var picture = receiver.picture
            {
                APIManager.sharedInstance.serviceCallToGetPhoto(picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.profilePicBtn])
            }
            else
            {
                cell.profilePicBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
            }
            cell.messageTxtView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : colorFromHex(hex: "3C3739")]
        }
        
        if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
        {
            cell.headerView.isHidden = false
            cell.headerLbl.text = "  " + getdayDifferenceFromCurrentDay(Double(dict.date)!) + "  "
            cell.constraintHeaderWidth.constant = (cell.headerLbl.intrinsicContentSize.width)
            cell.constraintHeightHeaderView.constant = 30
        }
        else
        {
            cell.headerView.isHidden = true
            cell.constraintHeaderWidth.constant = 0
            cell.constraintHeightHeaderView.constant = 0
        }
        if indexPath.row > 0  && dict.receiver == messages[indexPath.row-1].receiver
        {
            cell.profilePicView.isHidden = true
        }
        else
        {
            cell.profilePicView.isHidden = false
        }
        
        cell.durationLbl.text = getDateTimeStringFromServerTimeStemp(Double(dict.date)!)
        
        cell.messageTxtView.text = dict.text.decoded
        let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
        cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
        cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    @IBAction func retryToUploadMedia(_ sender: UIButton)
    {
        /*
        if sender.isSelected == true
        {
            let msgModel : MessageModel = messages[sender.tag]
            //uploadChatingMedia(msgModel: msgModel, msgIndex: sender.tag)
            
            
            if let tempStory = AppModel.shared.STORY[msgModel.storyID]
            {
                AppDelegate().sharedDelegate().uploadStory(story: tempStory, msg: msgModel)
                
                self.tblView.beginUpdates()
                self.tblView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableViewRowAnimation.automatic)
                self.tblView.endUpdates()
            }
        }
        */
    }
    
    //MARK: - Story Image Video Display
    @IBAction func showStory(_ sender: UIButton)
    {
        let dict : MessageModel = messages[sender.tag]
        
    }
    
    @IBAction func closeVideoView(_ sender: Any)
    {
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    
    // MARK: - TextView delegate
    func textViewDidChange(_ textView: UITextView)
    {
        if textView == msgTextView
        {
            if msgTextView.contentSize.height > 70 {
                constraintHeightMsgTextView.constant = 70 + 25
            }
            else
            {
                constraintHeightMsgTextView.constant = msgTextView.contentSize.height + 25
            }
            setTblViewHeight()
        }
    }
    
    func scrollTableviewToBottom()
    {
        if self.tblView != nil &&  self.messages.count > 0
        {
            self.tblView.scrollToRow(at: IndexPath(item: self.tblView.numberOfRows(inSection: 0) - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    
    func setTblViewHeight()
    {
        constraintHeightTblView.constant = self.view.frame.size.height - (70 + constraintHeightMsgTextView.constant)
        scrollTableviewToBottom()
    }
    
    //MARK: - Custom Popup
    func openCustomPopup()
    {
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        uploadImage = nil
    }
    func onSelectPic(_ img: UIImage) {
        uploadImage = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        openSendImageContainerView()
    }
    
    func openSendImageContainerView()
    {
        receiverImgBtn.addCircularRadiusOfView()
        let newUser : UserModel = UserModel.init(dict:receiver.dictionary())
        setUserProfileImage(newUser, button: receiverImgBtn)
        sendImgView.image = uploadImage
        displaySubViewtoParentView(self.view, subview: sendImageContainerVIew)
    }
    
    @IBAction func clickToCloseImageContainerView(_ sender: Any)
    {
        sendImageContainerVIew.removeFromSuperview()
    }
    
    
    @IBAction func clickToSendImage(_ sender: Any)
    {
        self.view.endEditing(true)
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
