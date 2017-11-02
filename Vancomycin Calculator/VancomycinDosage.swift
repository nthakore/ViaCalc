//
//  VancomycinDosage.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore, PharmD/PhD on 4/19/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

struct VancomycinDosage {
    fileprivate let idealBodyWeightHeightMultiplier = 0.9
    fileprivate let idealBodyWeightMaleOffset = Double(88)
    fileprivate let idealBodyWeightFemaleOffset = Double(92)
    fileprivate let adjustedBodyWeightMultiplier = 0.4
    fileprivate let checkBodyWeightMultiplier = 1.2
    fileprivate let ageOffset = 140
    fileprivate let scrMultiplier = Double(72)
    fileprivate let crclMultiplier = 0.85
    fileprivate let loadingDoseMultiplier = Double(25)
    fileprivate let loadingDoseCutOff = Double(2000)
    
    fileprivate func calculateIdealBodyWeightFor(patient: Patient) -> Double {
        let offset = patient.isMaleGender ? idealBodyWeightMaleOffset : idealBodyWeightFemaleOffset
        return idealBodyWeightHeightMultiplier * patient.height - offset
    }
    
    fileprivate func calculateAdjustedBodyWeightFor(patient: Patient) -> Double {
        let idealBodyWeight = calculateIdealBodyWeightFor(patient: patient)
        return idealBodyWeight + adjustedBodyWeightMultiplier * (patient.weight - idealBodyWeight)
    }
    
    public func calculateCrClFor(patient: Patient) -> Double {
        let idealBodyWeight = calculateIdealBodyWeightFor(patient: patient)
        let adjustedBodyWeight = calculateAdjustedBodyWeightFor(patient: patient)
        var crcl = Double(0)
        var weightToUse = Double(0)
        
        if patient.weight < (checkBodyWeightMultiplier * idealBodyWeight) {
            if patient.weight < idealBodyWeight {
                weightToUse = patient.weight
            } else {
                weightToUse = idealBodyWeight
            }
        } else {
            weightToUse = adjustedBodyWeight
        }
        
        crcl = (Double(ageOffset - patient.age) * weightToUse) / (scrMultiplier * patient.sCr)
        return patient.isMaleGender ? crcl : crcl * crclMultiplier
    }
    
    fileprivate func assignIntervalForTraditionalDosing(patient: Patient) -> String {
        let crcl = calculateCrClFor(patient: patient)
        let crclInt = Int(crcl)
        
        if crclInt >= 30 {
            if crclInt > 65 {
                return patient.age <= 75 ? "Q 12H" : "Q 24H"
            } else {
                return "Q 24H"
            }
        } else {
            return "Pulse dosing based on trough levels"
        }
    }
    
    fileprivate func assignIntervalForHighDosing(patient: Patient) -> String {
        let crcl = calculateCrClFor(patient: patient)
        
        switch Int(crcl) {
        case let x where x > 100:
            if patient.age > 65 && patient.age <= 75 {
                return "Q 12H"
            } else if patient.age > 75 {
                return "Q 24H"
            } else {
                return "Q 8H"
            }
        case 66...100:
            return patient.age <= 75 ? "Q 12H" : "Q 24H"
        case 30...65:
            return "Q 24H"
        default:
            return "Pulse dosing based on trough levels"
        }
    }
    
    fileprivate func assignDoseForTraditionalDosing(patient: Patient) -> String {
        let idealBodyWeight = calculateIdealBodyWeightFor(patient: patient)
        let adjustedBodyWeight = calculateAdjustedBodyWeightFor(patient: patient)
        var weightToUse = Double(0)
        
        if patient.weight >= (checkBodyWeightMultiplier * idealBodyWeight) {
            weightToUse = adjustedBodyWeight
        } else {
            weightToUse = patient.weight
        }
        
        switch Int(weightToUse) {
        case let x where x > 100:
            return "1250 MG"
        case 55...100:
            return "1000 MG"
        case 45...54:
            return "750 MG"
        default:
            return "Use clinical judgement in underweight patients"
        }
    }
    
    fileprivate func assignDoseForHighDosing(patient: Patient) -> String {
        let idealBodyWeight = calculateIdealBodyWeightFor(patient: patient)
        let adjustedBodyWeight = calculateAdjustedBodyWeightFor(patient: patient)
        var weightToUse = Double(0)
        
        if patient.weight >= (checkBodyWeightMultiplier * idealBodyWeight) {
            weightToUse = adjustedBodyWeight
        } else {
            weightToUse = patient.weight
        }
        
        switch Int(weightToUse) {
        case let x where x > 100:
            return "1500 MG"
        case 76...100:
            return "1250 MG"
        case 55...75:
            return "1000 MG"
        case 45...54:
            return "750 MG"
        default:
            return "Use clinical judgement in underweight patients"
        }
    }
    
    fileprivate func calculateLoadingDose(patient: Patient) -> Double {
        let loadingDose = patient.weight * loadingDoseMultiplier
        return loadingDose < loadingDoseCutOff ? loadingDose.round(nearest: 250) : loadingDoseCutOff
    }
    
    public func calculateResultForPatient(patient: Patient) -> Result {
        let patientInitials = patient.patientInitials
        var crcl = calculateCrClFor(patient: patient)
        var loadingDose = calculateLoadingDose(patient: patient)
        var traditionalDosingAmount = ""
        var traditionalDosingInterval = ""
        var highDosingAmount = ""
        var highDosingInterval = ""
        
        switch patient.status {
        case .underweight:
            traditionalDosingAmount = assignDoseForTraditionalDosing(patient: patient)
            highDosingAmount = assignDoseForHighDosing(patient: patient)
        case .poorClearance:
            traditionalDosingInterval = assignIntervalForTraditionalDosing(patient: patient)
            highDosingInterval = assignIntervalForHighDosing(patient: patient)
        case .underweightAndPoorClearance:
            traditionalDosingAmount = "Patient is underweight with poor clearance: use clinical judgement"
            highDosingInterval = "Patient is underweight with poor clearance: use clinical judgement"
        case .normal:
            traditionalDosingAmount = assignDoseForTraditionalDosing(patient: patient)
            traditionalDosingInterval = assignIntervalForTraditionalDosing(patient: patient)
            highDosingAmount = assignDoseForHighDosing(patient: patient)
            highDosingInterval = assignIntervalForHighDosing(patient: patient)
        }
        return Result(patientInitials: patientInitials, crcl: crcl, loadingDose: loadingDose, traditionalDosingAmount: traditionalDosingAmount, traditionalDosingInterval: traditionalDosingInterval, highDosingAmount: highDosingAmount, highDosingInterval: highDosingInterval, uniqueIdentifier: UUID().uuidString)
    }
}












