//
//  Utility.swift
//  ToShare
//
//  Created by Keyur on 22/12/17.
//  Copyright © 2017 Keyur. All rights reserved.
//

import UIKit
import Toaster

//MARK:- Image Function
func compressImage(_ image: UIImage, to toSize: CGSize) -> UIImage {
    var actualHeight: Float = Float(image.size.height)
    var actualWidth: Float = Float(image.size.width)
    let maxHeight: Float = Float(toSize.height)
    //600.0;
    let maxWidth: Float = Float(toSize.width)
    //800.0;
    var imgRatio: Float = actualWidth / actualHeight
    let maxRatio: Float = maxWidth / maxHeight
    //50 percent compression
    if actualHeight > maxHeight || actualWidth > maxWidth {
        if imgRatio < maxRatio {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        }
        else if imgRatio > maxRatio {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        }
        else {
            actualHeight = maxHeight
            actualWidth = maxWidth
        }
    }
    let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(actualWidth), height: CGFloat(actualHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    let imageData1: Data? = UIImagePNGRepresentation(img!)
    UIGraphicsEndImageContext()
    return imageData1 == nil ? image : UIImage(data: imageData1!)!
}

//MARK:- Table
func getTableBackgroundViewForNoData(_ str:String, size:CGSize) -> UIView{
    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    noDataLabel.text          = str
    noDataLabel.textColor     = colorFromHex(hex: COLOR.BLACK_COLOR)
    noDataLabel.font          = UIFont(name:"Helvetica", size: 18)!
    noDataLabel.textAlignment = .center
    return noDataLabel
}

//MARK:- set button Image
func setUserProfileImage(_ user : UserModel, button : UIButton)
{
    if let image : UIImage = AppModel.shared.usersAvatar[user.id]{
        button.setBackgroundImage(image.imageCropped(toFit: button.frame.size), for: .normal)
    }
    else{
        button.setBackgroundImage(UIImage(named:IMAGE.USER_PLACEHOLDER), for: .normal)
        APIManager.sharedInstance.serviceCallToGetUserAvatar(user, btn: button)
    }
}

//MARK:- Toast
func displayToast(_ message:String)
{
    let toast = Toast(text: message)
    toast.show()
//    AppDelegate().sharedDelegate().window?.makeToast(message)
//    if(AppDelegate().sharedDelegate().isKeyboardOpen){
//        UIApplication.shared.windows.last!.makeToast(message)
//    }
    
}

//MARK:- Loader
func showLoader()
{
    AppDelegate().sharedDelegate().showLoader()
}
func removeLoader()
{
    AppDelegate().sharedDelegate().removeLoader()
}

//MARK:- Alert
func showAlertWithOption(_ title:String, message:String, btns:[String] = ["Yes", "Cancel"],completionConfirm: @escaping () -> Void,completionCancel: @escaping () -> Void){
    let myAlert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert)
    let rightBtn = UIAlertAction(title: btns[0], style: UIAlertActionStyle.default, handler: { (action) in
        completionConfirm()
    })
    let leftBtn = UIAlertAction(title: btns[1], style: UIAlertActionStyle.cancel, handler: { (action) in
        completionCancel()
    })
    myAlert.addAction(rightBtn)
    myAlert.addAction(leftBtn)
    myAlert.view.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
    AppDelegate().sharedDelegate().window?.rootViewController?.present(myAlert, animated: true, completion: nil)
}


func showAlert(_ title:String, message:String, completion: @escaping () -> Void){
    
    let myAlert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:{ (action) in
        completion()
    })
    myAlert.addAction(okAction)
    myAlert.view.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
    AppDelegate().sharedDelegate().window?.rootViewController?.present(myAlert, animated: true, completion: nil)
}

//MARK:- View
func displaySubViewtoParentView(_ parentview: UIView! , subview: UIView!)
{
    subview.translatesAutoresizingMaskIntoConstraints = false
    parentview.addSubview(subview);
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    parentview.layoutIfNeeded()
}

func displaySubViewWithScaleOutAnim(_ view:UIView){
    view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
    view.alpha = 1
    UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: [], animations: {() -> Void in
        view.transform = CGAffineTransform.identity
    }, completion: {(_ finished: Bool) -> Void in
    })
}

func displaySubViewWithScaleInAnim(_ view:UIView){
    UIView.animate(withDuration: 0.25, animations: {() -> Void in
        view.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        view.alpha = 0.0
    }, completion: {(_ finished: Bool) -> Void in
        view.removeFromSuperview()
    })
}

func setBottomShadowView(_ view : UIView, color : UIColor)
{
    view.layer.masksToBounds = false;
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 3.0;
    view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    view.layer.shadowColor = color.cgColor
    view.layer.shadowPath = UIBezierPath.init(rect: view.bounds).cgPath
}

