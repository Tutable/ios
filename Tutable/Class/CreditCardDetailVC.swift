//
//  CreditCardDetailVC.swift
//  Tutable
//
//  Created by Amisha on 4/6/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

struct CARD {
    static var NUMBER = 16
    static var SPACE = 3
    static var EXPIRY = 5
    static var CVV = 3
}

class CreditCardDetailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cardNameTxt: UITextField!
    @IBOutlet weak var cardNumberTxt: UITextField!
    @IBOutlet weak var expiryDateTxt: UITextField!
    @IBOutlet weak var cvvTxt: UITextField!
    @IBOutlet weak var termsConditionBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var strCardNumber : String = ""
    var selectedExpiryDate : Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cardNumberTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        doneBtn.addCornerRadiusOfView(doneBtn.frame.size.height/2)
    }
    
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToExpiryDate(_ sender: Any) {
        DatePickerManager.shared.showPicker(title: "Select Date of Birth", selected: selectedExpiryDate, min: Date(), max: nil) { (date, cancel) in
            if !cancel && date != nil {
                self.selectedExpiryDate = date!
                self.expiryDateTxt.text = getDateStringFromDate(date: self.selectedExpiryDate, format: "MM/YY")
            }
        }
    }
    
    @IBAction func clickToTermsCondition(_ sender: Any) {
        termsConditionBtn.isSelected = !termsConditionBtn.isSelected
    }
    
    @IBAction func clickToDone(_ sender: Any) {
        if termsConditionBtn.isSelected
        {
            
        }
    }
    
    func showCardNumberFormattedStr(_ str:String, isRedacted:Bool = true) -> String{
        
        let tempStr:String = sendDetailByRemovingChar(sendDetailByRemovingChar(str, char:"-"), char: " ")
        var retStr:String = ""
        for i in 0..<tempStr.count{
            if(i == 4 || i == 8 || i == 12){
                retStr += "-"
            }
            retStr += tempStr[i]
        }
        if(isRedacted){
            var arr:[String] = retStr.components(separatedBy: "-")
            for i in 0..<arr.count{
                if(i == 1 || i == 2){
                    arr[i] = "xxxx"
                }
            }
            retStr = arr.joined(separator: "-")
        }
        return retStr
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string == ""){
            return true
        }
        var maxLength:Int = 0
        var str:String = ""
        if(textField == cardNumberTxt){
            maxLength = CARD.NUMBER + CARD.SPACE
            str = cardNumberTxt.text!
        }
        else if(textField == expiryDateTxt){
            maxLength = CARD.EXPIRY
            str = expiryDateTxt.text!
        }
        else if(textField == cvvTxt){
            maxLength = CARD.CVV
            str = cvvTxt.text!
        }
        else{
            return true
        }
        return str.count < maxLength
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(textField == cardNumberTxt){
            cardNumberTxt.text = showCardNumberFormattedStr(cardNumberTxt.text!, isRedacted: false)
            strCardNumber = sendDetailByRemovingChar((cardNumberTxt.text?.trimmed)!, char:" ")
        }
        else if(textField == expiryDateTxt){
            expiryDateTxt.text = showCardExpDateFormattedStr(expiryDateTxt.text!)
        }
    }
    
    func showCardExpDateFormattedStr(_ str:String) -> String{
        
        let tempStr:String = sendDetailByRemovingChar(str, char:"/")
        var retStr:String = ""
        for i in 0..<tempStr.count{
            if(i == 2){
                retStr += "/"
            }
            retStr += tempStr[i]
        }
        return retStr
    }
    
    func sendDetailByRemovingChar(_ str:String, char:String = " ") -> String{
        let regExp :String = char + "\n\t\r"
        return String(str.filter { !(regExp.contains($0))})
    }
    
    func sendDetailByRemovingChar(_ attrStr:NSAttributedString, char:String = " ") -> String{
        let str:String = attrStr.string
        let regExp :String = char + "\n\t\r"
        return String(str.filter { !(regExp.contains($0))})
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
