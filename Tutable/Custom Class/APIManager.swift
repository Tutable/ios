//  Created by ToShare Pty. Ltd on 13/07/17.
//  Copyright © 2017 ToShare Pty. Ltd. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
import AlamofireImage

public class APIManager {
    
    static let sharedInstance = APIManager()
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func getMultipartHeader() -> [String:String]{
        return ["Content-Type":"multipart/form-data"]
    }
    
    func getJsonHeader() -> [String:String]{
        return ["Content-Type":"application/json"]
    }
    
    func getJsonHeaderWithToken() -> [String:String]{
        return ["Content-Type":"application/json", "Authorization":AppModel.shared.token]
    }
    
    func getMultipartHeaderWithToken() -> [String:String]{
        return ["Content-Type":"multipart/form-data", "Authorization":AppModel.shared.token]
    }
    
    //MARK:- login-signup
 
    func serviceCallToRegister(_ imageData:Data, completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeader()
        var params :[String : Any] = [String : Any] ()
        params["data"] = AppModel.shared.currentUser.toJson(["firstName":AppModel.shared.currentUser.firstName,"lastName":AppModel.shared.currentUser.lastName,"email" : AppModel.shared.currentUser.email, "password" : AppModel.shared.currentUser.password])
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            multipartFormData.append(imageData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: BASE_URL+"user/signup", method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    removeLoader()
                    print(response.result.value!)
                    if let result = response.result.value as? [String:Any]{
                        if let code = result["code"] as? Int{
                            if(code == 100){
                                completion()
                                return
                            }
                        }
                        if let message = result["message"] as? String{
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                    displayToast("Registeration error")
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToFBLogin(_ completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        var params :[String : Any] = [String : Any] ()
        params["id"] = AppModel.shared.currentUser._id
        params["firstName"] = AppModel.shared.currentUser.firstName
        params["lastName"] = AppModel.shared.currentUser.lastName
        params["accessToken"] = AppModel.shared.token
        params["picture"] = AppModel.shared.currentUser.picture
        params["email"] = AppModel.shared.currentUser.email
        
        Alamofire.request(BASE_URL+"user/facebookLoginApp", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            if let accessToken = result["accessToken"] as? String{
                                AppModel.shared.token = accessToken
                                self.serviceCallToGetUserDetail {
                                    completion()
                                }
                                return
                            }
                            else{
                                displayToast("Unauthorized user.")
                            }
                            return
                        }
                    }
                    if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Facebook login error")
                break
            case .failure(let error):
                print(error)
                //displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToLogin(_ completion: @escaping (_ isSucceed:Bool) -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        
        var params :[String : Any] = [String : Any] ()
        params["username"] = AppModel.shared.currentUser.email
       params["password"] = AppModel.shared.currentUser.password

        Alamofire.request(BASE_URL+"user/login", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            if let accessToken = result["accessToken"] as? String{
                                AppModel.shared.token = accessToken
                                self.serviceCallToGetUserDetail {
                                    completion(true)
                                }
                                return
                            }
                            else{
                                displayToast("Unauthorized user.")
                            }
                            return
                        }
                    }
                    if let message = result["message"] as? String{
                        if(message == "User is not verified. Verify verification code first."){
                            completion(false)
                        }
                        displayToast(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Login error")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetFirebaseCustomToken(_ completion: @escaping (_ dict:[String:Any]) -> Void){
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["id"] = AppModel.shared.currentUser._id
        
        Alamofire.request(BASE_URL+"user/firebaseAuthToken", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            completion(result)
                            return
                        }
                    }
                    if let error = result["error"] as? String{
                        print(error)
                        return
                    }
                    if let message = result["message"] as? String{
                        print(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    print(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    //MARK:- User verification
    func serviceCallToVerifyCode(_ code:String, completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        params["verificationCode"] = Int(code)
        
        Alamofire.request(BASE_URL+"user/verificationCodeValidator", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            self.serviceCallToLogin({ (status) in
                                if(status == true){
                                    completion()
                                }
                            })
                            return
                        }
                    }
                    if let error = result["error"] as? String{
                        displayToast(error)
                        return
                    }
                    if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Verifying email error")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToResendVerifyCode(_ completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        
        Alamofire.request(BASE_URL+"user/resendVerificationCode", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            completion()
                            return
                        }
                    }
                    if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Verifying email error")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToChangePassword(_ completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        params["token"] = AppModel.shared.currentUser.verificationCode
        params["password"] = AppModel.shared.currentUser.password
        
        Alamofire.request(BASE_URL+"user/changePassword", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            completion()
                            return
                        }
                    }
                    if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Verifying email error")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- Get User detail
    func serviceCallToGetUserDetail(_ completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        let params :[String : Any] = [String : Any] ()
      
        Alamofire.request(BASE_URL+"user/details", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    AppModel.shared.currentUser = UserModel.init(dict: result)
                    AppModel.shared.currentUser.accessToken = AppModel.shared.token
                    setLoginUserData(AppModel.shared.currentUser.dictionary())
                    completion()
                    return
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Error in getting user detail.")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    func serviceCallToGetUserAvatar(_ user:UserModel, btn:UIButton){
        
        let _ :[String : String] = [String:String]()
        Alamofire.request(BASE_URL+"user/getProfilePic/"+user.picture).responseImage { response in
            if let image = response.result.value {
                btn.setBackgroundImage(image, for: .normal)
                AppModel.shared.usersAvatar[user._id] = image
                return
            }
            else
            {
                
            }
        }
    }
    
    func serviceCallToUploadPicture(_ imageData:Data, completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: BASE_URL+"user/uploadProfilePic", method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    removeLoader()
                    print(response.result.value!)
                    if (response.result.value as? [String:Any]) != nil{
                        completion()
                        return
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                    displayToast("Registeration error")
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToUpdateUserDetail(_ completion: @escaping (_ dict:[String:Any]) -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["firstName"] = AppModel.shared.currentUser.firstName
        params["lastName"] = AppModel.shared.currentUser.lastName
        params["email"] = AppModel.shared.currentUser.email
        
        Alamofire.request(BASE_URL+"user/updateProfile", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    completion(result)
                    if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                    
                    return
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                displayToast("Error in getting user detail.")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- Get Photo
    func serviceCallToGetPhoto(_ picPath:String?, isUser : Bool, btn:[UIButton]){
        
        if let picture = picPath
        {
            if let image = AppModel.shared.imageQueue[picture] as? UIImage{
                for i in 0..<btn.count{
                    btn[i].setBackgroundImage(image.imageCropped(toFit: btn[i].frame.size), for: .normal)
                }
            }
            else if let _ = AppModel.shared.imageQueue[picture] as? Bool{
                
            }
            else{
                DataRequest.addAcceptableImageContentTypes(["image/jpg", "image/jpeg", "image/png", "image/gif"])
                AppModel.shared.imageQueue[picPath!] = true
                //let headerParams :[String : String] = getJsonHeader()
                Alamofire.request(PHOTO_BASE_URL + picPath!).responseImage { response in
                    if let image = response.result.value {
                        AppModel.shared.imageQueue[picPath!] = image
                        for i in 0..<btn.count{
                            btn[i].setBackgroundImage(image.imageCropped(toFit: btn[i].frame.size), for: .normal)
                        }
                        return
                    }
                    else
                    {
                        AppModel.shared.imageQueue[picPath!] = nil
                    }
                }
            }
        }
        else
        {
            for i in 0..<btn.count{
                if isUser
                {
                    btn[i].setBackgroundImage(UIImage.init(named: "userPlaceHolder"), for: .normal)
                }
                else
                {
                    btn[i].setBackgroundImage(UIImage.init(named: "placeholder_event"), for: .normal)
                }
            }
        }
    }
}
