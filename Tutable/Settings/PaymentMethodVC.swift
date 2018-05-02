//
//  PaymentMethodVC.swift
//  Tutable
//
//  Created by Keyur on 20/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import MFCard
import Stripe

class PaymentMethodVC: UIViewController, MFCardDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var accountDetailLbl: UILabel!
    @IBOutlet weak var addAccount: UIButton!
    
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var cardImgBtn: UIButton!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var deleteCardBtn: UIButton!
    @IBOutlet var creditCardView: UIView!
    @IBOutlet var cardView: MFCardView!
    @IBOutlet weak var addCardBtn: UIButton!
    
    var isUpdateAccount : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isStudentLogin()
        {
            titleLbl.text = "PAYMENT METHOD"
        }
        else
        {
            titleLbl.text = "PAYMENT DETAILS"
        }
        
        addAccount.addCornerRadiusOfView(addAccount.frame.size.height/2)
        addCardBtn.addCornerRadiusOfView(addCardBtn.frame.size.height/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
        setDataValue()
    }
    
    func setDataValue()
    {
        if isStudentLogin()
        {
            cardImgBtn.setImage(nil, for: .normal)
            cardNumberLbl.text = ""
            studentView.isHidden = false
            teacherView.isHidden = true
            cardView.delegate = self
            cardView.autoDismiss = false
            cardView.toast = true
            
            if let cardImg : String = AppModel.shared.currentUser.card["type"] as? String
            {
                cardImgBtn.setImage(UIImage.init(named: cardImg), for: .normal)
            }
            
            if let cardnumber : String = AppModel.shared.currentUser.card["number"] as? String
            {
                cardNumberLbl.text = "•••• •••• •••• " + cardnumber
            }
            
            if cardNumberLbl.text == ""
            {
                cardNumberLbl.text = "You have not added a card yet"
                deleteCardBtn.isHidden = true
                addCardBtn.isHidden = false
            }
            else
            {
                deleteCardBtn.isHidden = false
                addCardBtn.isHidden = true
            }
        }
        else
        {
            studentView.isHidden = true
            teacherView.isHidden = false
            accountDetailLbl.text = ""
            
            if let cardnumber : String = AppModel.shared.currentUser.card["number"] as? String
            {
                accountDetailLbl.text = "•••• •••• •••• " + cardnumber
            }
            if let bank_name : String = AppModel.shared.currentUser.card["bank"] as? String
            {
                accountDetailLbl.text = accountDetailLbl.text! + "\n" + bank_name
            }
            
            if accountDetailLbl.text == ""
            {
                accountDetailLbl.text = "You have not added an account yet"
                addAccount.setTitle("ADD ACCOUNT", for: .normal)
                isUpdateAccount = false
            }
            else
            {
                addAccount.setTitle("UPDATE ACCOUNT", for: .normal)
                isUpdateAccount = true
            }
        }
    }
    
    @IBAction func clickToAddPaymentMethod(_ sender: Any) {
        if isStudentLogin()
        {
            displaySubViewtoParentView(AppDelegate().sharedDelegate().window, subview: self.creditCardView)
        }
        else
        {
            if isUpdateAccount
            {
                let vc : UpdateBankAccountVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "UpdateBankAccountVC") as! UpdateBankAccountVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                let vc : AccountDetailVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "AccountDetailVC") as! AccountDetailVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func clickToDelete(_ sender: Any) {
        var strMessage : String = ""
        if isStudentLogin()
        {
            strMessage = "Are you sure you want to delete this card?"
        }
        else
        {
            strMessage = "Are you sure you want to delete this Account?"
        }
        showAlertWithOption("Tutable", message: strMessage, completionConfirm: {
            APIManager.sharedInstance.serviceCallToDeletePaymentMethod({ (isSuccess) in
                if isSuccess
                {
                    if isStudentLogin()
                    {
                        displayToast("Payment Method Removed")
                    }
                    else
                    {
                        displayToast("Account Deleted Successfully")
                    }
                    
                    if isStudentLogin()
                    {
                        AppModel.shared.currentUser.card = [String : Any]()
                    }
                    else
                    {
                        AppModel.shared.currentUser.card = [String : Any]()
                    }
                    self.setDataValue()
                }
            })
        }) {
            
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //******************* Stripe Payment Start ************************//
    
    func cardDoneButtonClicked(_ card: Card?, error: String?) {
        
        if card == nil
        {
            creditCardView.removeFromSuperview()
        }
        else if card != nil
        {
            showLoader()
            let cardParams = STPCardParams()
            cardParams.name = card?.name
            cardParams.number = card?.number
            cardParams.expMonth = UInt((card?.month?.rawValue)!)!
            cardParams.expYear = UInt((card?.year!)!)!
            cardParams.cvc = card?.cvc
            
            STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
                removeLoader()
                if error == nil
                {
                    self.creditCardView.removeFromSuperview()
                    
                    let param : [String  :Any] = ["card" : token!.tokenId]
                    APIManager.sharedInstance.serviceCallToAddStripeToken(param, completion: { (isSuccess) in
                        if isSuccess
                        {
                            self.setDataValue()
                        }
                    })
                }
                else
                {
                    showAlert("Error", message: (error?.localizedDescription)!, completion: {
                        
                    })
                }
            }
        }
        else
        {
            displayToast("Invalid card details.")
        }
    }
    
    func cardTypeDidIdentify(_ cardType: String) {
        print(cardType)
    }
    
    //******************* Stripe Payment End ************************//
    
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
