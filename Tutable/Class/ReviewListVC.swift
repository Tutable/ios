//
//  ReviewListVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ReviewListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataFound: UILabel!
    
    var classData : ClassModel = ClassModel.init()
    var reviewData : [ReviewModel] = [ReviewModel]()
    var offscreenReviewCell : [String : Any] = [String : Any] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomReviewsTVC", bundle: nil), forCellReuseIdentifier: "CustomReviewsTVC")
        getReviewsList()
    }

    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cell = offscreenReviewCell["CustomCommentTVC"] as? CustomReviewsTVC
        if cell == nil {
            cell = tblView.dequeueReusableCell(withIdentifier: "CustomReviewsTVC") as? CustomReviewsTVC
            offscreenReviewCell["CustomReviewsTVC"] = cell
        }
        if cell == nil
        {
            return 90
        }
        let review : ReviewModel = reviewData[indexPath.row]
        cell?.reviewLbl.text = review.review
        let height : Float = Float(90 - 32 + (cell?.reviewLbl.getLableHeight(extraWidth: 80))!)
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomReviewsTVC", for: indexPath) as! CustomReviewsTVC
        let review : ReviewModel = reviewData[indexPath.row]
        APIManager.sharedInstance.serviceCallToGetPhoto(review.student.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.profileImgBtn])
        cell.nameLbl.text = getFirstName(name: review.student.name)
        cell.starView.rating = review.stars
        cell.reviewLbl.text = review.review
        return cell
    }
    
    
    func getReviewsList()
    {
        APIManager.sharedInstance.serviceCallToGetReviewList(classData.id) { (dictArr) in
            self.reviewData = [ReviewModel]()
            for i in 0..<dictArr.count
            {
                let dict : [String : Any] = dictArr[i]
                let review : ReviewModel = ReviewModel.init()
                review.id = dict["_id"] as! String
                review.blocked = dict["blocked"] as! Int
                if AppModel.shared.currentUser.id == dict["by"] as! String
                {
                    review.student = AppModel.shared.currentUser
                }
                else
                {
                    let index = AppModel.shared.USERS.index(where: { (temp) -> Bool in
                        temp.id == dict["by"] as! String
                    })
                    if index != nil
                    {
                        review.student = UserModel.init(dict: AppModel.shared.USERS[index!].dictionary())
                    }
                }
                review.deleted = dict["deleted"] as! Int
                review.ref = dict["ref"] as! String
                review.review = dict["review"] as? String ?? ""
                review.stars = dict["stars"] as! Double
                self.reviewData.append(review)
            }
            self.tblView.reloadData()
            if self.reviewData.count == 0
            {
                self.noDataFound.isHighlighted = false
            }
            else
            {
                self.noDataFound.isHighlighted = true
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
