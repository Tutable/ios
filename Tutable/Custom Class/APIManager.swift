//  Created by ToShare Pty. Ltd on 13/07/17.
//  Copyright © 2017 ToShare Pty. Ltd. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
import AlamofireImage
import SDWebImage

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
    
    func networkErrorMsg()
    {
        showAlert("Tutable", message: "You are not connected to the internet") {
            
        }
    }
    
    //MARK:- login-signup
 
    func serviceCallToRegister(_ imageData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        let headerParams :[String : String] = getMultipartHeader()
        var params :[String : Any] = [String : Any] ()
        
        var strUrl : String = "teachers/register"
        params["data"] = AppModel.shared.currentUser.toJson(["name":AppModel.shared.currentUser.name,"email" : AppModel.shared.currentUser.email, "password" : AppModel.shared.currentUser.password, "address" : AppModel.shared.currentUser.address.location])
        
        if isStudentLogin()
        {
            strUrl = "student/register"
            params["data"] = AppModel.shared.currentUser.toJson(["name":AppModel.shared.currentUser.name,"email" : AppModel.shared.currentUser.email, "password" : AppModel.shared.currentUser.password, "address" : AppModel.shared.currentUser.address.location, "dob" : AppModel.shared.currentUser.dob])
            
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if imageData.count != 0
            {
                multipartFormData.append(imageData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: BASE_URL+strUrl, method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
//                upload.uploadProgress(closure: { (Progress) in
//                    print("Upload Progress: \(Progress.fractionCompleted)")
//                })
                upload.responseJSON { response in
                    removeLoader()
                    if let result = response.result.value as? [String:Any]{
                        if let code = result["code"] as? Int{
                            if(code == 100){
                                completion()
                                return
                            }
                            else if code == 104
                            {
                                displayToast("User already exists")
                            }
                        }
                        else if let message = result["message"] as? String{
                            displayToast(message)
                            return
                        }
                    }
                    else if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                    //displayToast("Registeration error")
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToLogin(_ completion: @escaping (_ code:Int) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
    
        var params :[String : Any] = [String : Any] ()
        params["username"] = AppModel.shared.currentUser.email
        params["password"] = AppModel.shared.currentUser.password

        var strUrl : String = "teachers/login"
        if isStudentLogin()
        {
            strUrl = "student/login"
        }
        
        Alamofire.request(BASE_URL+strUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
                                    AppDelegate().sharedDelegate().updateDeviceToken()
                                    completion(code)
                                }
                                return
                            }
                            else{
                                displayToast("Unauthorized user.")
                            }
                            return
                        }
                        else if code == 104
                        {
                            displayToast("User not found")
                            return
                        }
                        else if code == 105
                        {
                            completion(code)
                            return
                        }
                        else if code == 106
                        {
                            displayToast("Invalid Email Id or Password.")
                            return
                        }
                    }
                    else if let message = result["message"] as? String{
                        if(message == "User is not verified. Verify verification code first."){
                            completion((result["code"] as? Int)!)
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
                //displayToast("Login error")
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToStudentSocialLogin(_ params : [String : Any], completion: @escaping (_ code:Int) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        Alamofire.request(BASE_URL+"student/social", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
                                    AppDelegate().sharedDelegate().updateDeviceToken()
                                    completion(code)
                                }
                                return
                            }
                            else{
                                displayToast("Unauthorized user.")
                            }
                            return
                        }
                        else if code == 104
                        {
                            if result["message"] as! String == "Requested user not found" || result["message"] as! String == "error"
                            {
                                displayToast(result["message"] as! String)
                                return
                            }
                            else
                            {
                                completion(code)
                            }
                        }
                    }
                    else if let message = result["message"] as? String{
                        if(message == "User is not verified. Verify verification code first."){
                            completion((result["code"] as? Int)!)
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
    
    func serviceCallToTeacherSocialLogin(_ params : [String : Any], completion: @escaping (_ code:Int) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        Alamofire.request(BASE_URL+"teachers/social", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
                                    AppDelegate().sharedDelegate().updateDeviceToken()
                                    completion(code)
                                }
                                return
                            }
                            else{
                                displayToast("Unauthorized user.")
                            }
                            return
                        }
                        else if code == 104
                        {
                            if result["message"] as! String == "Requested user not found" || result["message"] as! String == "error"
                            {
                                displayToast(result["message"] as! String)
                                return
                            }
                            else
                            {
                                completion(code)
                            }
                        }
                    }
                    if let message = result["message"] as? String{
                        if(message == "User is not verified. Verify verification code first."){
                            completion((result["code"] as? Int)!)
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
    
    //MARK:- User verification
    func serviceCallToVerifyCode(_ code:String, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()

        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        params["token"] = Int(code)
        
        var strUrl : String = "teachers/verify"
        if isStudentLogin()
        {
            strUrl = "student/verify"
        }
        
        Alamofire.request(BASE_URL + strUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            self.serviceCallToLogin({ (status) in
                                if(status == 100){
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
    
    func serviceCallToResendVerifyCode(_ tokenType:Int, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        var strUrl : String = "teachers/resendVerification"
        if isStudentLogin()
        {
            strUrl = "student/token"
            params["tokenType"] = tokenType
        }
        
        Alamofire.request(BASE_URL+strUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
    
    func serviceCallToGetPasswordToken(_ completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        
        Alamofire.request(BASE_URL+"teachers/passwordToken", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- Change Password
    func serviceCallToChangePassword(_ completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeader()
        
        var params :[String : Any] = [String : Any] ()
        params["email"] = AppModel.shared.currentUser.email
        params["token"] = AppModel.shared.currentUser.verificationCode
        params["password"] = AppModel.shared.currentUser.password
        
        var strUrl : String = "teachers/changePassword"
        if isStudentLogin()
        {
            strUrl = "student/changePassword"
        }
        
        Alamofire.request(BASE_URL+strUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
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
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- Get Category
    func serviceCallToGetCategory(_ completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["parent"] = true
        Alamofire.request(BASE_URL+"categories/list", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                //print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        setCategoryList(data)
                        completion()
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
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
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        let params :[String : Any] = [String : Any] ()
      
        var strUrl : String = "teachers/details"
        if isStudentLogin()
        {
            strUrl = "student/studentDetails"
        }
        Alamofire.request(BASE_URL+strUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [String : Any] = result["data"] as? [String : Any]
                    {
                        AppModel.shared.currentUser = UserModel.init(dict: data)
                        AppModel.shared.currentUser.accessToken = AppModel.shared.token
                        if isStudentLogin()
                        {
                            setIsUserLogin(isUserLogin: true)
                        }
                        completion()
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetTeacehrDetail(_ teacherID : String, completion: @escaping ([String : Any]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["id"] = teacherID
        
        Alamofire.request(BASE_URL+"teachers/teacherDetails", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [String : Any] = result["data"] as? [String : Any]
                    {
                        completion(data)
                        return
                    }
                }
                if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToUpdateTeacherDetail(_ dict : [String : Any], degreeData : Data, pictureData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        var params :[String : Any] = [String : Any] ()
        params["data"] = AppModel.shared.currentUser.toJson(dict)
        
        //print(getMultipartHeaderWithToken())
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                print(key,value)
            }
            
            if degreeData.count != 0
            {
                multipartFormData.append(degreeData, withName: "degreeAsset", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            if pictureData.count != 0
            {
                multipartFormData.append(pictureData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: BASE_URL+"teachers/update", method: .post
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
                            if(code == 100 || code == 104){
                                self.serviceCallToGetUserDetail {
                                    completion()
                                }
                                return
                            }
                        }
                        if let message = result["message"] as? String {
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToUpdateStudentDetail(_ dict : [String : Any], pictureData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        var params :[String : Any] = [String : Any] ()
        params["data"] = AppModel.shared.currentUser.toJson(dict)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if pictureData.count != 0
            {
                multipartFormData.append(pictureData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: BASE_URL+"student/update", method: .post
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
                            if(code == 100 || code == 104){
                                self.serviceCallToGetUserDetail({
                                    completion()
                                    return
                                })
                            }
                        }
                        else if let message = result["message"] as? String {
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- Certificate
    func serviceCallToUpdateCertificates(_ policeData : Data, childrenData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if policeData.count != 0
            {
                multipartFormData.append(policeData, withName: "policeCert", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            if childrenData.count != 0
            {
                multipartFormData.append(childrenData, withName: "childrenCert", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: BASE_URL+"certificates/save", method: .post
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
                                self.serviceCallToGetUserDetail {
                                    completion()
                                    return
                                }
                                
                            }
                        }
                        else if let message = result["message"] as? String {
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetCertificate(_ completion: @escaping () -> Void){
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        let params :[String : Any] = [String : Any] ()
        
        Alamofire.request(BASE_URL+"certificates/details", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [String : Any] = result["data"] as? [String : Any]
                    {
                        if let policeCertificate : String = data["policeCertificate"] as? String
                        {
                            setPoliceCertificate(policeCertificate)
                        }
                        if let childrenCertifiate : String = data["childrenCertifiate"] as? String
                        {
                            setChildreanCertificate(childrenCertifiate)
                        }
                    }
                    completion()
                    return
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetCertificate(_ picPath:String?, placeHolder : String, btn:[UIButton]){
        
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
                let headerParams :[String : String] = getJsonHeaderWithToken()
                DataRequest.addAcceptableImageContentTypes(["image/jpg", "image/jpeg", "image/png", "image/gif"])
                AppModel.shared.imageQueue[picPath!] = true
                //let headerParams :[String : String] = getJsonHeader()
                
                Alamofire.request("http://ec2-13-59-33-113.us-east-2.compute.amazonaws.com/development/api" + picPath!, headers: headerParams).responseImage { response in
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
                btn[i].setBackgroundImage(UIImage.init(named: placeHolder), for: .normal)
            }
        }
    }
    
    //MARK:- Get Certificate Image
    func serviceCallToGetCertificateImage(_ path:String, btn:UIButton, completion: @escaping () -> Void){
        
//        if let image : UIImage = AppModel.shared.imageQueue[path] as? UIImage
//        {
//            btn.setBackgroundImage(image, for: .normal)
//            completion()
//            return
//        }
        let _ :[String : String] = [String:String]()
        
        let strUrl : String = BASE_URL + path
        
        Alamofire.request(strUrl).responseImage { response in
            if let image = response.result.value {
                btn.setBackgroundImage(image, for: .normal)
                AppModel.shared.imageQueue[path] = image
                completion()
                return
            }
            else
            {
                btn.setBackgroundImage(UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER), for: .normal)
                completion()
            }
        }
    }
    
    //MARK:- Class
    func serviceCallToCreateClass(_ classImgData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        
        params["data"] = AppModel.shared.currentClass.toJson(["name":AppModel.shared.currentClass.name, "category" : AppModel.shared.currentClass.category.id, "level" : AppModel.shared.currentClass.level, "bio" : AppModel.shared.currentClass.bio, "timeline" : AppModel.shared.currentClass.timeline, "whyQualified" : AppModel.shared.currentClass.whyQualified, "rate" : AppModel.shared.currentClass.rate])
       
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if classImgData.count != 0
            {
                multipartFormData.append(classImgData, withName: "picture", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: BASE_URL+"class/create", method: .post
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
                        else if let message = result["message"] as? String{
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    
    func serviceCallToDeleteWWCCInformation() {
        
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        
        params["wwdc"] = true
        
        // certificates/delete
        print(params,headerParams,BASE_URL+"certificates/delete" )
        Alamofire.request(BASE_URL+"certificates/delete", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let _ = response.result.value {
           
                }
                else if let _ = response.result.error
                {
                   // displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
             //   displayToast(error.localizedDescription)
                break
            }
        }
        
        
    }
    
    
    func serviceCallToUpdateClass(_ classImgData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        
        params["data"] = AppModel.shared.currentClass.toJson(["name":AppModel.shared.currentClass.name, "category" : AppModel.shared.currentClass.category.id, "level" : AppModel.shared.currentClass.level, "bio" : AppModel.shared.currentClass.bio, "whyQualified" : AppModel.shared.currentClass.whyQualified, "rate" : AppModel.shared.currentClass.rate, "classId" : AppModel.shared.currentClass.id])
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if classImgData.count != 0
            {
                multipartFormData.append(classImgData, withName: "payload", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: BASE_URL+"class/update", method: .post
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
                            if(code == 100 || code == 104){
                                completion()
                                return
                            }
                        }
                        else if let message = result["message"] as? String{
                            displayToast(message)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetClassList(_ categoryId : String, teacherId : String, completion: @escaping (_ dataArr : [[String : Any]]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        if categoryId != ""
        {
            params["categoryId"] = categoryId
        }
        else
        {
            params["teacherId"] = teacherId
        }
        Alamofire.request(BASE_URL+"class/list", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        completion(data)
                        return
                    }
                    else
                    {
                        completion([[String : Any]]())
                        return
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetClassDetail(_ classId : String, _ completion: @escaping (_ dataArr : [String : Any]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["classId"] = classId
        
        Alamofire.request(BASE_URL+"class/details", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            removeLoader()
            
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [String : Any] = result["data"] as? [String : Any]
                    {
                        completion(data)
                        return
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToBookClass(_ classId : String, slotDict : [String : Any], completion: @escaping (_ result :[String : Any]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["ref"] = classId
        params["slot"] = slotDict
        print(params)
        Alamofire.request(BASE_URL+"bookings/create", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    completion(result)
                }
                else if let error = response.error{
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetBookingList(_ params : [String : Any], completion: @escaping (_ dictArr :[[String : Any]]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        Alamofire.request(BASE_URL+"bookings/details", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        completion(data)
                        return
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    
    func serviceCallToBookingAction(_ params : [String : Any], completion: @escaping (_ isSuccess :Bool) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        Alamofire.request(BASE_URL+"bookings/action", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            completion(true)
                            return
                        }
                    }
                    else if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                
                if let error = response.error{
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    func serviceCallToCancelBookingAction(_ params : [String : Any], completion: @escaping (_ isSuccess :Bool) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        Alamofire.request(BASE_URL+"bookings/cancel", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if(code == 100){
                            completion(true)
                            return
                        }
                    }
                    else if let message = result["message"] as? String{
                        displayToast(message)
                        return
                    }
                }
                
                if let error = response.error{
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    //MARK: - Payment
    func serviceCallToAddStripeToken(_ params : [String : Any], completion: @escaping (_ isSuccess :Bool) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        Alamofire.request(BASE_URL+"payments/create", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = (response.result.value as? [String:Any]){
                    if let code : Int = result["code"] as? Int
                    {
                        if code == 100
                        {
                            self.serviceCallToGetUserDetail({
                                completion(true)
                                return
                            })
                        }
                        else
                        {
                            completion(false)
                            return
                        }
                    }
                    else
                    {
                        completion(false)
                        return
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToCreateStripeBankAccount(_ dict : [String : Any], imgData : Data, completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getMultipartHeaderWithToken()
        
        var params :[String : Any] = [String : Any] ()
        params["data"] = toJson(["account":dict["account"]!, "personalDetails":dict["personalDetails"]!])
        print(params)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if imgData.count != 0
            {
                multipartFormData.append(imgData, withName: "verificationDocumentData", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: BASE_URL+"payments/createBankAccount", method: .post
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
                                self.serviceCallToGetUserDetail({
                                    completion()
                                    return
                                })
                            }
                            else if(code == 104){
                                if let errorDict = result["error"] as? [String : Any]{
                                    if let message = errorDict["message"] as? String{
                                        displayToast(message)
                                    }
                                }
                            }
                        }
                        else if (result["message"] as? String) != nil{
                            displayToast((result["message"] as? String)!)
                            return
                        }
                    }
                    
                    if let error = response.error{
                        displayToast(error.localizedDescription)
                        return
                    }
                }
            case .failure(let error):
                removeLoader()
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToUpdateStripeBankAccount(_ dict : [String : Any], completion: @escaping () -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        Alamofire.request(BASE_URL+"payments/updateBank", method: .post, parameters: dict, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int{
                        if code == 100
                        {
                            self.serviceCallToGetUserDetail({
                                completion()
                                return
                            })
                        }
                        else if(code == 104){
                            if let message = result["message"] as? String{
                                displayToast(message)
                            }
                        }
                    }
//                    if (result["message"] as? String) != nil{
//                        displayToast((result["message"] as? String)!)
//                        return
//                    }
                }
                
                if let error = response.error{
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToDeletePaymentMethod(_ completion: @escaping (_ isSuccess :Bool) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        Alamofire.request(BASE_URL+"payments/remove", method: .post, parameters: [String : Any](), encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int
                    {
                        if code == 100
                        {
                            completion(true)
                            return
                        }
                        else
                        {
                            displayToast((result["message"] as? String)!)
                            completion(false)
                            return
                        }
                    }
                    
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK: - Review
    func serviceCallToAddReview(_ params : [String : Any], completion: @escaping (_ isSuccess :Bool) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        Alamofire.request(BASE_URL+"reviews/create", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let code = result["code"] as? Int
                    {
                        if code == 100
                        {
                            completion(true)
                            return
                        }
                        else
                        {
                            displayToast((result["message"] as? String)!)
                            completion(false)
                            return
                        }
                    }
                    
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToGetReviewList(_ classId : String, completion: @escaping (_ dictArr :[[String : Any]]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        var params : [String : Any] = [String : Any]()
        params["classId"] = classId
        print(params)
        
        Alamofire.request(BASE_URL+"reviews/list", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        completion(data)
                        return
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK: - Notification
    func serviceCallToGetNotificationList(_ params : [String : Any], completion: @escaping (_ dictArr :[[String : Any]]) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        showLoader()
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        print(params)
        
        Alamofire.request(BASE_URL+"notifications/details", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        completion(data)
                        return
                    }
                    else
                    {
                        completion([[String : Any]]())
                    }
                }
                else if let error = response.result.error
                {
                    displayToast(error.localizedDescription)
                    return
                }
                break
            case .failure(let error):
                print(error)
                displayToast(error.localizedDescription)
                break
            }
        }
    }
    
    func serviceCallToclearNotificationCount(){
        let headerParams :[String : String] = getJsonHeaderWithToken()
        var strUrl : String = BASE_URL + "teachers/resetNotifications"
        if isStudentLogin()
        {
            strUrl = BASE_URL + "student/resetNotifications"
        }
        
        Alamofire.request(strUrl, method: .post, parameters: [String : Any](), encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [[String : Any]] = result["data"] as? [[String : Any]]
                    {
                        return
                    }
                }
                if let error = response.result.error
                {
                    return
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func serviceCallToRemoveNotification(_ notiID : String){
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        var params : [String : Any] = [String : Any]()
        params["notificationId"] = notiID
        
        Alamofire.request(BASE_URL + "notifications/delete", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            switch response.result {
            case .success:
                print(response.result.value!)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    //MARK: - Delete User
    func serviceCallToDeleteUser(){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        let params : [String : Any] = [String : Any]()
        
        Alamofire.request(BASE_URL + "admin/deleteUser", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            switch response.result {
            case .success:
                AppDelegate().sharedDelegate().logoutApp()
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    //MARK: - Help, About
    func serviceCallToGetHelpAbout(){
        let headerParams :[String : String] = getJsonHeaderWithToken()
        
        Alamofire.request(BASE_URL + "content/details", method: .post, parameters: [String : Any](), encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            removeLoader()
            switch response.result {
            case .success:
                print(response.result.value!)
                if let result = response.result.value as? [String:Any]{
                    if let data : [String : Any] = result["data"] as? [String : Any]
                    {
                        if let tearms : String = data["terms"] as? String
                        {
                            setTearmsConditionContent(tearms)
                        }
                        if let help : String = data["help"] as? String
                        {
                            setHelpContent(help)
                        }
                        if let about : String = data["about"] as? String
                        {
                            setAboutContent(about)
                        }
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
    
    //MARK: - Fetch Image
    func serviceCallToGetPhoto(_ picPath:String?, placeHolder : String, btn:[UIButton]){
        
        var url : String = ""
        if picPath!.contains("http://") || picPath!.contains("https://")
        {
            url = picPath!
        }
        else
        {
            url = BASE_URL + picPath!
        }
        
        for i in 0..<btn.count{
            btn[i].sd_setBackgroundImage(with: URL(string : url), for: .normal, completed: { (image, error, caheType, url) in
                if error == nil
                {
                    btn[i].setBackgroundImage(image?.imageCropped(toFit: btn[i].frame.size), for: .normal)
                }
                else
                {
                    btn[i].setBackgroundImage(UIImage.init(named: placeHolder), for: .normal)
                }
            })
        }
        
    }
    
    func toJson(_ dict:[String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
}
