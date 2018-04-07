//
//  TeacherAvailabilityVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

protocol TeacherAvailabilityDelegate {
    func selectedAvailability(dict : [String : [String]])
}

class TeacherAvailabilityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate : TeacherAvailabilityDelegate?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraintHeightDateView: NSLayoutConstraint!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    
    var timeArr : [[String : String]] = [["name" : "1 AM to 2 AM", "value" : "1-2"],
                                         ["name" : "2 AM to 3 AM", "value" : "2-3"],
                                        ["name" : "3 AM to 4 AM", "value" : "3-4"],
                                        ["name" : "4 AM to 5 AM", "value" : "4-5"],
                                        ["name" : "5 AM to 6 AM", "value" : "5-6"],
                                        ["name" : "6 AM to 7 AM", "value" : "6-7"],
                                        ["name" : "7 AM to 8 AM", "value" : "7-8"],
                                        ["name" : "8 AM to 9 AM", "value" : "8-9"],
                                        ["name" : "9 AM to 10 AM", "value" : "9-10"],
                                        ["name" : "10 AM to 11 AM", "value" : "10-11"],
                                        ["name" : "11 AM to 12 AM", "value" : "11-12"],
                                        ["name" : "12 AM to 1 PM", "value" : "12-13"],
                                        ["name" : "1 PM to 2 PM", "value" : "13-14"],
                                        ["name" : "2 PM to 3 PM", "value" : "14-15"],
                                        ["name" : "3 PM to 4 PM", "value" : "15-16"],
                                        ["name" : "4 PM to 5 PM", "value" : "16-17"],
                                        ["name" : "5 PM to 6 PM", "value" : "17-18"],
                                        ["name" : "6 PM to 7 PM", "value" : "18-19"],
                                        ["name" : "7 PM to 8 PM", "value" : "19-20"],
                                        ["name" : "8 PM to 9 PM", "value" : "20-21"],
                                        ["name" : "9 PM to 10 PM", "value" : "21-22"],
                                        ["name" : "10 PM to 11 PM", "value" : "22-23"],
                                        ["name" : "11 PM to 12 PM", "value" : "23-24"]
    ]
    
    var finalTimeDict : [String : [String]] = [String : [String]]()
    var selectedDateIndex : Int = 0
    
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
    
    @IBAction func clickToDone(_ sender: Any) {
        delegate?.selectedAvailability(dict: finalTimeDict)
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
        return timeArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell : CustomTimeSlotTVC = tblView.dequeueReusableCell(withIdentifier: "CustomTimeSlotTVC", for: indexPath) as! CustomTimeSlotTVC
        cell.titleLbl.text = timeArr[indexPath.row]["name"]
        
        cell.selectionBtn.isSelected = false
        if let tempArr : [String] = finalTimeDict[String(selectedDateIndex)] as? [String]
        {
            let index = tempArr.index { (strTime) -> Bool in
                strTime == timeArr[indexPath.row]["value"]
            }
            if index != nil
            {
                cell.selectionBtn.isSelected = true
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tempArr : [String] = finalTimeDict[String(selectedDateIndex)]!
        let index = tempArr.index { (strTime) -> Bool in
            strTime == timeArr[indexPath.row]["value"]
        }
        if index == nil
        {
            tempArr.append(timeArr[indexPath.row]["value"]!)
        }
        else
        {
            tempArr.remove(at: index!)
        }
        finalTimeDict[String(selectedDateIndex)] = tempArr
        tblView.reloadData()
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
