//
//  FluidCharacteristics.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/12/26.
//

import Foundation

struct FluidItem {
    let name: String
    let subtitle: String
    let iconName: String
    var isSelected: Bool
    
    static func == (lhs: FluidItem, rhs: FluidItem) -> Bool {
        return lhs.name == rhs.name
    }
}

struct FluidSection {
    let title: String
    var fluids: [FluidItem]
}

struct FluidMetadata {
    let formula: String
    let cas: String
    let safetyClass: String
}

struct CharacteristicItem {
    let title: String
    let value: String
    let unit: String
}

struct FluidCharacteristics {
    let name: String
    let molarMass: Double
    let acentricFactor: Double
    let criticalTemp: Double
    let criticalPress: Double
    let tripleTemp: Double
    let triplePress: Double
    let gwp: Int
    let odp: Double
    
    var molarMassString: String { String(format: "%.3f", molarMass) }
    var criticalTempString: String { String(format: "%.2f", criticalTemp) }
    var criticalPressString: String { String(format: "%.2f", criticalPress) }
    var acentricFactorString: String { String(format: "%.3f", acentricFactor) }
    var tripleTempString: String { String(format: "%.2f", tripleTemp) }
    var triplePressString: String { String(format: "%.4f", triplePress) }
    
    var gwpString: String { gwp == 0 ? "0 (Natural)" : (String(describing: gwp)) }
    var odpString: String { odp == 0.0 ? "0 (Safe)" : (String(describing: odp)) }
    
    func toDisplayItems() -> [CharacteristicItem] {
        let tempSetting = SettingsManager.shared.temperature
        let pressSetting = SettingsManager.shared.pressure
        
        let decimalCount = SettingsManager.shared.decimals.rawValue
        let formatStr = "%.\(decimalCount)f"
        
        let convertedT = tempSetting.fromBaseSI(kelvin: self.criticalTemp)
        let convertedP = pressSetting.fromBaseSI(pascal: self.criticalPress)
        
        let convertedTT = tempSetting.fromBaseSI(kelvin: self.tripleTemp)
        let convertedTP = pressSetting.fromBaseSI(pascal: self.triplePress)
        
        let formattedMass = String(format: formatStr, self.molarMass)
        let formattedT = String(format: formatStr, convertedT)
        let formattedP = String(format: formatStr, convertedP)
        let formattedTT = String(format: formatStr, convertedTT)
        let formattedTP = String(format: formatStr, convertedTP)
        let formattedAcentric = String(format: formatStr, self.acentricFactor)
        
        return [
            CharacteristicItem(title: "Molar weight", value: formattedMass, unit: "g/mol"),
            CharacteristicItem(title: "Critical T", value: formattedT, unit: tempSetting.rawValue),
            CharacteristicItem(title: "Critical P", value: formattedP, unit: pressSetting.rawValue),
            CharacteristicItem(title: "Triple T", value: formattedTT, unit: tempSetting.rawValue),
            CharacteristicItem(title: "Triple P", value: formattedTP, unit: pressSetting.rawValue),
            CharacteristicItem(title: "Acentric ω", value: formattedAcentric, unit: ""),
            CharacteristicItem(title: "GWP100", value: gwpString, unit: ""),
            CharacteristicItem(title: "ODP", value: odpString, unit: "")
        ]
    }
}
