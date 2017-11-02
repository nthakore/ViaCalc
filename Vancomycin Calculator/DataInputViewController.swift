//
//  ViewController.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore on 4/12/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import TKSubmitTransition

class DataInputViewController: UIViewController {
    @IBOutlet weak var patientInitials: SkyFloatingLabelTextField! {
        didSet {
            patientInitials.placeholder = "Initials"
            patientInitials.title = "Patient's initials"
        }
    }
    @IBOutlet weak var weightField: SkyFloatingLabelTextField! {
        didSet {
            weightField.placeholder = "Weight in pounds"
            weightField.title = "Patient's weight"
        }
    }
    @IBOutlet weak var heightField: SkyFloatingLabelTextField! {
        didSet {
            heightField.placeholder = "Height in inches"
            heightField.title = "Patient's height"
        }
    }
    @IBOutlet weak var ageField: SkyFloatingLabelTextField! {
        didSet {
            ageField.placeholder = "Age in years"
            ageField.title = "Patient's age"
        }
    }
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var calculateButton: TKTransitionSubmitButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateButton.layer.cornerRadius = 0.0
    }

    
    @IBAction func calculateButtonTouched(_ sender: Any) {
        if let patientInitialsText = patientInitials.text,
            let weightText = weightField.text,
            let heightText = heightField.text,
            let ageText = ageField.text,
            let weightDouble = Double(weightText),
            let heightDouble = Double(heightText),
            let ageInt = Int(ageText),
            maleButton.isSelected || femaleButton.isSelected {
            calculateButton.startLoadingAnimation()
            
            let newPatient = Patient(patientInitials: patientInitialsText, weight: weightDouble, height: heightDouble, age: ageInt, isMaleGender: maleButton.isSelected)
            let vancDosage = VancomycinDosage()
            let newResult = vancDosage.calculateResultForPatient(patient: newPatient)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let resultsController = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultsViewController {
                resultsController.myResult = newResult
                resultsController.showCloseButton = true
                resultsController.showSaveButton = true
                calculateButton.startFinishAnimation(1.0, completion: {
                    resultsController.transitioningDelegate = self
                    self.present(resultsController, animated: true, completion: nil)
                })
            }
        } else {
            let alert =  UIAlertController(title: "Incomplete Information", message: "Please ensure all information is complete and correct", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func femaleButtonTapped(_ sender: Any) {
        toggleButtonSelection(buttonTapped: femaleButton)
    }
    
    @IBAction func maleButtonTapped(_ sender: Any) {
        toggleButtonSelection(buttonTapped: maleButton)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        patientInitials?.text = nil
        weightField?.text = nil
        heightField?.text = nil
        ageField?.text = nil
        femaleButton.isSelected = false
        maleButton.isSelected = false
    }
    
    fileprivate func toggleButtonSelection(buttonTapped: UIButton) {
        if !buttonTapped.isSelected {
            buttonTapped.isSelected = true
            if buttonTapped == maleButton {
               femaleButton.isSelected = false
            } else {
                maleButton.isSelected = false
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if var keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                
                var contentInset = self.scrollView.contentInset
                contentInset.bottom = keyboardFrame.size.height
                scrollView.contentInset = contentInset
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

extension DataInputViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 1.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

