//
//  PhotoSelectionVC.swift
//  ToShare
//
//  Created by ToShare Pty. Ltd. on 1/18/18.
//  Copyright © 2018 ToShare Pty. Ltd. All rights reserved.
//

import UIKit
//import PEPhotoCropEditor

protocol PhotoSelectionDelegate{
    func onRemovePic()
    func onSelectPic(_ img:UIImage)
}

class PhotoSelectionVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{//, PECropViewControllerDelegate {

    var delegate:PhotoSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK:- Button Tap
    @IBAction func onDismissVC(_ sender: Any) {
        displaySubViewWithScaleInAnim(self.view)
    }
    
    @IBAction func onCaptureImageThroughCamera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            self.view.removeFromSuperview()
        }
        else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction func onCaptureImageThroughGallery(_ sender: Any) {
        self.view.removeFromSuperview()
        DispatchQueue.main.async {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    @IBAction func onPicRemove(_ sender: Any) {
        self.view.removeFromSuperview()
        delegate?.onRemovePic()
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        self.view.removeFromSuperview()
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        delegate?.onSelectPic(selectedImage!)
//        let controller = PECropViewController()
//        controller.delegate = self as PECropViewControllerDelegate
//        controller.image = selectedImage
//        controller.keepingCropAspectRatio = true
//        controller.toolbarHidden = true
//        let width: CGFloat? = selectedImage?.size.width
//        let height: CGFloat? = selectedImage?.size.height
//        let length: CGFloat = min(width!, height!)
//        controller.imageCropRect = CGRect(x: CGFloat((width! - length) / 2), y: CGFloat((height! - length) / 2), width: length, height: length)
//        let navigationController = UINavigationController(rootViewController: controller)
//        self.present(navigationController, animated: true, completion: nil)
    }
    
//    //MARK:- PECropViewControllerDelegate
//    func cropViewController(_ controller: PECropViewController, didFinishCroppingImage croppedImage: UIImage) {
//        controller.dismiss(animated: true, completion: nil)
//        delegate?.onSelectPic(croppedImage)
//    }
//    
//    func cropViewControllerDidCancel(_ controller: PECropViewController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
