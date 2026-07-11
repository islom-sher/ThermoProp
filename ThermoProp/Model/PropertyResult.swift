//
//  PropertyResult.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/8/26.
//

import Foundation

enum FluidPhaseState {
    case subcooledLiquied
    case superheatedVapor
    case twoPhaseSaturated
    case supercritical
    case calculationError(message: String)
    
    var displayName: String {
        switch self {
        case .subcooledLiquied: return "Subcooled Liquid"
        case .superheatedVapor: return "Superheated Vapor"
        case .twoPhaseSaturated: return "Two-Phase Saturated"
        case .supercritical: return "Supercritical"
        case .calculationError(let msg): return "Error: \(msg)"
        }
    }
}

struct PropertyResult {
    let title: String
    let valueType: ValueType
    let unit: String
    let symbolText: String
    let isHighlighted: Bool
    
    enum ValueType {
        case single(value: String)
        case saturationRange(liquidValue: String, vaporValue: String)
        case undetermined(message: String)
    }
    
    var displayValueString: String {
        switch valueType {
        case .single(let value):
            return value
        case .saturationRange(let liquidValue, let vaporValue):
            return "\(liquidValue) → \(vaporValue)"
        case .undetermined(let message):
            return message
        }
    }
}

struct ThermodynamicStateResponse {
    let phaseState: FluidPhaseState
    let properties: [PropertyResult]
    let dependentParameterText: String?
}

struct ThermodynamicTableRow {
    let iterationStepValue: String
    let phaseState: FluidPhaseState
    let properties: [PropertyResult]
}

struct ThermodynamicTableResponse {
    let fixedParameterText: String?
    let iteratedParameterName: String
    let rows: [ThermodynamicTableRow]
}




