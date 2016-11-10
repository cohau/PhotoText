//
//  ViewController.swift
//  PhotoText
//
//  Created by Colin Au on 8/3/16.
//  Copyright © 2016 Colin Au. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var replaceTextField: UITextField!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    var activityIndicator:UIActivityIndicatorView!
    var originalTopMargin:CGFloat!
    
    override func viewDidLoad() {
        let topColor = UIColor(red: (152.0/255.0), green:(242.0/255.0), blue:(255.0/255.0), alpha: 1)
        let bottomColor = UIColor(red: (0.0/255.0), green:(100.0/255.0), blue:(164.0/255.0), alpha: 1)
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1,0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        originalTopMargin = topMarginConstraint.constant
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let camButton = UIAlertAction(title: "Take a Photo", style: .Default) {
                (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(camButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Photo from Photo Library", style: .Default) {
            (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in }
        
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func swapText(sender: AnyObject) {
        if let text = textView.text, let findText = findTextField.text,
            let replaceText = replaceTextField.text {
            
            
            //added ! to a few
            textView.text = text.stringByReplacingOccurrencesOfString(findText, withString: replaceText, options: [], range: nil)
            
            findTextField.text = nil
            replaceTextField.text = nil
            
            view.endEditing(true)
            moveViewDown()
        }
            
    }
    
    //@IBAction func sharePoem(sender: AnyObject) {
        
    //}
    
    
    //MARK: Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    
    // The remaining methods handle the keyboard resignation/
    // move the view so that the first responders aren't hidden
    
    func moveViewUp() {
        if topMarginConstraint.constant != originalTopMargin {
            return
        }
        
        topMarginConstraint.constant -= 135
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func moveViewDown() {
        if topMarginConstraint.constant == originalTopMargin {
            return
        }
        
        topMarginConstraint.constant = originalTopMargin
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
//-----------------------------------
//textView = "" //to make it clear
//-----------------------------------
    }
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }
    
    func performImageRecognition(image: UIImage) {
        //1
        let tesseract = G8Tesseract()
        //2
        tesseract.language = "eng"
        //3
        tesseract.engineMode = .TesseractCubeCombined
        // 4
        tesseract.pageSegmentationMode = .Auto
        // 5
        tesseract.maximumRecognitionTime = 60.0
        // 6
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        // 7
        textView.text = tesseract.recognizedText
        textView.editable = true
        // 8
        removeActivityIndicator()
    }
    
    let speech = AVSpeechSynthesizer()
    
    @IBAction func speakWords(sender: AnyObject) {
        let speechUtter = AVSpeechUtterance(string: textView.text)
        
        speech.speakUtterance(speechUtter)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        moveViewUp()
    }
    
    @IBAction func textFieldEndEditing(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        moveViewDown()
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let scaledImage = scaledImage(selectedPhoto,maxDimension:640)
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(selectedPhoto)
            //self.performImageRecognition(scaledImage)
        })
            
    }
}

