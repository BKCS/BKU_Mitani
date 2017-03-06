//
//  ForgotPasswordController.swift
//  UI
//
//  Created by kien on 1/16/17.
//  Copyright © 2017 kien. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftMessages

class ForgotPasswordController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround2()
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        if (emailTextField.text! == "")
        {
            let view = MessageView.viewFromNib(layout: .CardView)
            view.configureTheme(.error)
            view.configureDropShadow()
            view.configureContent(title: "Error", body: "Please insert you Email!.")
            SwiftMessages.show(view: view)
        }
        else
        {
            FIRAuth.auth()?.sendPasswordReset(withEmail: self.emailTextField.text!, completion: {(error) in
            if error != nil
                {
                }
            else
                {
                    let view = MessageView.viewFromNib(layout: .CardView)
                    view.configureTheme(.success)
                    view.configureDropShadow()
                    view.configureContent(title: "Success", body: "Please check your Email to reset password!.")
                    SwiftMessages.show(view: view)
                    
                }
            })
        }

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
extension UIViewController {
    func hideKeyboardWhenTappedAround2() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard2() {
        view.endEditing(true)
    }
}
