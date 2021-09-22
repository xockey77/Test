//
//  Persistance.swift
//  currencyXML
//
//  Created by username on 21.09.2021.
//

import Foundation

class Persistance {
    static let shared = Persistance()
    
    private let kThresholdKey  = "Persistance.kThresholdKey"
    
    var threshold: Double? {
        set { UserDefaults.standard.set(newValue, forKey: kThresholdKey) }
        get { return UserDefaults.standard.double(forKey: kThresholdKey)}
    }
    
}
