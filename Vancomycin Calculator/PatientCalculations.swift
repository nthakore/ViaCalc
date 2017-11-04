//
//  PatientCalculations.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore on 11/4/17.
//  Copyright © 2017 Neha Thakore. All rights reserved.
//

import UIKit

struct PatientCalculations {
    
    fileprivate let baseForIdealBodyWeightMale = Double(106)
    fileprivate let baseForIdealBodyWeightFemale = Double(100)
    fileprivate let idealBodyWeightHeightOffset = Double(60)
    fileprivate let maleWeightOffset = Double(6)
    fileprivate let femaleWeightOffset = Double(5)
    fileprivate let bodyMassIndexMultiplier = Double(703)
    fileprivate let basalMetabolicRateBaseMale = Double(66)
    fileprivate let basalMetabolicRateBaseFemale = Double(655)
    fileprivate let basalMetabolicRateWeightOffsetMale = Double(6.23)
    fileprivate let basalMetabolicRateWeightOffsetFemale = Double(4.35)
    fileprivate let basalMetabolicRateHeightOffsetMale = Double(12.7)
    fileprivate let basalMetabolicRateHeightOffsetFemale = Double(4.7)
    fileprivate let basalMetabolicRateAgeOffsetMale = Double(6.8)
    fileprivate let basalMetabolicRateAgeOffsetFemale = Double(4.7)
    fileprivate let bodySurfaceAreaOffset = Double(3131)

    fileprivate func calculateIdealBodyWeightFor(patient: Patient) -> Double {
        if patient.isMaleGender == true {
            return baseForIdealBodyWeightMale + ((patient.height - idealBodyWeightHeightOffset) * maleWeightOffset)
        } else {
            return baseForIdealBodyWeightFemale + ((patient.height - idealBodyWeightHeightOffset) * femaleWeightOffset)
        }
    }
    
    fileprivate func calculateBodyMassIndexFor(patient: Patient) -> Double {
        return (patient.weight / (patient.height * patient.height)) * bodyMassIndexMultiplier
    }
    
    fileprivate func calculateBasalMetabolicRateFor(patient: Patient) -> Double {
        if patient.isMaleGender == true {
            return basalMetabolicRateBaseMale + (basalMetabolicRateWeightOffsetMale * patient.weight) + (basalMetabolicRateHeightOffsetMale * patient.height) - (basalMetabolicRateAgeOffsetMale * patient.age)
        } else {
            return basalMetabolicRateBaseFemale + (basalMetabolicRateWeightOffsetFemale * patient.weight) + (basalMetabolicRateHeightOffsetFemale * patient.height) - (basalMetabolicRateAgeOffsetFemale * patient.age)
        }
    }
    
    fileprivate func calculateBodySurfaceAreaFor(patient: Patient) -> Double {
        return sqrt((patient.height * patient.weight) / bodySurfaceAreaOffset)
    }
    
    public func calculateResultForPatient(patient: Patient) -> Result {
        let patientInitials = patient.patientInitials
        let idealBodyWeight = calculateIdealBodyWeightFor(patient: patient)
        let bodyMassIndex = calculateBodyMassIndexFor(patient: patient)
        let basalMetabolicRate = calculateBasalMetabolicRateFor(patient: patient)
        let bodySurfaceArea = calculateBodySurfaceAreaFor(patient: patient)
        return Result(patientInitials: patientInitials, idealBodyWeight: idealBodyWeight, bodyMassIndex: bodyMassIndex, basalMetabolicRate: basalMetabolicRate, bodySurfaceArea: bodySurfaceArea, uniqueIdentifier: UUID().uuidString)
    }
}
