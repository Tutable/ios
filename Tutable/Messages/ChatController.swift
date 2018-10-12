//
//  ChatController.swift
//  Tutable
//
//  Created by Rohit Saini on 05/10/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Photos
import MobileCoreServices
class ChatController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    fileprivate var currentVC: UIViewController!
    @IBOutlet weak var ProfilePic: UIImageView!
    var userProfilePic: UIImageView = UIImageView()
    let barHeight: CGFloat = 50
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTxtView: UIView!
    var TitleLbl = String()
    var status  = Int()
    var keyBoardHeight = CGFloat()
    
    @IBOutlet weak var ChatTxt: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var keyBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var AcceptRejView: UIView!
    let imagePicker = UIImagePickerController()
    var currentUser: USER?
    var items = [Messages]()
    override func viewDidLoad() {
        super.viewDidLoad()
        download_Current_User_image()
        fetchData()
        
        
        print(AppModel.shared.currentUser.picture)
       
        
        customization()
      
        titleLbl.text = TitleLbl
        ProfilePic.circleCorner()
        ChatTxt.circleCorner(cornerRadius: 10)
        ChatTxt.addRightPadding(padding: 35)
        ChatTxt.addPadding(padding: 10)
        ChatTxt.delegate = self
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            //            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            //            UIView.animate(withDuration: 0.3, animations: {
            //                cell.transform = CGAffineTransform.identity
            //            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            cell.profilePic.image = userProfilePic.image
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
//                cell.messageBackground.image = UIImage.init(named: "message_shape_send")!.resizableImage(withCapInsets: UIEdgeInsets.init(top: 17, left: 21, bottom: 17, right: 21), resizingMode: UIImageResizingMode.stretch)
                
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.image = self.currentUser?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
//                cell.messageBackground.image = UIImage.init(named: "message_balloon")!.resizableImage(withCapInsets: UIEdgeInsets.init(top: 17, left: 21, bottom: 17, right: 21), resizingMode: UIImageResizingMode.stretch)
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        }
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        self.ChatTxt.resignFirstResponder()
    //        switch self.items[indexPath.row].type {
    //        case .photo:
    //            if let photo = self.items[indexPath.row].image {
    //
    //                //                let info = ["viewType" : ShowExtraView.preview, "pic": photo] as [String : Any]
    //                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
    //                // self.inputAccessoryView?.isHidden = true
    //            }
    ////        case .location:
    ////            let coordinates = (self.items[indexPath.row].content as! String).components(separatedBy: ":")
    ////            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
    ////            let info = ["viewType" : ShowExtraView.map, "location": location] as [String : Any]
    ////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
    ////            self.inputAccessoryView?.isHidden = true
    //        default: break
    //        }
    //    }
    
    
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        tableView.reloadData()
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {
                self.keyBottomHeight.constant = height
                self.view.layoutIfNeeded()
            }
            self.tableView.contentInset.bottom = height - height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.keyBottomHeight.constant = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
        
        IQKeyboardManager.sharedManager().enable = false
    }
    //
    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.chatTxtView.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        NotificationCenter.default.removeObserver(self)
        // Message.markMessagesRead(forUserID: self.currentUser!.id)
    }
    
    
  
    
    
    
    
    
    
//
//    //MARK:- sendNotificationWithOutFirebase
//    //Accept Friend Request
//    func sendNotificationWithOutFirebase(){
//        APIManager.sharedInstance.serviceCallSaveNotification(notificationType: 2, ref: (currentUser?.id)! ) {
//            print("SEND")
//        }
//    }
//
//    //MARK:- getUserForPushNotification
//    func getUserForPushNotification(){
//        print(AppModel.shared.currentUser.name)
//        User.info(forUserID: (currentUser?.id)!) { (user) in
//            DispatchQueue.main.async {
//                AppDelegate().sharedDelegate().sendPush(title: "\((AppModel.shared.currentUser.name)!) accepted your friend request.", body: "", user: user, type: "2")
//
//
//
//
//            }
//
//        }
//    }
    

    
    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = self.currentUser?.name
        
    }
      //MARK: download_Current_User_image
    func download_Current_User_image(){
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
            userProfilePic.downloaded(from: url!)
            
    }
    }
    //Downloads messages
    func fetchData() {
        Messages.downloadAllMessages(forUserID: self.currentUser!.id, completion: {[weak weakSelf = self] (message) in
            weakSelf?.items.append(message)
            weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
            DispatchQueue.main.async {
                if let state = weakSelf?.items.isEmpty, state == false {
                    weakSelf?.tableView.reloadData()
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
        Messages.markMessagesRead(forUserID: self.currentUser!.id)
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Messages.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        Messages.send(message: message, toID: self.currentUser!.id, completion: {(_) in
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Send Media
    @IBAction func sendMedia(_ sender: UIButton) {
        showActionSheet(vc: self)
    }
    
    //MARK:- Send Message
    @IBAction func sendMessage(_ sender: UIButton) {
        if let text = self.ChatTxt.text {
            if text.count > 0 {
                self.composeMessage(type: .text, content: self.ChatTxt.text!)
                self.ChatTxt.text = ""
            }
        }
    }
    
    
    
    //MARK:- Action Sheet
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.selectCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.selectGallery()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }//Action Sheet
    
    
    
    
    //MARK:- selectCamera
    func selectCamera(){
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- selectGallery
    func selectGallery(){
        
        self.imagePicker.mediaTypes = [kUTTypeImage as String]
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    //MARK:- Send Photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL]{
            print(videoUrl)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Back
    @IBAction func clickBackBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

