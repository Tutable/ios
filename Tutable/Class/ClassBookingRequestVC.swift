//
//  ClassBookingRequestVC.swift
//  Tutable
//
//  Created by Amisha on 4/6/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import MFCard
import Stripe

class ClassBookingRequestVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFCardDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraintHeightDateView: NSLayoutConstraint!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    
    @IBOutlet var creditCardView: UIView!
    @IBOutlet var cardView: MFCardView!
    
    var timeArr : [String] = [String]()
    
    var finalTimeDict : [String : [String]] = [String : [String]]()
    var selectedDateIndex : Int = 0
    var teacherData : UserModel = UserModel.init()
    var classData : ClassModel = ClassModel.init()
    var selectedSlotDict : [String : Any] = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomTimeSlotTVC", bundle: nil), forCellReuseIdentifier: "CustomTimeSlotTVC")
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        setButtonDesign(button: btn1)
        setButtonDesign(button: btn2)
        setButtonDesign(button: btn3)
        setButtonDesign(button: btn4)
        setButtonDesign(button: btn5)
        setButtonDesign(button: btn6)
        setButtonDesign(button: btn7)
        
        constraintHeightDateView.constant = ((UIScreen.main.bounds.size.width - 110)/7) + 27
        
        cardView.delegate = self
        cardView.autoDismiss = false
        cardView.toast = true
        
        setButtonLable()
        clickToSelectDate(btn1)
    }
    
    func setButtonDesign(button : UIButton)
    {
        button.addCircularRadiusOfView()
        button.setBackgroundImage(imageWithColor(color: colorFromHex(hex: COLOR.WHITE_COLOR)), for: .normal)
        button.setBackgroundImage(imageWithColor(color: colorFromHex(hex: COLOR.APP_COLOR)), for: .selected)
    }

    func setButtonLable()
    {
        for i in 1...7
        {
            let date : Date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
            let timestamp : Int = Int(getOnlyDateTimestamp(date: date))
            if (finalTimeDict[String(timestamp)] == nil)
            {
                finalTimeDict[String(timestamp)] = [String]()
            }
            
            switch i {
            case 1:
                btn1.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn1.tag = Int(timestamp)
                break
            case 2:
                btn2.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn2.tag = Int(timestamp)
                break
            case 3:
                btn3.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn3.tag = Int(timestamp)
                break
            case 4:
                btn4.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn4.tag = Int(timestamp)
                break
            case 5:
                btn5.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn5.tag = Int(timestamp)
                break
            case 6:
                btn6.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn6.tag = Int(timestamp)
                break
            case 7:
                btn7.setTitle(getDateOnlyFromDate(date: date), for: .normal)
                btn7.tag = Int(timestamp)
                break
            default:
                break
            }
        }
    }
    
    func resetButtonSelection()
    {
        btn1.isSelected = false
        btn2.isSelected = false
        btn3.isSelected = false
        btn4.isSelected = false
        btn5.isSelected = false
        btn6.isSelected = false
        btn7.isSelected = false
    }
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSelectDate(_ sender: UIButton) {
        resetButtonSelection()
        sender.isSelected = true
        selectedDateIndex = sender.tag
        tblView.reloadData()
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedDateIndex == 0
        {
            return 0
        }
        else if let arrTemp : [String] = teacherData.availability[String(selectedDateIndex)]
        {
            return arrTemp.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTimeSlotTVC = tblView.dequeueReusableCell(withIdentifier: "CustomTimeSlotTVC", for: indexPath) as! CustomTimeSlotTVC
        
        cell.titleLbl.text = ""
        cell.bookBtn.isHidden = true
        
        if let arrTemp : [String] = teacherData.availability[String(selectedDateIndex)], arrTemp.count > 0
        {
            let tempTimeStr : String = arrTemp[indexPath.row]
            
            let timeArr : [String] = tempTimeStr.components(separatedBy: "-")
            var startTime : String = timeArr[0]
            var endTime : String = timeArr[1]
            
            if Int(startTime)! > 12
            {
                cell.titleLbl.text = String(Int(startTime)! - 12) + " PM to "
            }
            else
            {
                if startTime.first == "0"
                {
                    startTime = startTime.replacingOccurrences(of: "0", with: "")
                }
                cell.titleLbl.text = startTime + " AM to "
            }
            
            if Int(endTime)! > 12
            {
                cell.titleLbl.text = cell.titleLbl.text! + String(Int(endTime)! - 12) + " PM"
            }
            else
            {
                if endTime.first == "0"
                {
                    endTime = endTime.replacingOccurrences(of: "0", with: "")
                }
                cell.titleLbl.text = cell.titleLbl.text! + endTime + " AM"
            }
            
            cell.bookBtn.isHidden = false
            cell.bookBtn.tag = indexPath.row
            cell.bookBtn.addTarget(self, action: #selector(clickToBook(_:)), for: .touchUpInside)
        }
        
        
        cell.selectionBtn.isHidden = true
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    @IBAction func clickToBook(_ sender: UIButton) {
        
        selectedSlotDict = [String : Any]()
        selectedSlotDict[String(selectedDateIndex)] = (teacherData.availability[String(selectedDateIndex)]?[sender.tag])!
        requestForBooking()
    }
    
    func requestForBooking()
    {
        APIManager.sharedInstance.serviceCallToBookClass(classData.id, slotDict: selectedSlotDict) { (dict) in
            if let code : Int = dict["code"] as? Int
            {
                if code == 100
                {
                    showAlert("Thanks!", message: "Your booking request has been submitted.\nWe will inform you once the teacher confirms the class.") {
                        self.clickToBack(self)
                    }
                }
                else if code == 104
                {
                    let myAlert = UIAlertController(title:"Tutable", message:dict["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.cancel, handler:{ (action) in
                        displaySubViewtoParentView(self.view, subview: self.creditCardView)
                    })
                    myAlert.addAction(okAction)
                    myAlert.view.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
                    self.present(myAlert, animated: true, completion: nil)
                }
                else
                {
                    print(dict["message"]!)
                }
            }
        }
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
                            self.requestForBooking()
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

