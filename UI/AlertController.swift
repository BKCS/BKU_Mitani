//
//  AlertController.swift
//  UI
//
//  Created by kien on 2/13/17.
//  Copyright © 2017 kien. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import AVFoundation
import Firebase
import FirebaseStorage

class AlertController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate {
let locationManager = CLLocationManager()
var ref: FIRDatabaseReference! = nil
var isboxclicked: Bool!
    var player:AVAudioPlayer!
    var recorder: AVAudioRecorder!
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var statusLabel: UILabel!
    
    var meterTimer:Timer!
    
    var soundFileURL:URL!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        isboxclicked = false
        GMSServices.provideAPIKey("AIzaSyDqU52Dby7tw4bWwnd2robEB7ghKYgTuxQ")
        
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        let button = UIButton(frame: CGRect(x: 250, y: 380, width: 60, height: 60))
        button.setBackgroundImage(UIImage(named: "alert-icon.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(buttonTapAction), for: UIControlEvents.touchUpInside)
                self.view.addSubview(button)
        let buttonemergency = UIButton(frame: CGRect(x: 70, y: 20, width: 180, height: 80))
        buttonemergency.setBackgroundImage(UIImage(named: "emergency-mode.png"), for: UIControlState.normal)
        buttonemergency.addTarget(self, action: #selector(alertmode), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonemergency)
        
     
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Alert", for: .normal)
        titleButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20.0)
        titleButton.setTitleColor(UIColor.white, for: .normal)
        self.navigationItem.titleView = titleButton
        navigationController!.navigationBar.isTranslucent = false
   
    }
    func updateAudioMeter(_ timer:Timer) {
        
        if recorder.isRecording {
                        recorder.updateMeters()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    func stoprecord()
    {
        print("stop")
        
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        storagefirebase()
    }
    func storagefirebase()
    {
        setSessionPlayback()
        play()
    }
    
    func play() {
        
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let localFile = soundFileURL
        
        let riversRef = storageRef.child("Records-File/record.m4a")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = riversRef.putFile(localFile!, metadata: nil) { metadata, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                _ = metadata!.downloadURL()
            }
        }


    }
    func alertmode()
    {
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
            
            
        } else {
            recordWithPermission(false)
        }
        
    }
    
    func buttonTapAction()
    {

        print("stop")
        
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        storagefirebase()

     /*   if self.isboxclicked == true {
            self.isboxclicked = false
        } else {
            self.isboxclicked = true
        }
        
        if self.isboxclicked == true
        {
            ref = FIRDatabase.database().reference(fromURL: "https://ios-login-c71ab.firebaseio.com/ALERT")
            ref.observe(.childAdded, with:
                {
                    snapshot in
                    let snapshotValue1 = snapshot.value as? NSDictionary
                    let lat = snapshotValue1?["Latitude"] as! Double
                    let long = snapshotValue1?["Longitude"] as! Double
                    let radius = snapshotValue1?["Radius"] as! Double
                    let circleCenter = CLLocationCoordinate2D(latitude: lat , longitude: long)
                    let circle = GMSCircle(position: circleCenter, radius: radius)
                    circle.strokeColor = UIColor.blue
                    circle.strokeWidth = 3
                    circle.fillColor = UIColor(red: 0.85, green: 0, blue: 0, alpha: 0.2)
                    circle.map = self.view as! GMSMapView?
                    
                    let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let marker = GMSMarker(position: position)
                    marker.title = "Zika"
                    marker.icon = UIImage(named: "alert-icon-1.png")
                    marker.map = self.view as! GMSMapView?
                    
                    
                    
            })
        } else {
            ref = FIRDatabase.database().reference(fromURL: "https://ios-login-c71ab.firebaseio.com/ALERT")
            ref.observe(.childAdded, with:
                {
                    snapshot in
                    let snapshotValue1 = snapshot.value as? NSDictionary
                    let lat = snapshotValue1?["Latitude"] as! Double
                    let long = snapshotValue1?["Longitude"] as! Double
                    let radius = snapshotValue1?["Radius"] as! Double
                    let circleCenter = CLLocationCoordinate2D(latitude: lat , longitude: long)
                    let circle = GMSCircle(position: circleCenter, radius: radius)
                    circle.strokeColor = UIColor.blue
                    circle.strokeWidth = 3
                    circle.fillColor = UIColor(red: 0.85, green: 0, blue: 0, alpha: 0.2)
                
                    
                    let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let marker = GMSMarker(position: position)
                    marker.title = "Zika"
                    marker.icon = UIImage(named: "alert-icon-1.png")
                    marker.map = nil
                    
                    
                    
            })

        }*/
    
    }
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:2),
            AVSampleRateKey :          NSNumber(value:44100.0)
        ]
        
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target:self,
                                                           selector:#selector(AlertController.updateAudioMeter(_:)),
                                                           userInfo:nil,
                                                           repeats:true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func deleteAllRecordings() {
        let docsDir =
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
    }
    
    func askForNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(AlertController.background(_:)),
                                               name:NSNotification.Name.UIApplicationWillResignActive,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(AlertController.foreground(_:)),
                                               name:NSNotification.Name.UIApplicationWillEnterForeground,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(AlertController.routeChange(_:)),
                                               name:NSNotification.Name.AVAudioSessionRouteChange,
                                               object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    
    func routeChange(_ notification:Notification) {
        print("routeChange \((notification as NSNotification).userInfo)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    @IBAction
    func trim() {
        if self.soundFileURL == nil {
            print("no sound file")
            return
        }
        
        print("trimming \(soundFileURL!.absoluteString)")
        print("trimming path \(soundFileURL!.lastPathComponent)")
        let asset = AVAsset(url:self.soundFileURL!)
        exportAsset(asset, fileName: "trimmed.m4a")
    }
    
    func exportAsset(_ asset:AVAsset, fileName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        
        
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch let error as NSError {
                NSLog("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
            }
            
        }
        
        print("creating export session for \(asset)")
        
                if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileTypeAppleM4A
            exporter.outputURL = trimmedSoundFileURL
            
            let duration = CMTimeGetSeconds(asset.duration)
            if (duration < 5.0) {
                print("sound is not long enough")
                return
            }
            // e.g. the first 5 seconds
            let startTime = CMTimeMake(0, 1)
            let stopTime = CMTimeMake(5, 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    
                    if let e = exporter.error as? NSError {
                        print("export failed \(e)")
                        switch e.code {
                        case AVError.Code.fileAlreadyExists.rawValue:
                            print("File Exists")
                            break
                        default: break
                        }
                    } else {
                        print("export failed")
                    }
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(exporter.error)")
                default:
                    print("export complete")
                }
            })
        } else {
            print("cannot create AVAssetExportSession for asset \(asset)")
        }
        
    }
    
    @IBAction
    func speed() {
        let asset = AVAsset(url:self.soundFileURL!)
        exportSpeedAsset(asset, fileName: "trimmed.m4a")
    }
    
    func exportSpeedAsset(_ asset:AVAsset, fileName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists")
        }
        
        print("creating export session for \(asset)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileTypeAppleM4A
            exporter.outputURL = trimmedSoundFileURL
            
                       exporter.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed
            
            
            
            
            let duration = CMTimeGetSeconds(asset.duration)
            if (duration < 5.0) {
                print("sound is not long enough")
                return
            }
           
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    print("export failed \(exporter.error)")
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(exporter.error)")
                default:
                    print("export complete")
                }
            })
        }
    }
    

   

}
extension AlertController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        print("finished recording \(flag)")
        
        // iOS8 and later
        let alert = UIAlertController(title: "Recorder",
                                      message: "Finished Recording",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
            print("keep was tapped")
            self.recorder = nil
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
            print("delete was tapped")
            self.recorder.deleteRecording()
        }))
        self.present(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension AlertController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
}

