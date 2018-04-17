//
//  PhotoSelectionActionSheet.swift
//  Tutable
//
//  Created by Keyur on 17/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

protocol PhotoSelectionActionSheetDelegate{
    func onRemovePic()
    func onSelectPic(_ img:UIImage)
}

class PhotoSelectionActionSheet: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let shared = DatePickerManager()
    var actionSheet: UIAlertController!
    var imgPicker = UIImagePickerController()
    var delegate:PhotoSelectionActionSheetDelegate?
    
    private typealias PickerCompletionBlock  = (_ cancel: Bool) -> Void
    private var pickerCompletion: PickerCompletionBlock?
    
    @objc open func selectImage() {
        actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        UIViewController.top?.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc open func onCaptureImageThroughCamera()
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            
        }
        else {
            imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            UIViewController.top?.present(imgPicker, animated: true, completion: {() -> Void in
            })
            actionSheet.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc open func onCaptureImageThroughGallery()
    {
        actionSheet.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.imgPicker = UIImagePickerController()
            self.imgPicker.delegate = self
            self.imgPicker.sourceType = .photoLibrary
            UIViewController.top?.present(self.imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        delegate?.onSelectPic(selectedImage!)
    }
}
