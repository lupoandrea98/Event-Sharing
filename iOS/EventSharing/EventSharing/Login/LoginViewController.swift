//
//  LoginViewController.swift
//  EventSharing
//
//  Created by certimeter on 07/04/23.
//

import UIKit
import Firebase
import GoogleSignIn

protocol LoginViewControllerDelegate: AnyObject {
    func newUser(_ viewController: LoginViewController)
    func performLogin(_ viewController: LoginViewController, email: String, password: String)
    func presentForgotPw(_ viewController: LoginViewController)
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?

    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var pwTextField: CustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var bottomLoginConstraint: NSLayoutConstraint!
    //@IBOutlet weak var googleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        pwTextField.delegate = self
        
        loginButton.layer.cornerRadius = 10
    
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
               return
           }
        let keyboardHeight = keyboardFrame.height

        bottomLoginConstraint.constant = keyboardHeight - 100
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
       }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomLoginConstraint.constant = 120
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        delegate?.performLogin(self, email: emailTextField.text!, password: pwTextField.text!)
    }
    @IBAction func signinAction(_ sender: Any) {
        delegate?.newUser(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKey() {
        view.endEditing(true);
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        delegate?.presentForgotPw(self)
    }
    

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
}
