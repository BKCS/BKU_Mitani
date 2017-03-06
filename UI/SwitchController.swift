//
//  SwitchController.swift
//  UI
//
//  LocationController.swift
//  UI
//
//  Created by kien on 11/25/16.
//  Copyright © 2016 kien. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation
import SwiftMessages
import ExpandingMenu
import SystemConfiguration
import SCLAlertView

protocol AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: SwitchController, didAddCoordinate coordinate: CLLocationCoordinate2D,
                                        radius: Double, identifier: String, note: String)
}

class SwitchController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: -
    // MARK: Vars
    
    var timer : Timer = Timer()
    var timer1 : Timer = Timer()
    
    let locationManager = CLLocationManager()
    var speed : CLLocationSpeed = CLLocationSpeed()
    
    @IBOutlet weak var gpsquality: UIImageView!
    
    fileprivate var currentCoordiante: CLLocationCoordinate2D?
    
    @IBOutlet weak var SegmentedMaps: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    var ref: FIRDatabaseReference! = nil
    var utenteRef: FIRDatabaseReference! = nil
    var userId = FIRAuth.auth()?.currentUser?.uid    // MARK: -
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExpandingMenuButton()
        mapView.showsUserLocation = true

        ref = FIRDatabase.database().reference()
        utenteRef = ref.child("PATH").child("TEST-4")
        
        let runkeeperSwitch = DGRunkeeperSwitch(titles: ["OFF", "ON"])
        runkeeperSwitch.backgroundColor = UIColor(red: 229.0/255.0, green: 163.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        runkeeperSwitch.selectedBackgroundColor = .white
        runkeeperSwitch.titleColor = .white
        runkeeperSwitch.selectedTitleColor = UIColor(red: 255.0/255.0, green: 196.0/255.0, blue: 92.0/255.0, alpha: 1.0)
        runkeeperSwitch.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
        runkeeperSwitch.frame = CGRect(x: 30.0, y: 40.0, width: 100.0, height: 30.0)
        runkeeperSwitch.addTarget(self, action: #selector(SwitchController.switchValueDidChange(sender:)), for: .valueChanged)
        navigationItem.titleView = runkeeperSwitch
        
        
        }
    func setmap()
    {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        self.locationManager.allowsBackgroundLocationUpdates = true
        }
    public class Reachability {
        
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            
            return ret
            
        }
    }
        func checkgpsquality()
    {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkgps), userInfo: nil, repeats: true)
        
    }
    func checkgps()
    {
        let acc = locationManager.location!.verticalAccuracy
        if (acc > 10)
        {
           gpsquality.image = UIImage(named:"good-gps")
            self.view.addSubview(gpsquality)
            print("1")
        }
        if (acc < 10)
        {
            gpsquality.image = UIImage(named:"good-gps")
        }
    }
    func lcsef()
    {
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
                mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
            }
    
    // MARK: -
    @IBAction func MenuButton(_ sender: Any) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    @IBAction func WhenclickSegmented(_ sender: Any) {
        if (SegmentedMaps.selectedSegmentIndex == 0)
        {
            mapView.mapType = MKMapType.standard
        }
        if (SegmentedMaps.selectedSegmentIndex == 1)
        {
            mapView.mapType = MKMapType.hybrid
        }
        if (SegmentedMaps.selectedSegmentIndex == 2)
        {
            mapView.mapType = MKMapType.satellite
        }
    }
    
    func locationUser()
    {
        self.selfset()
    }
    @IBAction func locationUser(_ sender: Any) {
        self.selfset()
    }
  
    @IBAction func switchValueDidChange(sender: DGRunkeeperSwitch!) {
        if Reachability.isConnectedToNetwork() == true {
            if (sender.selectedIndex == 1)
            {
                setmap()
                repeat1()
                let view = MessageView.viewFromNib(layout: .CardView)
                view.configureTheme(.success)
                view.configureDropShadow()
                view.configureContent(title: "ON Mode", body: "Your Location will be collect!.")
                SwiftMessages.show(view: view)
            }
            if (sender.selectedIndex == 0)
            {
                let view = MessageView.viewFromNib(layout: .CardView)
                view.configureTheme(.error)
                view.configureDropShadow()
                view.configureContent(title: "OFF Mode", body: "Your Location not be collect!.")
                SwiftMessages.show(view: view)
                self.locationManager.stopUpdatingLocation()
                timer.invalidate()
            }
        } else {
            SCLAlertView().showTitle(
                "OOps", // Title of view
                subTitle: "NO Internet Connections.", // String of view
                duration: 2.0, // Duration to show before closing automatically, default: 0.0
                completeText: "OK", // Optional button value, default: ""
                style: .error, // Styles - see below.
                colorStyle: 0xA429FF,
                colorTextButton: 0xFFFFFF
            )

        }
    }
    
    func selfset()
    {
        let center = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
  
    func repeat1()
    {
        timergetlatlong()
    }
    func timergetlatlong()
    {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.collectdata), userInfo: nil, repeats: true)
      
    }
    
    func checkspeed()
    {
        let speed = locationManager.location!.speed
        if (speed < 0)
        {
            
            timer = Timer.scheduledTimer(timeInterval: 14.0, target: self, selector: #selector(self.checkspeed), userInfo: nil, repeats: true)
        }
        if (speed == 0)
        {
             timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.checkspeed), userInfo: nil, repeats: true)
        }
        
        if (speed > 0)
        {	
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.checkspeed), userInfo: nil, repeats: true)
        }
        self.collectdata()
    }
    
    func collectdata()
    {
        let date = Date();
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        speed = locationManager.location!.speed
        
        let localDate = dateFormatter.string(from: date as Date)
        utenteRef.child(localDate).setValue(["Latitude": locationManager.location!.coordinate.latitude, "Longitude": locationManager.location!.coordinate.longitude,"Speed":speed * 2.23693629, "Accuracy":locationManager.location!.verticalAccuracy])
    }
    
    fileprivate func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), centerImage: UIImage(named: "chooser-button-tab")!, centerHighlightedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 88.0)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Setting", image: UIImage(named: "chooser-moment-icon-music")!, highlightedImage: UIImage(named: "chooser-moment-icon-place-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            showAlert("Music")
        }
        
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "Search", image: UIImage(named: "chooser-moment-icon-place")!, highlightedImage: UIImage(named: "chooser-moment-icon-place-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            showAlert("Place")
        }
        
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "Vehicle", image: UIImage(named: "choose-moment-icon-vehicle-highlight")!, highlightedImage: UIImage(named: "choose-moment-icon-vehicle")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            self.performSegue(withIdentifier: "choosevehicle", sender: nil)
        }
        
        let item4 = ExpandingMenuItem(size: menuButtonSize, title: "Location", image: UIImage(named: "chooser-moment-icon-place")!, highlightedImage: UIImage(named: "chooser-moment-icon-place-highlighted")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            self.locationUser()
        }
        
        
        menuButton.addMenuItems([item1, item2, item3, item4])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("MenuItems dismissed.")
        }
    }

    
}

