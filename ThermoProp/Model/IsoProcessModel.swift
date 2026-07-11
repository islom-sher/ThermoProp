//
//  IsoProcessModel.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import Foundation

enum IsoProcessModel: Int, CaseIterable {
    case pressure = 0, temperature, density, enthalpy, entropy
    
    var symbol: String {
        switch self {
        case .pressure: return "P"
        case .temperature: return "T"
        case .density: return "ρ"
        case .enthalpy: return "H"
        case .entropy: return "S"
        }
    }
    
    var name: String {
        switch self {
        case .pressure: return "Pressure"
        case .temperature: return "Tempearture"
        case .density: return "Density"
        case .enthalpy: return "Enthalpy"
        case .entropy: return "Entropy"
        }
    }
}
