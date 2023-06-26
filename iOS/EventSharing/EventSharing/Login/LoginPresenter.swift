//
//  LoginPresenter.swift
//  EventSharing
//
//  Created by certimeter on 07/04/23.
//

import Foundation
import UIKit

final class LoginPresenter {
    
    private let loginService = LoginService()
    
    func presentAlert(_ viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 20.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        let attributedMessage = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 16) ?? UIFont.systemFont(ofSize: 16.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        viewController.present(alert, animated: true)
    }
}
extension LoginPresenter: LoginViewControllerDelegate {
    func presentForgotPw(_ viewController: LoginViewController) {
        let forgotViewController = ForgotPwViewController()
        forgotViewController.delegate = self
        forgotViewController.modalPresentationStyle = .overCurrentContext
        forgotViewController.modalTransitionStyle = .crossDissolve
        viewController.present(forgotViewController, animated: true)
    }
    
    func performLogin(_ viewController: LoginViewController, email: String, password: String) {
        if(email == "") {
            presentAlert(viewController, title: "Insert email",message: "")
            viewController.emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        if(password == "") {
            presentAlert(viewController, title: "Insert password",message: "")
            viewController.pwTextField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        loginService.login(email: email, pw: password){
            result in
            if result == "true" {
                PresenterManager.mainPresenter?.presentTabBar()
                print("GoHome")
            } else {
                if result.contains("password") {
                    viewController.pwTextField.layer.borderColor = UIColor.red.cgColor
                } else if result.contains("user") {
                    viewController.emailTextField.layer.borderColor = UIColor.red.cgColor
                }
                self.presentAlert(viewController, title: "Error", message: result)
                print("login goes boom")
            }
        }
    }
    
    func newUser(_ viewController: LoginViewController) {
        let signinController = SignInViewController()
        signinController.signDelegate = self
        viewController.navigationController?.pushViewController(signinController, animated: true)
        //PresenterManager.mainPresenter?.presentSignIn()
    }
}

extension LoginPresenter: SigninViewDelegate {
    
    func performSignin(_ viewController: SignInViewController, username: String, email: String, pw: String, image: UIImage) {
        
        if username == "" {
            presentAlert(viewController, title: "Insert a username", message: "")
            viewController.usernameTextField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        
        if email == "" {
            presentAlert(viewController, title: "Insert valid email", message: "")
            viewController.emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        
        if pw == "" {
            presentAlert(viewController, title: "Insert valid password", message: "")
            viewController.pwTextField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        
        loginService.signIn(viewController, username: username, email: email, pw: pw, image: image) {
            result in
            if result == "true" {
                print("Registrato con successo!")
                PresenterManager.mainPresenter?.presentTabBar()
            } else {
                self.presentAlert(viewController, title: "Error", message: result)
            }
        }
    }
    
}

extension LoginPresenter: ForgotDelegate {
    func sendEmail(_ viewController: ForgotPwViewController, _ email: String) {
        loginService.forgotPassword(email) { result in
            if result != nil {
                guard let message = result?.localizedDescription else { return }
                self.presentAlert(viewController, title: "Error", message: message)
                viewController.emailField.layer.borderColor = UIColor.red.cgColor
            } else {
                let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                let attributedTitle = NSAttributedString(string: "Email sended", attributes: [
                    NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 20.0, weight: .bold),
                    NSAttributedString.Key.foregroundColor: UIColor.red
                ])
                let attributedMessage = NSAttributedString(string: "check your mail box", attributes: [
                    NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 16) ?? UIFont.systemFont(ofSize: 16.0, weight: .bold),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ])
                alert.setValue(attributedTitle, forKey: "attributedTitle")
                alert.setValue(attributedMessage, forKey: "attributedMessage")
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default) {
                    (UIAlertAction) in
                    viewController.dismiss(animated: true)
                })
                viewController.present(alert, animated: true)
            }
        }
    }
}
