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

    @IBOutlet weak var cardImgBtn: UIButton!
    @IBOutlet weak var cardNumberLbl: UILabel!
    
    @IBOutlet var creditCardView: UIView!
    @IBOutlet var cardView: MFCardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardView.delegate = self
        cardView.autoDismiss = false
        cardView.toast = true
        
        if let cardType : Int = AppModel.shared.currentUser.card["type"] as? Int
        {
            switch cardType {
                
            case 1:
                cardImgBtn.setImage(UIImage.init(named: "Visa"), for: .normal)
                break
                
            case 2:
                cardImgBtn.setImage(UIImage.init(named: "MasterCard"), for: .normal)
                break
                
            case 3:
                cardImgBtn.setImage(UIImage.init(named: "Amex"), for: .normal)
                break
                
            case 4:
                cardImgBtn.setImage(UIImage.init(named: "JCB"), for: .normal)
                break
                
            case 5:
                cardImgBtn.setImage(UIImage.init(named: "Discover"), for: .normal)
                break
                
            case 6:
                cardImgBtn.setImage(UIImage.init(named: "DinersClub"), for: .normal)
                break
            case 7:
                cardImgBtn.setImage(UIImage.init(named: "Maestro"), for: .normal)
                break
            case 8:
                cardImgBtn.setImage(UIImage.init(named: "Electron"), for: .normal)
                break
            case 9:
                cardImgBtn.setImage(UIImage.init(named: "Dankort"), for: .normal)
                break
            case 10:
                cardImgBtn.setImage(UIImage.init(named: "UnionPay"), for: .normal)
                break
            case 11:
                cardImgBtn.setImage(UIImage.init(named: "RuPay"), for: .normal)
                break
            default:
                cardImgBtn.setImage(nil, for: .normal)
                break
            }
        }
        
        if let cardnumber : String = AppModel.shared.currentUser.card["number"] as? String
        {
            cardNumberLbl.text = "•••• •••• •••• " + cardnumber
        }
        
    }

    @IBAction func clickToAddPaymentMethod(_ sender: Any) {
        displaySubViewtoParentView(self.view, subview: self.creditCardView)
    }
    
    @IBAction func clickToDelete(_ sender: Any) {
        showAlertWithOption("Tutable", message: "Are you sure you want to delete this card ?", completionConfirm: {
            APIManager.sharedInstance.serviceCallToDeletePaymentMethod({ (isSuccess) in
                if isSuccess
                {
                    displayToast("Payment method removed.")
                    self.clickToBack(self)
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
        
        if card != nil
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
                            self.clickToBack(self)
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
