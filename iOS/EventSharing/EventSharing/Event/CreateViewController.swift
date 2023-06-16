//
//  CreateViewController.swift
//  EventSharing
//
//  Created by certimeter on 14/04/23.
//

import UIKit

protocol CreateViewControllerDelegate: AnyObject {
    func startCreate() -> CreateViewController
    func saveNewEvent(_ viewController: CreateViewController ,title: String, image: UIImage?, date: String, category: String, description: String, maxPartecipant: String?, externalLink: String)
    func presentLocationSearch(_ viewController: CreateViewController, _ chooseLocationButton: UIButton)
    func updateEvent(_ viewController: CreateViewController ,title: String, image: UIImage?, date: String, category: String, description: String, maxPartecipant: String?, externalLink: String, eventId: Int, oldLatitude: Double, oldLongitude: Double, address: String)
    func setLocationChanged(_ isLocationChanged: Bool)
    func resetInputCreate(_ viewController: CreateViewController)
}

class CreateViewController: UIViewController {
    var isModify: Bool = false
    var event: Event?
    weak var delegate: CreateViewControllerDelegate?
    var categoryPickerView = UIPickerView()
    private lazy var datePickerInput: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        return datePicker
    }()
    @IBOutlet weak var trashImage: UIImageView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: CustomTextField!
    @IBOutlet weak var chooseLocation: UIButton!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var publish: UIButton!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var categoryTextField: CustomTextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet var imageConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkTextField: CustomTextField!
    @IBOutlet weak var maxPartecipantField: CustomTextField!
    @IBOutlet weak var dateField: CustomTextField!
    @IBOutlet var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Event"
        if isModify {
            self.addImageButton.setTitle("Change Image", for: .normal)
            self.publish.setTitle("Update", for: .normal)
        }
        
        eventTitle.delegate = self
        maxPartecipantField.delegate = self
        eventDescription.delegate = self
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryTextField.delegate = self
        linkTextField.delegate = self
        dateField.delegate = self
        
        chooseLocation.layer.cornerRadius = 10
        chooseLocation.titleLabel?.numberOfLines = 4

        addImageButton.titleLabel?.numberOfLines = 2
        addImageButton.layer.cornerRadius = 10
        publish.layer.cornerRadius = 10
        
        datePickerInput.backgroundColor = view.backgroundColor
        categoryPickerView.backgroundColor = view.backgroundColor
        categoryTextField.inputView = categoryPickerView
        
        eventDescription.clipsToBounds = true
        eventDescription.layer.cornerRadius = 10
        eventDescription.layer.borderColor = UIColor.systemBlue.cgColor
        eventDescription.layer.borderWidth = 1
        
        eventImage.layer.cornerRadius = 20
        eventImage.layer.borderColor = UIColor.systemBlue.cgColor
        eventImage.layer.borderWidth = 1
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 25)!
        ]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        view.addGestureRecognizer(tapGesture)
        
        let trashGesture = UITapGestureRecognizer(target: self, action: #selector(delImage))
        trashImage.addGestureRecognizer(trashGesture)
        
        let doneButtonDate = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
        let cancelButtonDate = UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: #selector(datePickerCancel))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: -10, width: view.bounds.size.width, height: 40))
        toolBar.barTintColor = view.backgroundColor
        toolBar.setItems([cancelButtonDate, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButtonDate], animated: true)
        datePickerInput.addTarget(self, action:#selector(handleDatePicker), for: .valueChanged)
        dateField.inputView = datePickerInput
        dateField.inputAccessoryView = toolBar
       
        
        let doneButtonCategory = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.categoryPickerDone))
        let cancelButtonCategory = UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: #selector(categoryPickerCancel))
        let toolBarCategory = UIToolbar.init(frame: CGRect(x: 0, y: -10, width: view.bounds.size.width, height: 40))
        toolBarCategory.barTintColor = categoryPickerView.backgroundColor
        toolBarCategory.setItems([cancelButtonCategory, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButtonCategory], animated: true)
        categoryTextField.inputAccessoryView = toolBarCategory
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isModify {
            guard let event = self.event else {
                return
            }
            delegate?.setLocationChanged(false)
            self.eventTitle.text = event.title
            self.categoryTextField.text = event.tag
            descriptionPlaceholder.alpha = 0
            self.eventDescription.text = event.description
            self.maxPartecipantField.text = event.max_partecipnt?.description
            self.linkTextField.text = event.externalLink
            self.dateField.text = event.date
            let check = event.image?.isEmpty ?? true
            if !check {
                UIView.animate(withDuration: 0.1) {
                    self.imageConstraint.isActive = false
                    self.trashImage.alpha = 1
                    self.trashImage.isUserInteractionEnabled = true
                    self.eventImage.image = UIImage(data: event.image ?? Data())
                    self.view.layoutIfNeeded()
                }
            }
            self.chooseLocation.setTitle(event.address, for: .normal)
            self.chooseLocation.setImage(UIImage(systemName: "location.fill"), for: .normal)
        } else {
            delegate?.resetInputCreate(self)
        }
    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func delImage() {
        self.trashImage.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.eventImage.image = UIImage()
            self.imageConstraint.isActive = true
            self.trashImage.isUserInteractionEnabled = false
        }
        
    }
    
    @objc func categoryPickerDone() {
        if categoryTextField.text == "" || categoryTextField.text == nil {
            categoryPickerView.delegate?.pickerView?(categoryPickerView, didSelectRow: 0, inComponent: 0)
        }
        view.endEditing(true)
    }
    
    @objc func datePickerDone() {
        if dateField.text == "" || dateField.text == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateField.text = dateFormatter.string(from: Date())
        }
        view.endEditing(true)
    }
    
    @objc func datePickerCancel() {
        dateField.text = ""
        view.endEditing(true)
    }
 
    @objc func categoryPickerCancel() {
        categoryTextField.text = ""
        view.endEditing(true)
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
           return
        }
        let screen = UIScreen.main
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        
        let fromCoordinateSpace = screen.coordinateSpace
        let toCoordinateSpace: UICoordinateSpace = view
        let convertedKeyboardFrame = fromCoordinateSpace.convert(keyboardFrame, from: toCoordinateSpace)
        let keyboardHeight = convertedKeyboardFrame.size.height
        let bottomOffset = view.safeAreaInsets.bottom
        bottomButtonConstraint.constant = keyboardHeight - bottomOffset + 10
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomButtonConstraint.constant = 10
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func chooseLocationView(_ sender: Any) {
        view.endEditing(true)
        delegate?.presentLocationSearch(self, chooseLocation)
    }
    
    @IBAction func addImage(_ sender: Any) {
        UIView.animate(withDuration: 0.1) {
            self.imageConstraint.isActive = false
            self.trashImage.alpha = 1
            self.trashImage.isUserInteractionEnabled = true
            self.view.layoutIfNeeded()
        }
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    @IBAction func publishEvent(_ sender: Any) {
        trashImage.alpha = 0
        trashImage.isUserInteractionEnabled = false
        if isModify {
            guard let event = self.event else {return}
            delegate?.updateEvent(self, title: eventTitle.text ?? "", image: eventImage.image, date: dateField.text ?? "", category: categoryTextField.text ?? "", description: eventDescription.text ?? "", maxPartecipant: maxPartecipantField?.text ?? "", externalLink: linkTextField.text ?? "", eventId: event.id, oldLatitude: event.latitude, oldLongitude: event.longitude, address: event.address)
        } else {
            delegate?.saveNewEvent(self, title: eventTitle.text ?? "", image: eventImage.image, date: dateField.text ?? "", category: categoryTextField.text ?? "", description: eventDescription.text ?? "", maxPartecipant: maxPartecipantField?.text ?? "", externalLink: linkTextField.text ?? "")
        }
        view.endEditing(true)
    }
}

extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            eventImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if eventImage.image == UIImage() {
            UIView.animate(withDuration: 0.3) {
                self.imageConstraint.isActive = true
                self.trashImage.isUserInteractionEnabled = false
                self.trashImage.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

extension CreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = Category.allCases[row].rawValue
    }
}

extension CreateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.descriptionPlaceholder.alpha = 0
        eventDescription.layer.borderColor = UIColor.systemBlue.cgColor
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.descriptionPlaceholder.alpha = 1
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if(text == "\n") {
               textView.resignFirstResponder()
               return false
           }
           return true
       }
}

extension CreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 7 {
            return false
        } else {
            return true
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
