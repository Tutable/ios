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
    var token : String = ""
    var currentUser : UserModel!
    var currentClass : ClassModel!
    var usersAvatar:[String:UIImage] = [String:UIImage]()
    var imageQueue:[String:Any] = [String:Any]()
    var categoryData : [CategoryModel] = [CategoryModel]()
    
    var firebaseCurrentUser : FirebaseUserModel!
    var isFCMConnected : Bool = false
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
    
    func getLocationArrOfDictionary(arr:[LocationModel]) -> [[String:Any]]{ // story
        
        let len:Int = arr.count
        var retArr:[[String:Any]] =  [[String:Any]] ()
        for i in 0..<len{
            retArr.append(arr[i].dictionary())
        }
        return retArr
    }
}

class UserModel:AppModel{
    var id:String!
    var name:String!
    var email : String!
    var password : String!
    var verificationCode : String!
    var accessToken : String!
    var picture : String!
    var blocked : Int!
    var deleted : Int!
    var firstLogin : Int!
    var isVerified : Int!
    var dob : Double!
    var gender : String!
    var bio : String!
    var availability : [String : [String]]!
    var address : LocationModel!
    var qualification : String!
    var school : String!
    var degreeAsset : String!
    var deviceId : String!
    var policeCert : String!
    var childrenCert : String!
    
