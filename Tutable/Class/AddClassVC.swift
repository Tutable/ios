//
//  AddClassVC.swift
//  Tutable
//
//  Created by Keyur on 28/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import DropDown
import StepSlider
import Toaster

class AddClassVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var classNameTxt: UITextField!
    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var aboutClassTxt: UITextField!
    @IBOutlet weak var subjectTxt: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet var categoryContainerView: UIView!
    @IBOutlet weak var categoryPopupView: UIView!
    @IBOutlet weak var categoryTblView: UITableView!
    @IBOutlet weak var constraintHeightCategoryPopup: NSLayoutConstraint!
    @IBOutlet weak var levelSlider: StepSlider!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var underView: UIView!
    
    var classImg:UIImage!
    var categoryArr : [CategoryModel] = [CategoryModel]()
    var selectedCategory : CategoryModel = CategoryModel()
    var selectedLevel : Int = 2
    var isFromDashboard : Bool = false
    var classData : ClassModel = ClassModel.init(dict: [String : Any]())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isFromDashboard
        {
            titleLbl.text = "ADD CLASS"
        }
        else
        {
            titleLbl.text = "ADD YOUR FIRST CLASS"
        }
        
        AppModel.shared.currentClass = ClassModel.init(dict: classData.dictionary())
        
        setUIDesigning()
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
    }
    
    func setUIDesigning()
    {
        classImgBtn.addCornerRadiusOfView(5.0)
        nextBtn.addCornerRadiusOfView(nextBtn.frame.size.height/2)
        categoryPopupView.addCornerRadiusOfView(10.0)
        classNameTxt.autocapitalizationType = .sentences
        categoryTblView.register(UINib.init(nibName: "CustomTimeSlotTVC", bundle: nil), forCellReuseIdentifier: "CustomTimeSlotTVC")
        
        if getCategoryList().count == 0
        {
            APIManager.sharedInstance.serviceCallToGetCategory {
                self.setCategoryData()
            }
        }
        else
        {
            setCategoryData()
        }
        
        levelSlider.tintColor = UIColor.init(patternImage: UIImage.init(named: "bg_header")!)
        levelSlider.sliderCircleColor = colorFromHex(hex: COLOR.APP_COLOR)
        levelSlider.sliderCircleRadius = 5.0
        levelSlider.trackCircleRadius = 0.0
        levelSlider.addCornerRadiusOfView(2.0)
        levelSlider.setIndex(1, animated: true)
        setClassDetail()
    }
    
    func setClassDetail()
    {
        if AppModel.shared.currentClass.id == ""
        {
           return
        }
        classNameTxt.text = AppModel.shared.currentClass.name
        APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentClass.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [classImgBtn])
        selectedCategory = AppModel.shared.currentClass.category
        categoryBtn.setTitle(selectedCategory.title, for: .normal)
        selectedLevel = AppModel.shared.currentClass.level
        levelSlider.setIndex(UInt(selectedLevel-1), animated: false)
        aboutClassTxt.text = AppModel.shared.currentClass.bio
        subjectTxt.text = AppModel.shared.currentClass.whyQualified
    }
    
    func setCategoryData()
    {
        categoryArr = [CategoryModel]()
        let tempData : [[String : Any]] = getCategoryList()
        for temp in tempData
        {
            self.categoryArr.append(CategoryModel.init(dict: temp))
        }
    }
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        if self.tabBarController?.tabBar == nil
        {
            AppDelegate().sharedDelegate().navigateToDashboard()
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clickToUploadClassImg(_ sender: Any) {
        self.view.endEditing(true)
        uploadImage()
    }
    
    @IBAction func clickToSelectCategory(_ sender: Any) {
        self.view.endEditing(true)
        categoryTblView.reloadData()
        constraintHeightCategoryPopup.constant = CGFloat(categoryArr.count*50)
        if constraintHeightCategoryPopup.constant > (UIScreen.main.bounds.size.height - 100)
        {
            constraintHeightCategoryPopup.constant = (UIScreen.main.bounds.size.height - 100)
        }
        displaySubViewtoParentView(self.view, subview: categoryContainerView)
    }
    
    @IBAction func clickToCloseCategory(_ sender: Any) {
        categoryContainerView.removeFromSuperview()
    }
    
    @IBAction func clickToNext(_ sender: Any) {
        self.view.endEditing(true)
        
        if classNameTxt.text == ""
        {
            displayToast("Please enter class name")
        }
        else if selectedCategory.dictionary().count == 0
        {
            displayToast("Please select class category")
        }
        else if classImg == nil && AppModel.shared.currentClass.payload == ""
        {
            displayToast("Please select class image")
        }
        else if aboutClassTxt.text?.trimmed == ""
        {
            displayToast("Please enter about this class.")
        }
        else if subjectTxt.text?.trimmed == ""
        {
            displayToast("Please enter why you are qualified to teach this class.")
        }
        else
        {
            AppModel.shared.currentClass.name = classNameTxt.text
            AppModel.shared.currentClass.category = selectedCategory
            AppModel.shared.currentClass.level = Int(levelSlider.index + 1)
            AppModel.shared.currentClass.bio = aboutClassTxt.text
            AppModel.shared.currentClass.whyQualified = subjectTxt.text
            AppModel.shared.currentClass.timeline = Double(getCurrentTimeStampValue())
            
            let vc : ClassHourlyRateVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ClassHourlyRateVC") as! ClassHourlyRateVC
            vc.classImg = classImg
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTimeSlotTVC = categoryTblView.dequeueReusableCell(withIdentifier: "CustomTimeSlotTVC", for: indexPath) as! CustomTimeSlotTVC
        cell.titleLbl.text = categoryArr[indexPath.row].title
        cell.selectionBtn.setImage(UIImage.init(named: "check_circle_off"), for: .normal)
        cell.selectionBtn.setImage(UIImage.init(named: "check_circle_on"), for: .selected)
        
        if selectedCategory == categoryArr[indexPath.row]
        {
            cell.selectionBtn.isSelected = true
        }
        else
        {
            cell.selectionBtn.isSelected = false
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categoryArr[indexPath.row]
        categoryTblView.reloadData()
        categoryBtn.setTitle(selectedCategory.title, for: .normal)
        clickToCloseCategory(self)
    }
    
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        classImg = nil
        classImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
    }
    
    func onSelectPic(_ img: UIImage) {
        classImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        classImgBtn.setBackgroundImage(classImg.imageCropped(toFit: classImgBtn.frame.size), for: .normal)
    }
    
    // MARK: - Upload Image
    func uploadImage()
    {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelButton)
        
        let cameraButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            print("Camera")
            self.onCaptureImageThroughCamera()
        }
        actionSheet.addAction(cameraButton)
        
        let galleryButton = UIAlertAction(title: "Choose Existing Photo", style: .default)
        { _ in
            print("Gallery")
            self.onCaptureImageThroughGallery()
        }
        actionSheet.addAction(galleryButton)
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
        self.present(actionSheet, animated: true, completion: nil)
        
        onCaptureImageThroughCamera()
    }
    
    @objc open func onCaptureImageThroughCamera()
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            
        }
        else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    
    @objc open func onCaptureImageThroughGallery()
    {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        self.present(imgPicker, animated: true, completion: {() -> Void in
        })
    }
    
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        classImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        classImgBtn.setBackgroundImage(classImg.imageCropped(toFit: classImgBtn.frame.size), for: .normal)
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
