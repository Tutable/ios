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
    var isFCMConnected : Bool = false
    var imageQueue:[String:Any] = [String:Any]()
    
    func validateUser(dict : [String : Any]) -> Bool{
        if let uID = dict["_id"] as? String, let email = dict["email"] as? String
        {
            if(uID != "" && email != ""){
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
    var degreeAsset : String!
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
    var category : Int!
    var level : String!
    var desc : String!
    var bio : String!
    var timeline : Double!
    var picture : String!
    var price : Int!
    
    override init(){
        id = ""
        name = ""
        category = 0
        level = ""
        desc = ""
        bio = ""
        timeline = 0
        picture = ""
        price = 0
    }
    init(dict : [String : Any])
    {
        id = ""
        name = ""
        category = 0
        level = ""
        desc = ""
        bio = ""
        timeline = 0
        picture = ""
        price = 0
        
        if let temp = dict["id"] as? String{
            id = temp
        }
        if let temp = dict["name"] as? String{
            name = temp
        }
        if let temp = dict["category"] as? Int{
            category = temp
        }
        if let temp = dict["level"] as? String{
            level = temp
        }
        if let temp = dict["description"] as? String{
            desc = temp
        }
        if let temp = dict["bio"] as? String{
            bio = temp
        }
        if let block = dict["timeline"] as? Double{
            timeline = block
        }
        if let image = dict["picture"] as? String{
            picture = image
        }
        if let temp = dict["price"] as? Int{
            price = temp
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id,"name":name,"category" : category, "level" : level, "description" : desc, "bio":bio, "picture":picture, "timeline":timeline, "price":price]
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}