    override init(){
        id = ""
        name = ""
        email = ""
        password = ""
        verificationCode = ""
        accessToken = ""
        picture = ""
        blocked = 0
        degreeAsset = ""
        deleted = 0
        firstLogin = 0
        isVerified = 0
        dob = 0.0
        gender = ""
        bio = ""
        availability = [String : [String]]()
        address = LocationModel.init()
        qualification = ""
        school = ""
        deviceId = ""
        policeCert = ""
        childrenCert = ""
    }
    init(dict : [String : Any])
    {
        id = ""
        name = ""
        email = ""
        password = ""
        verificationCode = ""
        accessToken = ""
        picture = ""
        blocked = 0
        degreeAsset = ""
        deleted = 0
        firstLogin = 0
        isVerified = 0
        dob = 0.0
        gender = ""
        bio = ""
        availability = [String : [String]]()
        address = LocationModel.init()
        qualification = ""
        school = ""
        deviceId = ""
        policeCert = ""
        childrenCert = ""
        
        if let Id = dict["id"] as? String{
            id = Id
        }
        else if let Id = dict["_id"] as? String{
            id = Id
        }
        if let Name = dict["name"] as? String{
            name = Name
        }
        if let Email = dict["email"] as? String{
            email = Email
        }
        if let Password = dict["password"] as? String{
            password = Password
        }
        if let code = dict["verificationCode"] as? String{
            verificationCode = code
        }
        if let token = dict["accessToken"] as? String{
            accessToken = token
        }
        if let image = dict["picture"] as? String{
            picture = image
        }
        if let block = dict["blocked"] as? Int{
            blocked = block
        }
        if let degree = dict["degreeAsset"] as? String{
            degreeAsset = degree
        }
        if let delete = dict["deleted"] as? Int{
            deleted = delete
        }
        if let first_login = dict["firstLogin"] as? Int{
            firstLogin = first_login
        }
        if let verified = dict["isVerified"] as? Int{
            isVerified = verified
        }
        if let date = dict["dob"] as? Double{
            dob = date
        }
        if let Gender = dict["gender"] as? String{
            gender = Gender
        }
        if let about = dict["bio"] as? String{
            bio = about
        }
        if let temp = dict["availability"] as? [String : [String]]{
            availability = temp
        }
        if let temp = dict["address"] as? [String : Any] {
            address = LocationModel.init(dict: temp)
        }
        if let temp = dict["qualification"] as? String{
            qualification = temp
        }
        if let temp = dict["school"] as? String{
            school = temp
        }
        if let temp = dict["deviceId"] as? String{
            deviceId = temp
        }
        if let temp = dict["policeCert"] as? String{
            policeCert = temp
        }
        if let temp = dict["childrenCert"] as? String{
            childrenCert = temp
        }
        if let temp = dict["facebook"] as? [String : Any]{
            if let temp = temp["email"] as? String
            {
                email = temp
            }
            if let temp = temp["firstName"] as? String
            {
                name = temp
            }
            if let temp = temp["lastName"] as? String
            {
                if name != ""
                {
                    name = name + " " + temp
                }
                else
                {
                    name = temp
                }
            }
        }
        if let temp = dict["google"] as? [String : Any]{
            if let temp = temp["email"] as? String
            {
                email = temp
            }
            if let temp = temp["firstName"] as? String
            {
                name = temp
            }
            if let temp = temp["lastName"] as? String
            {
                if name != ""
                {
                    name = name + " " + temp
                }
                else
                {
                    name = temp
                }
            }
            
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"name":name,"email" : email, "password" : password, "verificationCode" : verificationCode, "accessToken":accessToken, "picture":picture, "blocked":blocked, "degreeAsset":degreeAsset, "deleted":deleted, "firstLogin":firstLogin, "isVerified":isVerified, "dob":dob, "gender":gender, "bio":bio, "availability" : availability, "address":address.dictionary(), "qualification":qualification, "school":school, "deviceId":deviceId, "policeCert" : policeCert, "childrenCert" : childrenCert]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class LocationModel:AppModel{
    var location:String!
    var state:String!
    var suburb:String!
    var coordinates:[String]!
    
    override init(){
        location = ""
        state = ""
        suburb = ""
        coordinates = [String]()
    }
    init(dict : [String : Any])
    {
        location = ""
        state = ""
        suburb = ""
        coordinates = [String]()
        
        if let temp = dict["location"] as? String{
            location = temp
        }
        if let temp = dict["state"] as? String{
            state = temp
        }
        if let temp = dict["suburb"] as? String{
            suburb = temp
        }
        if let temp = dict["coordinates"] as? [String]{
            coordinates = temp
        }
    }
    func dictionary() -> [String:Any]{
        return ["location" : location, "state" : state, "suburb" : suburb, "coordinates" : coordinates]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
    
}

class ClassModel:AppModel{
    var id:String!
    var name:String!
    var category : CategoryModel!
    var level : Int!
    var bio : String!
    var timeline : Double!
    var payload : String!
    var rate : Float!
    var cancelled : Int!
    var created : Double!
    var teacher : UserModel!
    var reviews : [String : Any]!
    
    override init(){
        id = ""
        name = ""
        category = CategoryModel.init()
        level = 0
        bio = ""
        timeline = 0
        payload = ""
        rate = 0.0
        cancelled = 0
        created = 0.0
        teacher = UserModel.init()
        reviews = [String : Any]()
    }
    init(dict : [String : Any])
    {
        id = ""
        name = ""
        category = CategoryModel.init()
        level = 0
        bio = ""
        timeline = 0
        payload = ""
        rate = 0.0
        cancelled = 0
        created = 0.0
        teacher = UserModel.init()
        reviews = [String : Any]()
        
        if let temp = dict["id"] as? String{
            id = temp
        }
        if let temp = dict["name"] as? String{
            name = temp
        }
        if let temp = dict["category"] as? [String : Any]{
            category = CategoryModel.init(dict: temp)
        }
        if let temp = dict["level"] as? Int{
            level = temp
        }
        if let temp = dict["bio"] as? String{
            bio = temp
        }
        if let temp = dict["timeline"] as? Double{
            timeline = temp
        }
        else if let temp = dict["timestamp"] as? Double{
            timeline = temp
        }
        if let image = dict["payload"] as? String{
            payload = image
        }
        else if let image = dict["picture"] as? String{
            payload = image
        }
        if let temp = dict["rate"] as? Float{
            rate = temp
        }
        if let temp = dict["cancelled"] as? Int{
            cancelled = temp
        }
        if let temp = dict["created"] as? Double{
            created = temp
        }
        if let temp = dict["teacher"] as? [String : Any]{
            teacher = UserModel.init(dict: temp)
        }
        if let temp = dict["reviews"] as? [String : Any]{
            reviews = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"name":name,"category" : category.dictionary(), "level" : level, "bio":bio, "payload":payload, "timeline":timeline, "rate":rate, "cancelled" : cancelled, "created" : created, "teacher" : teacher.dictionary(), "reviews" : reviews]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class CategoryModel:AppModel{
    var id:String!
    var v:Int!
    var picture : String!
    var title : String!
    
    override init(){
        id = ""
        v = 0
        picture = ""
        title = ""
    }
    init(dict : [String : Any])
    {
        id = ""
        v = 0
        picture = ""
        title = ""
        
        if let temp = dict["id"] as? String{
            id = temp
        }
        if let temp = dict["__v"] as? Int{
            v = temp
        }
        if let temp = dict["picture"] as? String{
            picture = temp
        }
        if let temp = dict["title"] as? String{
            title = temp
        }
        else if let temp = dict["name"] as? String{
            title = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"v":v,"picture" : picture, "title" : title]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class BookingClassModel:AppModel{
    
    var classDetails : ClassModel!
    var completed:Int!
    var confirmed:Int!
    var deleted:Int!
    var id:String!
    var student : UserModel!
    var teacher : UserModel!
    var timestamp : Double!
    var slot : [String : Any]!
    
    override init(){
        classDetails = ClassModel.init()
        completed = 0
        confirmed = 0
        deleted = 0
        id = ""
        student = UserModel.init()
        teacher = UserModel.init()
        timestamp = 0.0
        slot = [String : Any]()
    }
    init(dict : [String : Any])
    {
        classDetails = ClassModel.init()
        completed = 0
        confirmed = 0
        deleted = 0
        id = ""
        student = UserModel.init()
        teacher = UserModel.init()
        timestamp = 0.0
        slot = [String : Any]()
        
        if let temp = dict["classDetails"] as? [String : Any]{
            classDetails = ClassModel.init(dict: temp)
        }
        if let temp = dict["completed"] as? Int{
            completed = temp
        }
        if let temp = dict["confirmed"] as? Int{
            confirmed = temp
        }
        if let temp = dict["deleted"] as? Int{
            deleted = temp
        }
        if let temp = dict["id"] as? String{
            id = temp
        }
        if let temp = dict["student"] as? [String : Any]{
            student = UserModel.init(dict: temp)
        }
        if let temp = dict["teacher"] as? [String : Any]{
            teacher = UserModel.init(dict: temp)
        }
        if let temp = dict["timestamp"] as? Double{
            timestamp = temp
        }
        if let temp = dict["slot"] as? [String : Any]{
            slot = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["classDetails":classDetails.dictionary(),"completed":completed,"confirmed" : confirmed, "deleted" : deleted, "id" : id, "student" : student.dictionary(), "teacher" : teacher.dictionary(), "timestamp" : timestamp, "slot" : slot]
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
