//
//  PatientResultStorage.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore on 11/2/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import FMDB

class PatientResultStorage: ResultStorage {
    
    static let sharedInstance = PatientResultStorage()
    
    fileprivate var database: FMDatabase?
    
    init() {
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("patients.sqlite") {
            
            database = FMDatabase(path: fileURL.path)
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                createTable()
            }
        }
    }
    
    fileprivate func createTable() {
        guard let db = database, db.open() else {
            return
        }
        
        do {
            try db.executeUpdate("create table patients(patientInitials text, idealBodyWeight double, bodyMassIndex double, basalMetabolicRate double, bodySurfaceArea double, uniqueIdentifier text)", values: nil)
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        db.close()
    }
    
    func storeResult(result: Result) {
        guard let db = database, db.open() else {
            return
        }
        
        do {
            try db.executeUpdate("insert into patients(patientInitials, idealBodyWeight, bodyMassIndex, basalMetabolicRate, bodySurfaceArea, uniqueIdentifier) values(?, ?, ?, ?, ?, ?)", values: [result.patientInitials, result.idealBodyWeight, result.bodyMassIndex, result.basalMetabolicRate, result.bodySurfaceArea, result.uniqueIdentifier])
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        db.close()
        
    }
    
    func readResults(completionHandler: (([Result]) -> Void)?) {
        guard let db = database, db.open() else {
            return
        }
        var results = [Result]()
        do {
            let result = try db.executeQuery("select * from patients", values: nil)
            while result.next() {
                if let initials = result.string(forColumn: "patientInitials"), let uniqueIdentifier = result.string(forColumn: "uniqueIdentifier") {
                    let patientResult = Result(patientInitials: initials, idealBodyWeight: result.double(forColumn: "idealBodyWeight"), bodyMassIndex: result.double(forColumn: "bodyMassIndex"), basalMetabolicRate: result.double(forColumn: "basalMetabolicRate"), bodySurfaceArea: result.double(forColumn: "bodySurfaceArea"), uniqueIdentifier: uniqueIdentifier)
                    results.append(patientResult)
                }
            }
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        completionHandler?(results)
    }
    
    func deleteResult(result: Result) {
        guard let db = database, db.open() else {
            return
        }
        
        do {
            try db.executeUpdate("delete from patients where uniqueIdentifier = ?", values: [result.uniqueIdentifier])
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
    }
}
