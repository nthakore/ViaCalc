//
//  SavedPatientsViewController.swift
//  Vancomycin Calculator
//
//  Created by Dahle III, Donald E. on 6/17/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SavedPatientsViewController: UIViewController {
    @IBOutlet weak var savedPatientsTableView: UITableView!
    
    fileprivate var resultsForTableView = [Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedPatientsTableView.dataSource = self
        savedPatientsTableView.delegate = self
        savedPatientsTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PatientResultStorage.sharedInstance.readResults { [weak self] (fetchedResults) in
            self?.resultsForTableView = fetchedResults
            
            self?.savedPatientsTableView.reloadData()
        }
    }
}

extension SavedPatientsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultsController = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultsViewController {
            resultsController.myResult = resultsForTableView[indexPath.row]
            
            navigationController?.pushViewController(resultsController, animated: true)
        }
    }
}

extension SavedPatientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPatientsTableViewCell", for: indexPath) as? SavedPatientsTableViewCell else {
            return UITableViewCell()
        }
                
        let result = resultsForTableView[indexPath.row]
        cell.patientIdentifierLabel.text = result.patientInitials
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, success) in
            PatientResultStorage.sharedInstance.deleteResult(result: self.resultsForTableView[indexPath.row])
            
            self.resultsForTableView.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
            success(true)
        }
        modifyAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
