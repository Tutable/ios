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
        if let uID = dict["id"] as? String, let email = dict["email"] as? String
        {
            if(uID != "" && email != ""){
                return true
            }
        }
        return false
    }
    
    func validateInbox(dict : [String : Any]) -> Bool{
        if let id = dict["id"] as? String, let lastMessage = dict["lastMessage"] as? [String:Any]
        {
            if(id != "" && validateLastMessage(dict:lastMessage)){
                return true
            }
        }
        return false
    }
    func validateLastMessage(dict : [String : Any]) -> Bool{
        if let msgID = dict["msgId"] as? String, let key = dict["key"] as? String, let connectUserID = dict["otherUserId"] as? String
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
    var notifications : Int!
    var payment : Int!
    var certs : [String : Any]!
    var card : [String : Any]!
    
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
        notifications = 0
        payment = 0
        certs = [String : Any]()
        card = [String : Any]()
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
        notifications = 0
        payment = 0
        certs = [String : Any]()
        card = [String : Any]()
        
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
//        if let temp = dict["facebook"] as? [String : Any]{
//            if let temp = temp["email"] as? String
//            {
//                email = temp
//            }
//            if let temp = temp["firstName"] as? String
//            {
//                name = temp
//            }
//            if let temp = temp["lastName"] as? String
//            {
//                if name != ""
//                {
//                    name = name + " " + temp
//                }
//                else
//                {
//                    name = temp
//                }
//            }
//        }
//        if let temp = dict["google"] as? [String : Any]{
//            if let temp = temp["email"] as? String
//            {
//                email = temp
//            }
//            if let temp = temp["firstName"] as? String
//            {
//                name = temp
//            }
//            if let temp = temp["lastName"] as? String
//            {
//                if name != ""
//                {
//                    name = name + " " + temp
//                }
//                else
//                {
//                    name = temp
//                }
//            }
//        }
        if let temp = dict["notifications"] as? Int{
            notifications = temp
        }
        if let temp = dict["payment"] as? Int{
            payment = temp
        }
        if let temp = dict["certs"] as? [String : Any]{
            certs = temp
        }
        if let temp = dict["card"] as? [String : Any]{
            card = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"name":name,"email" : email, "password" : password, "verificationCode" : verificationCode, "accessToken":accessToken, "picture":picture, "blocked":blocked, "degreeAsset":degreeAsset, "deleted":deleted, "firstLogin":firstLogin, "isVerified":isVerified, "dob":dob, "gender":gender, "bio":bio, "availability" : availability, "address":address.dictionary(), "qualification":qualification, "school":school, "deviceId":deviceId, "policeCert" : policeCert, "childrenCert" : childrenCert, "notifications" : notifications, "payment" : payment, "certs" : certs, "card" : card]
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
    var review : [String : Any]!
    
    
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
        review = [String : Any]()
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
        review = [String : Any]()
        
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
        if let temp = dict["review"] as? [String : Any]{
            review = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["classDetails":classDetails.dictionary(),"completed":completed,"confirmed" : confirmed, "deleted" : deleted, "id" : id, "student" : student.dictionary(), "teacher" : teacher.dictionary(), "timestamp" : timestamp, "slot" : slot, "review" : review]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}


class FirebaseUserModel:AppModel{
    var id:String!
    var name:String!
    var email : String!
    var last_seen : String!
    var fcmToken : String!
    var picture : String!
    var isType : Int!
    var badge : Int!
    
    override init(){
        id = ""
        name = ""
        email = ""
        last_seen = ""
        fcmToken = ""
        picture = ""
        isType = 0
        badge = 0
    }
    init(dict : [String : Any])
    {
        id = ""
        name = ""
        email = ""
        last_seen = ""
        fcmToken = ""
        picture = ""
        isType = 0
        badge = 0
        
        if let temp = dict["id"] as? String{
            id = temp
        }
        if let temp = dict["name"] as? String{
            name = temp
        }
        if let temp = dict["email"] as? String{
            email = temp
        }
        if let temp = dict["last_seen"] as? String{
            last_seen = temp
        }
        if let temp = dict["fcmToken"] as? String{
            fcmToken = temp
        }
        if let temp = dict["picture"] as? String{
            picture = temp
        }
        if let temp = dict["isType"] as? Int{
            isType = temp
        }
        if let temp = dict["badge"] as? Int{
            badge = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"name":name,"email" : email, "last_seen" : last_seen, "fcmToken" : fcmToken, "picture" : picture, "isType" : isType, "badge" : badge]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

class MessageModel: AppModel {
    var msgId : String!
    var key : String!
    var otherUserId : String!
    var date : String!
    var text : String!
    var status : Int! //1.Pending, 2.Send, 3.notify
    
    override init(){
        msgId = ""
        key = ""
        otherUserId = ""
        date = ""
        text = ""
        status = 0
    }
    
    init(dict : [String : Any])
    {
        msgId = ""
        key = ""
        otherUserId = ""
        date = ""
        text = ""
        status = 0
        
        if let temp = dict["msgId"] as? String{
            self.msgId = temp
        }
        if let temp = dict["key"] as? String{
            self.key = temp
        }
        if let temp = dict["otherUserId"] as? String{
            self.otherUserId = temp
        }
        if let temp = dict["date"] as? String{
            self.date = temp
        }
        if let temp = dict["text"] as? String{
            self.text = temp
        }
        if let STATUS = dict["status"] as? Int{
            self.status = STATUS
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["msgId":msgId,"key":key,"otherUserId":otherUserId,"date" : date, "text":text, "status":status]
    }
    
}

class InboxListModel: AppModel
{
    var id : String!
    var badge1 : Int!
    var badge2 : Int!
    var lastMessage : MessageModel!
    
    override init(){
        id = ""
        badge1 = 0
        badge2 = 0
        lastMessage = MessageModel.init()
    }
    
    init(dict : [String : Any])
    {
        id = ""
        badge1 = 0
        badge2 = 0
        lastMessage = MessageModel.init()
        
        if let temp = dict["id"] as? String{
            self.id = temp
        }
        if let temp = dict["badge1"] as? Int {
            self.badge1 = temp
        }
        if let temp = dict["badge2"] as? Int {
            self.badge2 = temp
        }
        if let temp = dict["lastMessage"] as? [String : Any] {
            self.lastMessage = MessageModel.init(dict: temp)
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id, "badge1":badge1, "badge2":badge2, "lastMessage":lastMessage.dictionary()]
    }
}

class ReviewModel: AppModel
{
    var id : String!
    var blocked : Int!
    var student : UserModel!
    var deleted : Int!
    var posted : String!
    var ref : String!
    var review : String!
    var stars : Double!
    
    override init(){
        id = ""
        blocked = 0
        student = UserModel.init()
        deleted = 0
        posted = ""
        ref = ""
        review = ""
        stars = 0
    }
    
    init(dict : [String : Any])
    {
        id = ""
        blocked = 0
        student = UserModel.init()
        deleted = 0
        posted = ""
        ref = ""
        review = ""
        stars = 0
        
        if let temp = dict["_id"] as? String{
            self.id = temp
        }
        if let temp = dict["blocked"] as? Int {
            self.blocked = temp
        }
        if let temp = dict["student"] as? [String : Any] {
            self.student = UserModel.init(dict: temp)
        }
        if let temp = dict["deleted"] as? Int {
            self.deleted = temp
        }
        if let temp = dict["posted"] as? String{
            self.posted = temp
        }
        if let temp = dict["review"] as? String{
            self.review = temp
        }
        if let temp = dict["stars"] as? Double{
            self.stars = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["_id":id, "blocked":blocked, "student":student.dictionary(), "deleted":deleted, "posted":posted, "deleted":deleted, "posted":posted, "review":review, "stars":stars]
    }
}
