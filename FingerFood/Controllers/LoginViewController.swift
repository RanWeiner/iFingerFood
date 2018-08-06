//
//  LoginViewController.swift
//  FingerFood
//
//  Created by Mac on 18/07/2018.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import CoreLocation


class LoginViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var dataHandler : DataManager? = nil
    
    //default values - afeka tel aviv
    var latitude : Double = 32.113619
    var longitude : Double = 34.818165
 
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.getInstance().setLocation(latitude: self.latitude, longitude: self.longitude)
        
        ConnectionManager.shared.startMonitoring()
        
        if ConnectionManager.shared.isNetworkAvailable {
            dataHandler = DataManager.getInstance()
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        else {
            goToNetworkErrorVC()
        }
    }
    

    func goToNetworkErrorVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:  "NetworkUnavailableViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        let emailImage = UIImage(named: "mail")
        addLeftImageToTextField(txtField: emailTextField, image: emailImage!)
        
        let lockImage = UIImage(named: "lock")
        addLeftImageToTextField(txtField: passwordTextField, image: lockImage!)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func HighlightErrorTextField(textField : UITextField) {
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 3
        textField.layer.cornerRadius = 5
    }
    
    func addLeftImageToTextField(txtField : UITextField , image : UIImage) {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftImage.image = image
        txtField.leftView = leftImage
        txtField.leftViewMode = .always
    }
    
    @IBAction func passwordTextFieldEdit(_ sender: UITextField) {
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderWidth = 0
        passwordTextField.layer.cornerRadius = 5
    }
    
    
    @IBAction func emailTextFieldEdit(_ sender: UITextField) {
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.borderWidth = 0
        emailTextField.layer.cornerRadius = 5
    }
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        
        if ConnectionManager.shared.isNetworkAvailable == false  { goToNetworkErrorVC() }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            HighlightErrorTextField(textField: emailTextField)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            HighlightErrorTextField(textField: passwordTextField)
            return
        }
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !pred.evaluate(with: email) || password.count < 6 {
            self.view.makeToast("email or password inccorect!", duration: 3.0 , position: .bottom)
            return
        }
        SVProgressHUD.show()

        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                SVProgressHUD.dismiss()
                self.view.makeToast("Couldn't sign in.. Please make sure you entered the right email and password", duration: 4.0 , position: .bottom)
                print("error creating user = \(String(describing: error))")
            }
            else {
                
                if let userId = user?.user.uid {
                    User.getInstance().setUserID(userId: userId)
                    self.dataHandler = DataManager.getInstance()
                    self.dataHandler?.readUserName(userId: userId)
                    self.dataHandler?.readData(userId: userId, callback: {
                    SVProgressHUD.dismiss()
                    self.goToMainVC()
                    })
                    print("lat = \(self.latitude) , long = \(self.longitude)")
                    
                }
            }
            })
        }

    func goToMainVC() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier:  "MainViewController")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
  
    @IBAction func forgotPasswordBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:  "ForgotPasswordViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:  "RegisterViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
        
            print("longitude = \(location.coordinate.longitude) , latitude = \(location.coordinate.latitude) ")
            
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            User.getInstance().setLocation(latitude: latitude, longitude: longitude)

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.view.makeToast("Location Unavailable")
    }
    
    
}



extension UITextField{
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.placeholderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

