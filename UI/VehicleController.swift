//
//  VehicleController.swift
//  UI
//
//  Created by kien on 1/8/17.
//  Copyright © 2017 kien. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import SCLAlertView

class VehicleController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    let segues = ["Plane","Rail","Ship","Bus","Car","Motorbike","Bike","Run","More..."]
    var arrImageName: [String] = ["plane-vehicle", "rail-vehicle", "ship-vehicle","bus-vehicle","car-vehicle","motorbike-vehicle","bike-vehicle","run-vehicle","more-vehicle"]
    let segues1 = ["\n","\n", "\n", "\n"]
    let kSuccessTitle = "Congratulations"
    let kErrorTitle = "Connection error"
    let kNoticeTitle = "Notice"
    let kWarningTitle = "Warning"
    let kInfoTitle = "Info"
    let kSubtitle = "You've just displayed this awesome Pop Up View"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infButton: UIButton!
    var ref: FIRDatabaseReference! = nil
    var utenteRef1: FIRDatabaseReference! = nil
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        utenteRef1 = ref.child("VEHICLE")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 300.0
        self.tableView.rowHeight = UITableViewAutomaticDimension//// Do any additional setup after loading the view.

        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Vehicle", for: .normal)
        titleButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20.0)
        titleButton.setTitleColor(UIColor.white, for: .normal)
        //titleButton.addTarget(self, action: Selector("titlepressed:"), for: UIControlEvents.touchUpInside)
        self.navigationItem.titleView = titleButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCellVehicle", for: indexPath)
        cell.textLabel?.text = segues[(indexPath as NSIndexPath).row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: "AppleSDGothicNeo-Bold"))
        cell.imageView?.image = UIImage(named:self.arrImageName[indexPath.row])
        cell.textLabel?.font = UIFont(name:"AppleSDGothicNeo-Bold", size:14)
      //  cell.textLabel?.textAlignment = .center
    
        return cell
        
    }
    private func tableView(_ heightForRowAttableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat
    {
        return 800 //cell height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Date();
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let localDate = dateFormatter.string(from: date as Date)
        if (indexPath.row == 0)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Plane", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 1)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Rail", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 2)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Ship", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 3)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Bus", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 4)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Car", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 5)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Motorbike", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 6)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Bike", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            let alert = SCLAlertView()
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)

        }
        if (indexPath.row == 7)
        {
            utenteRef1.child("1").child(localDate).setValue(["Transport": "Run", "Latitude": locationManager.location!.coordinate.latitude, "Longitude":
                locationManager.location!.coordinate.longitude])
            
        }
    }
    
   }