//MARK:- Color function
func colorFromHex(hex : String) -> UIColor
{
    return colorWithHexString(hex, alpha: 1.0)
}

func colorFromHex(hex : String, alpha:CGFloat) -> UIColor
{
    return colorWithHexString(hex, alpha: alpha)
}

func colorWithHexString(_ stringToConvert:String, alpha:CGFloat) -> UIColor {
    
    var cString:String = stringToConvert.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: alpha
    )
}

func imageWithColor(color : UIColor) -> UIImage
{
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
}

//MARK:- Features
func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func setFlotingPriceWithCurrency(_ price : Float) -> String
{
    return "$ " + setFlotingPrice(price)
}

func setFlotingPrice(_ price : Float) -> String
{
    var strPrice : String = String(format: "%0.2f", price)
    if strPrice.contains(".00")
    {
        strPrice = strPrice.replacingOccurrences(of: ".00", with: "")
    }
    if strPrice.contains(".")
    {
        strPrice = String(format: "%0.2f", Float(strPrice)!)
        if (((strPrice as NSString).substring(from: strPrice.count - 1)) == "0")
        {
            strPrice = String(format: "%0.1f", Float(strPrice)!)
        }
    }
    return strPrice
}

func setRatingValue(rate : Double) -> String
{
    var strRate : String = String(format: "%0.1f", rate)
    if strRate.contains(".0")
    {
        strRate = strRate.replacingOccurrences(of: ".0", with: "")
    }
    return strRate
}


func getIPAddress() -> String? {
    
    var address : String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        
        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if  name == "en0" {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    freeifaddrs(ifaddr)
    
    if address == ""
    {
        let ipData : [String] = getIFAddresses()
        if let ip : String = ipData[1]
        {
            return ip
        }
    }
    
    return address
}

func getIFAddresses() -> [String] {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [] }
    guard let firstAddr = ifaddr else { return [] }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        let addr = ptr.pointee.ifa_addr.pointee
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return addresses
}


func getFirstName(name : String) -> String
{
    var fname : String = name
    if fname.contains(" ")
    {
        let arrTemp = fname.components(separatedBy: " ")
        if arrTemp.count > 0
        {
            fname = arrTemp[0]
        }
    }
    return fname
}

func getLastName(name : String) -> String
{
    var lname : String = name
    if lname.contains(" ")
    {
        let arrTemp = lname.components(separatedBy: " ")
        if arrTemp.count > 1
        {
            lname = arrTemp[1]
        }
    }
    return lname
}

extension UIImage {
    
    func imageResize ()-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 1.0
        let sizeChange:CGSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

//MARK: - String Method
extension String
{
    var isValidEmail: Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var trimmed:String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    var encoded:String{
        let str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let data: Data? = str.data(using: String.Encoding.nonLossyASCII)
        let Value = String(data: data!, encoding: String.Encoding.utf8)
        return Value ?? ""
    }
    var decoded: String {
        let str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let data: Data? = str.data(using: String.Encoding.utf8)
        let Value = String(data: data!, encoding: String.Encoding.nonLossyASCII)
        return Value ?? ""
    }
    var html2AttributedString: NSAttributedString {
        return Data(utf8).html2AttributedString ?? NSAttributedString()
    }
    var html2String: String {
        return html2AttributedString.string ?? ""
    }
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }

}

//MARK: - UIView Method
extension UIView
{
    func addCornerRadiusOfView(_ radius: CGFloat = 10.0)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func addCircularRadiusOfView()
    {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
    
    func applyBorderOfView(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
    
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setInnerViewShadow(_ shadowColor : UIColor)
    {
        self.layer.masksToBounds = false;
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 12
    }
    
}

extension UILabel
{
//    func getLableHeight() -> CGFloat{
//        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byWordWrapping
//        label.font = self.font
//        label.text = self.text
//        label.sizeToFit()
//        return label.frame.height
//    }
    
    func getLableHeight(extraWidth : CGFloat) -> CGFloat
    {
        let fixedWidth = UIScreen.main.bounds.size.width - extraWidth
        let constraint : CGSize = CGSize(width: fixedWidth, height: CGFloat(FLT_MAX))
        let context : NSStringDrawingContext = NSStringDrawingContext()
        let boundingBox: CGSize = self.text!.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: self.font], context: context).size
        let size : CGSize = CGSize(width: boundingBox.width, height: boundingBox.height)
        return size.height
    }
    
    func getLableHeight(numberOfLines : Int) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
    
    func getLableWidth() -> CGFloat{
        return self.intrinsicContentSize.width
    }
}


extension UITextField
{
    func addPadding(padding: CGFloat)
    {
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: padding, height: self.frame.height)
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
}

extension UITextView
{
    func getHeight() -> CGFloat
    {
        let fixedWidth = self.frame.size.width
        self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = self.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.frame = newFrame
        return self.frame.size.height
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

