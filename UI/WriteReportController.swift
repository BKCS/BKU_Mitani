//
//  WriteReportController.swift
//  UI
//
//  Created by kien on 12/13/16.
//  Copyright © 2016 kien. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import AVFoundation
import SpeechToTextV1
import ExpandingMenu
import CoreLocation


class WriteReportController: UIViewController,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate
{
    var recorder : AVAudioRecorder!
    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var isStreaming = false
    var ref: FIRDatabaseReference! = nil
    var utenteRef: FIRDatabaseReference! = nil
    var userId = FIRAuth.auth()?.currentUser?.uid
    var activityViewController : UIActivityViewController!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var subjectTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var report_image: UIImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        textView.delegate = self
        
        ref = FIRDatabase.database().reference()
        utenteRef = ref.child("REPORT")
        
        self.hideKeyboardWhenTappedAround1()
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("News", for: .normal)
        titleButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20.0)
        titleButton.setTitleColor(UIColor.white, for: .normal)
        //titleButton.addTarget(self, action: Selector("titlepressed:"), for: UIControlEvents.touchUpInside)
        self.navigationItem.titleView = titleButton
        
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        speechToTextSession = SpeechToTextSession(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
    
        configureExpandingMenuButton1()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func sendReport(_ sender: UIButton) {
        if (subjectTextField.text == "" && textView.text == "Your content for report: ")
        {
            EZLoadingActivity.showWithDelay("Nothing...", disableUI: false, seconds: 3)
            EZLoadingActivity.hide(false, animated: true)
        }
        else
        {
        let date = Date();
        let dateFormatter = DateFormatter()
        let subject = subjectTextField.text
        let content = textView.text
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let localDate = dateFormatter.string(from: date as Date)
        utenteRef.child("1").child(localDate).setValue(["Subject": subject, "Content": content,"Latitude": locationManager.location!.coordinate.latitude, "Longitude":
            locationManager.location!.coordinate.longitude])
        EZLoadingActivity.showWithDelay("Sending...", disableUI: false, seconds: 3)
        }
    }
    func sharebutton()
    {
        if self.textView.text!.isEmpty {
            let alert = UIAlertController(title: "Sharing Option", message: "There is nothong in Tet", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert,animated: true, completion: nil )
        } else
        {
            activityViewController = UIActivityViewController(activityItems: [self.textView.text], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func importimage()
    {
        let PickerController = UIImagePickerController()
            PickerController.sourceType = .photoLibrary
            PickerController.delegate = self
            PickerController.allowsEditing = true
        self.present(PickerController, animated: true, completion: nil)
        
        
            }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any])
    {
        let selectPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.report_image.image = selectPhoto
        report_image.layer.cornerRadius = 10
        report_image.clipsToBounds = true
        report_image.layer.borderColor = UIColor.white.cgColor
        report_image.layer.borderWidth = 3
        
        
        var attributedString :NSMutableAttributedString!
        attributedString = NSMutableAttributedString(attributedString:textView.attributedText)
        let textAttachment = NSTextAttachment()
        //textAttachment.image = UIImage(named: "menu-top")!
        textAttachment.image = report_image.image
        
        let oldWidth = textAttachment.image!.size.width;
        
        //I'm subtracting 10px to make the image display nicely, accounting
        //for the padding inside the textView
        
        let scaleFactor = oldWidth / (textView.frame.size.width - 10);
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        textView.attributedText = attributedString;
        

        self.dismiss(animated: true, completion:nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        	
    }
    
    @IBAction func MenuButton(_ sender: Any) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == "Your content for report: "){
            textView.text = ""
        }
        textView.becomeFirstResponder()    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = "Your content for report: "
        }
        textView.resignFirstResponder()
    }
    
    @IBAction func speechToText(_ sender: Any) {
        streamMicrophoneBasic()
    }
   
    public func streamMicrophoneBasic() {
        if !isStreaming {
            
            isStreaming = true
            var settings = RecognitionSettings(contentType: .opus)
            settings.continuous = true
            settings.interimResults = true
            let failure = { (error: Error) in print(error) }
            speechToText.recognizeMicrophone(settings: settings, failure: failure) {
                results in
                self.textView.text = results.bestTranscript
            }
            
        } else {
            
            // update state
            // microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToText.stopRecognizeMicrophone()
        }
    }
    
    /**
     This function demonstrates how to use the more advanced
     `SpeechToTextSession` class to transcribe microphone audio.
     */
    public func streamMicrophoneAdvanced() {
        if !isStreaming {
            
            // update state
            //  microphoneButton.setTitle("Stop Microphone", for: .normal)
            isStreaming = true
            
            // define callbacks
            speechToTextSession.onConnect = { print("connected") }
            speechToTextSession.onDisconnect = { print("disconnected") }
            speechToTextSession.onError = { error in print(error) }
            speechToTextSession.onPowerData = { decibels in print(decibels) }
            speechToTextSession.onMicrophoneData = { data in print("received data") }
            speechToTextSession.onResults = { results in self.textView.text = results.bestTranscript }
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.continuous = true
            settings.interimResults = true
            
            // start recognizing microphone audio
            speechToTextSession.connect()
            speechToTextSession.startRequest(settings: settings)
            speechToTextSession.startMicrophone()
            
        } else {
            
            // update state
            // microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToTextSession.stopMicrophone()
            speechToTextSession.stopRequest()
            speechToTextSession.disconnect()
        }
    }
    
    fileprivate func configureExpandingMenuButton1() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), centerImage: UIImage(named: "chooser-button-tab")!, centerHighlightedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 80.0)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Settings", image: UIImage(named: "chooser-moment-icon-music")!, highlightedImage: UIImage(named: "chooser-moment-icon-place-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            showAlert("Music")
        }
        
     
        
        let item4 = ExpandingMenuItem(size: menuButtonSize, title: "Insert wav File", image: UIImage(named: "chooser-moment-icon-thought")!, highlightedImage: UIImage(named: "chooser-moment-icon-thought-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            showAlert("Thought")
        }
        
        let item5 = ExpandingMenuItem(size: menuButtonSize, title: "Insert image", image: UIImage(named: "chooser-moment-icon-sleep")!, highlightedImage: UIImage(named: "chooser-moment-icon-sleep-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            self.importimage()
        }
        
        menuButton.addMenuItems([item1,  item4, item5])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("MenuItems dismissed.")
        }
    }

    
}



extension UIViewController {
    func hideKeyboardWhenTappedAround1() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard1))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard1() {
        view.endEditing(true)
    }
}
