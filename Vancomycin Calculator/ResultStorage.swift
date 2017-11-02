//
//  ResultStorage.swift
//  Vancomycin Calculator
//
//  Created by Neha Thakore on 5/29/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation

protocol ResultStorage {
    func storeResult(result: Result)
    func readResults(completionHandler: (([Result]) -> Void)?)
    func deleteResult(result: Result)
}

