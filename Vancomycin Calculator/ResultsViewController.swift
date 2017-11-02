//
//  ResultsViewController.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore, PharmD/PhD on 4/19/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    @IBOutlet weak var patientInitialsField: UILabel!
    @IBOutlet weak var loadingDoseField: UILabel!
    @IBOutlet weak var crclField: UILabel!
    @IBOutlet weak var highDoseAndIntervalField: UILabel!
    @IBOutlet weak var traditionalDoseAndIntervalField: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var myResult: Result!
    var showCloseButton = false
    var showSaveButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.isHidden = !showCloseButton
        saveButton.isHidden = !showSaveButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let crclString = String(describing: Int(myResult.crcl))
        let loadingDoseString = String(describing: Int(myResult.loadingDose))
        
        patientInitialsField.text = "PATIENT: \(myResult.patientInitials)"
        crclField.text = "\(crclString) ML/MIN"
        loadingDoseField.text = "\(loadingDoseString) MG"
        traditionalDoseAndIntervalField.text = "\(myResult.traditionalDosingAmount) \(myResult.traditionalDosingInterval)"
        highDoseAndIntervalField.text = "\(myResult.highDosingAmount) \(myResult.highDosingInterval)"
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        PatientResultStorage.sharedInstance.storeResult(result: myResult)
        
        let alert =  UIAlertController(title: nil, message: "Patient information has been saved!", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
