//
//  ThermodynamicUnitsModel.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/11/26.
//

import Foundation

enum ThermoParameter {
    case temperature(celsius: Double)
    case pressure(bar: Double)
    case density(kgm3: Double)
    case enthalpy(kJkg: Double)
    case entropy(kJkgK: Double)
    case vaporQuality(fraction: Double)
    
    var coolPropKey: String {
        switch self {
        case .temperature: return "T"
        case .pressure:    return "P"
        case .density:     return "D"
        case .enthalpy:    return "H"
        case .entropy:     return "S"
        case .vaporQuality: return "Q"
        }
    }
    
    var SIValue: Double {
        switch self {
        case .temperature(let c): return c + 273.15   // °C to Kelvin
        case .pressure(let b):    return b * 100000.0  // bar to Pa
        case .density(let d):     return d            // kg/m³
        case .enthalpy(let h):    return h * 1000.0   // kJ/kg to J/kg
        case .entropy(let s):     return s * 1000.0   // kJ/kg·K to J/kg·K
        case .vaporQuality(let q): return q
        }
    }
}
