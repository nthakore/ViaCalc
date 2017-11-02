//
//  Double+Extensions.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore on 5/4/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation

extension Double {
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
