//
//  ClassBookingRequestVC.swift
//  Tutable
//
//  Created by Amisha on 4/6/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ClassBookingRequestVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraintHeightDateView: NSLayoutConstraint!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    
    var timeArr : [String] = [String]()
    
    var finalTimeDict : [String : [String]] = [String : [String]]()
    var selectedDateIndex : Int = 0
    var teacherData : UserModel = UserModel.init()
    var classData : ClassModel = ClassModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomTimeSlotTVC", bundle: nil), forCellReuseIdentifier: "CustomTimeSlotTVC")
        timeArr = Array(teacherData.availability.keys).sorted()
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
            let timestamp : Double = Double(timeArr[i-1])!
            let date : Date = getDateFromTimeStamp(timestamp)
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
        return teacherData.availability[String(selectedDateIndex)]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTimeSlotTVC = tblView.dequeueReusableCell(withIdentifier: "CustomTimeSlotTVC", for: indexPath) as! CustomTimeSlotTVC
        
        let tempTimeStr : String = (teacherData.availability[String(selectedDateIndex)]?[indexPath.row])!
        
        let timeArr : [String] = tempTimeStr.components(separatedBy: "-")
        let startTime : String = timeArr[0]
        let endTime : String = timeArr[1]
        
        if Int(startTime)! > 12
        {
            cell.titleLbl.text = String(Int(startTime)! - 12) + " PM to "
        }
        else
        {
            cell.titleLbl.text = startTime + " AM to "
        }
        
        if Int(endTime)! > 12
        {
            cell.titleLbl.text = cell.titleLbl.text! + String(Int(endTime)! - 12) + " PM"
        }
        else
        {
            cell.titleLbl.text = cell.titleLbl.text! + endTime + " AM"
        }
        
        cell.bookBtn.isHidden = false
        cell.bookBtn.tag = indexPath.row
        cell.bookBtn.addTarget(self, action: #selector(clickToBook(_:)), for: .touchUpInside)
        
        cell.selectionBtn.isHidden = true
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    @IBAction func clickToBook(_ sender: UIButton) {
        print(timeArr[sender.tag])
        var slotDict : [String : Any] = [String : Any]()
        slotDict[String(selectedDateIndex)] = (teacherData.availability[String(selectedDateIndex)]?[sender.tag])!
        APIManager.sharedInstance.serviceCallToBookClass(classData.id, slotDict: slotDict) { (isSuccess) in
            if isSuccess
            {
                showAlert("Thanks!", message: "Your booking request has been submitted.\nWe will inform you once the teacher confirms the class.") {
//                    let vc : CreditCardDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditCardDetailVC") as! CreditCardDetailVC
//                    self.navigationController?.pushViewController(vc, animated: true)
                    self.clickToBack(self)
                }
            }
        }
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

