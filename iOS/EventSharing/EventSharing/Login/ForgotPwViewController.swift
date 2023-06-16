//
//  ForgotPwViewController.swift
//  EventSharing
//
//  Created by certimeter on 26/05/23.
//

import UIKit

protocol ForgotDelegate: LoginPresenter {
    func sendEmail(_ viewController: ForgotPwViewController, _ email: String)
}

class ForgotPwViewController: UIViewController {
    
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var sendButton: UIButton!
    weak var delegate: LoginPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        sendButton.layer.cornerRadius = 10
        container.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func sendAction(_ sender: Any) {
        guard let email = emailField.text else { return }
        delegate?.sendEmail(self, email)
    }
    
    @objc func dismissKey() {
        //view.endEditing(true);
     
        self.dismiss(animated: true)
        
    }
    

}

extension ForgotPwViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
}

