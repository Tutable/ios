//
//  AppModel.swift
//  ToShare
//
//  Created by ToShare Pty. Ltd on 1/2/18.
//  Copyright © 2018 ToShare Pty. Ltd. All rights reserved.
//

import UIKit

class AppModel: NSObject {
    static let shared = AppModel()
    
    var currentUser : UserModel!
    var firebaseCurrentUser : FirebaseUserModel!
    var token:String = ""
    var usersAvatar:[String:UIImage] = [String:UIImage]()
    var isFCMConnected : Bool = false
    var imageQueue:[String:Any] = [String:Any]()
    
    var USERS : [FirebaseUserModel] = [FirebaseUserModel] ()
    var INBOXLIST : [InboxListModel] = [InboxListModel] ()
    var UPLOADING_STORY_QUEUE : [String : String] = [String : String] () // id of story
    
    func validateUser(dict : [String : Any]) -> Bool{
        if let uID = dict["_id"] as? String, let email = dict["email"] as? String
        {
            if(uID != "" && email != ""){
                return true
            }
        }
        return false
    }
    func validateInbox(dict : [String : Any]) -> Bool{
        if let id = dict["conversationKey"] as? String, let lastMessage = dict["lastMessage"] as? [String:Any]
        {
            if(id != "" && validateLastMessage(dict:lastMessage)){
                return true
            }
        }
        return false
    }
    func validateLastMessage(dict : [String : Any]) -> Bool{
        if let msgID = dict["msgId"] as? String, let key = dict["key"] as? String, let connectUserID = dict["receiver"] as? String
        {
            if(msgID != "" && key != "" && connectUserID != ""){
                return true
            }
        }
        return false
    }
}

class UserModel:AppModel{
    var _id:String!
    var firstName:String!
    var lastName : String!
    var email : String!
    var password : String!
    var picture:String!
    var isVerified:Int!
    var verificationCode:Int!
    
    var accessToken:String!
    var latitude:Float!
    var longitude:Float!
    var notiSetting:Bool!
    var isSocial : Bool!
    var last_seen : String!
    var fcmToken : String!
    
    override init(){
        _id = ""
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        picture = ""
        isVerified = 0
        verificationCode = 0
        
        accessToken = ""
        latitude = 0
        longitude = 0
        notiSetting = true
        isSocial = false
        last_seen = ""
        fcmToken = ""
    }
    init(dict : [String : Any])
    {
        _id = ""
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        accessToken = ""
        picture = ""
        isVerified = 0
        verificationCode = 0
        
        latitude = 0
        longitude = 0
        notiSetting = true
        isSocial = false
        last_seen = ""
        fcmToken = ""
        
        if let Id = dict["_id"] as? String{
            _id = Id
        }
        if let FirstName = dict["firstName"] as? String{
            firstName = FirstName
        }
        if let LastName = dict["lastName"] as? String{
            lastName = LastName
        }
        if let Email = dict["email"] as? String{
            email = Email
        }
        if let Password = dict["password"] as? String{
            password = Password
        }
        if let AccessToken = dict["accessToken"] as? String{
            accessToken = AccessToken
        }
        if let Picture = dict["picture"] as? String{
            picture = Picture
        }
        if let IsVerified = dict["isVerified"] as? Int{
            isVerified = IsVerified
        }
        if let VerificationCode = dict["verificationCode"] as? Int{
            verificationCode = VerificationCode
        }
        
        if let Latitude = dict["latitude"] as? Float{
            latitude = Latitude
        }
        if let Longitude = dict["longitude"] as? Float{
            longitude = Longitude
        }
        if let notifications = dict["notifications"] as? Bool{
            notiSetting = notifications
        }
        
        if let fbDict = dict["facebook"] as? [String : Any]
        {
            if fbDict.count == 0
            {
                isSocial = false
            }
            else
            {
                isSocial = true
            }
        }
        else if let isSocialLogin = dict["isSocial"] as? Bool
        {
            isSocial = isSocialLogin
        }
        if let lastSeen = dict["last_seen"] as? String{
            last_seen = lastSeen
        }
        if let fcm_token = dict["fcmToken"] as? String{
            fcmToken = fcm_token
        }
        
    }
    
