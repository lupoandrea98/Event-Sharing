//
//  SigninViewController.swift
//  EventSharing
//
//  Created by certimeter on 11/04/23.
//

import UIKit

protocol SigninViewDelegate: AnyObject {
    func performSignin(_ viewController: SignInViewController, username: String, email: String, pw: String, image: UIImage)
}
protocol ModifyViewDelegate: AnyObject {
    func performModify(_ viewContoroller: SignInViewController, username: String, email: String, oldPassword: String, password: String, image: UIImage?)
}

class SignInViewController: UIViewController {
    
    weak var signDelegate: SigninViewDelegate?
    weak var modifyDelegate: ModifyViewDelegate?
    weak var parentView: ProfileViewController?
    var userAddPhoto: Bool = false
    var userUpdatePhoto: Bool  = false
    var username: String? = nil
    var email: String? = nil
    var profileImage: UIImage? = nil
    var isModify: Bool = false
    
    @IBOutlet weak var trashImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var pwTextField: CustomTextField!
    @IBOutlet weak var pwconfTextField: CustomTextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var bottomPasswordConsraint: NSLayoutConstraint!
    @IBOutlet var bottomImageConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        pwTextField.delegate = self
        pwconfTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        view.addGestureRecognizer(tapGesture)
        
        let trashGesture = UITapGestureRecognizer(target: self, action: #selector(delImage))
        trashImage.addGestureRecognizer(trashGesture)
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 22)!
        ]
        signinButton.layer.cornerRadius = 10
        addImage.layer.cornerRadius = 10
        userPhoto.layer.cornerRadius = 20
        self.title = "SignUp"
        if userPhoto.image == nil {
            userPhoto.image = UIImage(named: "userStandard")
        }
        
        if isModify {
            infoLabel.alpha = 1
           
            self.navigationItem.title = ""
            usernameTextField.text = username ?? ""
            emailTextField.text = email ?? ""
            if let userPhoto = profileImage {
                self.userPhoto.image = userPhoto
            }
            if userPhoto.image?.pngData() != UIImage(named: "userStandard")?.pngData() {
                trashImage.alpha = 1
                trashImage.isUserInteractionEnabled = true
            }
            pwTextField.placeholder = "Password"
            pwconfTextField.placeholder = "New Password"
            signinButton.setTitle("Update", for: .normal)

            addImage.setTitle("Change Image", for: .normal)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes( [NSAttributedString.Key.font:UIFont(name: "Helvetica-Bold", size: 17)!
            ], for: .normal)
            
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .regular)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.99
            blurView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(blurView, at: 0)
            NSLayoutConstraint.activate([
              blurView.topAnchor.constraint(equalTo: view.topAnchor),
              blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
              blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKey() {
        view.endEditing(true);
    }
    
    @objc func delImage() {
        print("delUser image")
        userPhoto.image = UIImage(named: "userStandard")
        trashImage.alpha = 0
        userUpdatePhoto = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
           return
        }
        let keyboardHeight = view.convert(keyboardFrame.cgRectValue, from: nil).size.height + 10
        bottomImageConstraint.isActive = false
        bottomPasswordConsraint.constant = keyboardHeight //- 170
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
       }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomImageConstraint.isActive = true
        bottomPasswordConsraint.constant = 10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func doneClick() {
        self.dismiss(animated: true)
    }
    
    @IBAction func addUserPhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    
    @IBAction func signInAction(_ sender: Any) {
        
        if pwconfTextField.text == "" && !isModify{
            pwconfTextField.layer.borderColor = UIColor.systemRed.cgColor
            let alert = UIAlertController(title: "Error", message: "You must confirm password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
            return
        }
        
        if pwTextField.text != pwconfTextField.text && !isModify{
            pwTextField.layer.borderColor = UIColor.systemRed.cgColor
            pwconfTextField.layer.borderColor = UIColor.systemRed.cgColor
            let alert = UIAlertController(title: "Error", message: "Password's are not the same", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
            return
        }else {
            
            //Se l'utente non ha aggiunto un'immagine allora ne inserisco una di default
            if !self.userAddPhoto && !isModify{
                userPhoto.image = UIImage(named: "userStandard")
            }

            if isModify {
                if userUpdatePhoto {
                    modifyDelegate?.performModify(self, username: usernameTextField.text ?? "", email: emailTextField.text ?? "", oldPassword: pwTextField.text ?? "", password: pwconfTextField.text ?? "", image: userPhoto.image ?? nil)
                } else {
                    modifyDelegate?.performModify(self, username: usernameTextField.text ?? "", email: emailTextField.text ?? "", oldPassword: pwTextField.text ?? "", password: pwconfTextField.text ?? "", image: nil)
                }
            } else {
                signDelegate?.performSignin(self, username: usernameTextField.text!, email: emailTextField.text!, pw: pwTextField.text!, image: userPhoto.image!)
            }
        }
    }
}

extension SignInViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            //delegate?.updateUserImage(userController: self, row: self.row!, newImage: image)
            userPhoto.image = image
            self.userAddPhoto = true
            self.userUpdatePhoto = true
            self.trashImage.alpha = 1
            self.trashImage.isUserInteractionEnabled = true
            //delegate?.getUserDetail(userController: self, index: self.row!)
        }

        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
}