    func dictionary() -> [String:Any]{
        return ["_id":_id,"firstName":firstName,"lastName":lastName,"email" : email, "password" : password, "accessToken":accessToken, "picture":picture, "isVerified":isVerified, "verificationCode":verificationCode, "latitude":latitude, "longitude":longitude, "notiSetting":notiSetting, "isSocial":isSocial, "last_seen" : last_seen, "fcmToken" : fcmToken]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class FirebaseUserModel:AppModel{
    var _id:String!
    var firstName:String!
    var lastName : String!
    var email : String!
    var last_seen : String!
    var fcmToken : String!
    var picture : String!
    
    override init(){
        _id = ""
        firstName = ""
        lastName = ""
        email = ""
        last_seen = ""
        fcmToken = ""
        picture = ""
    }
    init(dict : [String : Any])
    {
        _id = ""
        firstName = ""
        lastName = ""
        email = ""
        last_seen = ""
        fcmToken = ""
        picture = ""
        
        if let Id = dict["_id"] as? String{
            _id = Id
        }
        if let FirstName = dict["firstName"] as? String{
            firstName = FirstName
        }
        if let LastName = dict["lastName"] as? String{
            lastName = LastName
        }
        if let Email = dict["email"] as? String{
            email = Email
        }
        if let lastSeen = dict["last_seen"] as? String{
            last_seen = lastSeen
        }
        if let fcm_token = dict["fcmToken"] as? String{
            fcmToken = fcm_token
        }
        if let picture_url = dict["picture"] as? String{
            picture = picture_url
        }
        
    }
    
    func dictionary() -> [String:Any]{
        return ["_id":_id,"firstName":firstName,"lastName":lastName,"email" : email, "last_seen" : last_seen, "fcmToken" : fcmToken, "picture" : picture]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class MessageModel: AppModel
{
    var msgId : String!
    var key : String!
    var sender : String!
    var userName : String!
    var receiver : String!
    var ownerName : String!
    var date : String!
    var type : Int! //1.Text, 2.Image
    var text : String!
    var local_picture : String!
    var remote_picture : String!
    var status : Int! //1.Pending, 2.Send, 3.notify
    
    override init(){
        msgId = ""
        key = ""
        sender = ""
        userName = ""
        receiver = ""
        ownerName = ""
        date = ""
        type = 0
        text = ""
        local_picture = ""
        remote_picture = ""
        status = 0
    }
    
    init(dict : [String : Any])
    {
        msgId = ""
        key = ""
        sender = ""
        userName = ""
        receiver = ""
        ownerName = ""
        date = ""
        type = 0
        text = ""
        local_picture = ""
        remote_picture = ""
        status = 0
        
        if let MSG_ID = dict["msgId"] as? String{
            self.msgId = MSG_ID
        }
        if let KEY = dict["key"] as? String{
            self.key = KEY
        }
        if let SENDER_USER_ID = dict["sender"] as? String{
            self.sender = SENDER_USER_ID
        }
        if let USER_NAME = dict["userName"] as? String{
            self.userName = USER_NAME
        }
        if let RECEIVER_USER_ID = dict["receiver"] as? String{
            self.receiver = RECEIVER_USER_ID
        }
        if let OWNER_NAME = dict["ownerName"] as? String{
            self.ownerName = OWNER_NAME
        }
        if let DATE = dict["date"] as? String{
            self.date = DATE
        }
        if let TYPE = dict["type"] as? Int{
            self.type = TYPE
        }
        if let TEXT = dict["text"] as? String{
            self.text = TEXT
        }
        if let LOCAL_PICTURE = dict["local_picture"] as? String{
            self.local_picture = LOCAL_PICTURE
        }
        if let REMOTE_PICTURE = dict["remote_picture"] as? String{
            self.remote_picture = REMOTE_PICTURE
        }
        if let STATUS = dict["status"] as? Int{
            self.status = STATUS
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["msgId":msgId,"key":key,"sender":sender,"userName":userName,"receiver":receiver,"ownerName":ownerName,"date" : date, "type" : type, "text":text, "local_picture":local_picture, "remote_picture":remote_picture, "status":status]
    }
    
}

class InboxListModel: AppModel
{
    var conversationKey : String!
    var owner : String!
    var user : String!
    var date : String!
    var lastMessage : MessageModel!
    
    override init(){
        conversationKey = ""
        owner = ""
        user = ""
        date = ""
        lastMessage = MessageModel.init()
    }
    
    init(dict : [String : Any])
    {
        conversationKey = ""
        owner = ""
        user = ""
        date = ""
        lastMessage = MessageModel.init()
        
        if let conversation_key = dict["conversationKey"] as? String{
            self.conversationKey = conversation_key
        }
        if let owner_id = dict["owner"] as? String {
            self.owner = owner_id
        }
        if let user_id = dict["user"] as? String {
            self.user = user_id
        }
        if let date_value = dict["date"] as? String {
            self.date = date_value
        }
        self.lastMessage = MessageModel.init(dict: dict["lastMessage"] as? [String : Any] ?? [String : Any]())
    }
    
    func dictionary() -> [String:Any]{
        return ["conversationKey":conversationKey, "owner":owner, "user":user, "date" : date, "lastMessage":lastMessage.dictionary()]
    }
}

