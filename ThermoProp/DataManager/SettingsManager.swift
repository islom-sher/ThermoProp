//
//  SettingsManager.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/15/26.
//

import UIKit

enum ReferenceState: String, CaseIterable {
    case ashrae = "ASHRAE"
    case iir = "IIR"
    case nbp = "NBP"
    case def = "DEF"
}

enum AppAppearance: String, CaseIterable {
    case system = "System"
    case dark = "Dark"
    case light = "Light"
}

enum DecimalPlaces: String, CaseIterable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
}

enum TemperatureUnit: String, CaseIterable {
    case kelvin = "K"
    case celsius = "°C"
    case fahrenheit = "°F"
    
    // Converting from user's preferred unit to system/coolprop input unit
    func toBaseSI(value: Double) -> Double {
        switch self {
        case .kelvin:
            return value
        case .celsius:
            return value + 273.15
        case .fahrenheit:
            return (value + 459.67) * 5.0 / 9.0
        }
    }
    
    // Converting from system/coolprop output unit to user's preferred unit
    func fromBaseSI(kelvin: Double) -> Double {
        switch self {
        case .kelvin:
            return kelvin
        case .celsius:
            return kelvin - 273.15
        case .fahrenheit:
            return kelvin * (9.0 / 5.0) - 459.67
        }
    }
}

enum PressureUnit: String, CaseIterable {
    case pascal = "Pa"
    case kilopascal = "kPa"
    case megapascal = "MPa"
    case bar = "bar"
    case atm = "atm"
    case mmHg = "mmHg"
    case psi = "psi"
    
    func toBaseSI(value: Double) -> Double {
        switch self {
        case .pascal:
            return value
        case .kilopascal:
            return value * 1_000.0
        case .megapascal:
            return value * 1_000_000.0
        case .bar:
            return value * 100_000.0
        case .atm:
            return value * 101_325.0
        case .mmHg:
            return value * 133.322
        case .psi:
            return value * 6894.76
        }
    }
    
    func fromBaseSI(pascal: Double) -> Double {
        switch self {
        case .pascal:
            return pascal
        case .kilopascal:
            return pascal / 1_000.0
        case .megapascal:
            return pascal / 1_000_000.0
        case .bar:
            return pascal / 100_000.0
        case .atm:
            return pascal / 101325.0
        case .mmHg:
            return pascal / 133.322
        case .psi:
            return pascal / 6894.76
        }
    }
}

enum DensityUnit: String, CaseIterable {
    case kg_per_CubicMeter = "kg/m³"
    case lb_per_CubicFt = "lb/ft³"
    case lb_per_Gallon = "lb/gal"
    
    func toBaseSI(value: Double) -> Double {
        switch self {
        case .kg_per_CubicMeter:
            return value
        case .lb_per_CubicFt:
            return value * 16.018463
        case .lb_per_Gallon:
            return value * 119.826
        }
    }
    
    func fromBaseSI(kg_per_CubicMeter: Double) -> Double {
        switch self {
        case .kg_per_CubicMeter:
            return kg_per_CubicMeter
        case .lb_per_CubicFt:
            return kg_per_CubicMeter / 16.018463
        case .lb_per_Gallon:
            return kg_per_CubicMeter / 119.826
        }
    }
}

enum EnthalpyUnit: String, CaseIterable {
    case kiloJoul_per_Kg = "kJ/kg"
    case joul_per_Kg = "J/kg"
    case btu_per_Lb = "Btu/Lb"
    
    func toBaseSI(value: Double) -> Double {
        switch self {
        case .kiloJoul_per_Kg:
            return value * 1000.0
        case .joul_per_Kg:
            return value
        case .btu_per_Lb:
            return value * 2326
        }
    }
    
    func fromBaseSI(joul_per_Kg: Double) -> Double {
        switch self {
        case .kiloJoul_per_Kg:
            return joul_per_Kg / 1000.0
        case .joul_per_Kg:
            return joul_per_Kg
        case .btu_per_Lb:
            return joul_per_Kg / 2326
        }
    }
}

enum EntropyUnit: String, CaseIterable {
    case kiloJoul_per_KgKelvin = "kJ/kg·K"
    case joul_per_KgKelvin = "J/kg·K"
    case btu_per_LbFaranheit = "Btu/lb·°F"
    
    func toBaseSI(value: Double) -> Double {
        switch self {
        case .kiloJoul_per_KgKelvin:
            return value * 1000.0
        case .joul_per_KgKelvin:
            return value
        case .btu_per_LbFaranheit:
            return value * 4186.8
        }
    }
    
    func fromBaseSI(joul_per_KgKelvin: Double) -> Double {
        switch self {
        case .kiloJoul_per_KgKelvin:
            return joul_per_KgKelvin / 1000.0
        case .joul_per_KgKelvin:
            return joul_per_KgKelvin
        case .btu_per_LbFaranheit:
            return joul_per_KgKelvin / 4186.8
        }
    }
}

extension Notification.Name {
    static let unitsDidUpdate = Notification.Name("unitsDidUpdateNotification")
}

class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    private init() { }
    
    //MARK: - Properties
    
    var temperature: TemperatureUnit {
        get {
            let savedValue = defaults.string(forKey: "tempUnit") ?? TemperatureUnit.kelvin.rawValue
            return TemperatureUnit(rawValue: savedValue) ?? .kelvin
        }
        set {
            defaults.set(newValue.rawValue, forKey: "tempUnit")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var pressure: PressureUnit {
        get {
            let savedValue = defaults.string(forKey: "pressUnit") ?? PressureUnit.megapascal.rawValue
            return PressureUnit(rawValue: savedValue) ?? .megapascal
        }
        set {
            defaults.set(newValue.rawValue, forKey: "pressUnit")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var density: DensityUnit {
        get {
            let savedValue = defaults.string(forKey: "densityUnit") ?? DensityUnit.kg_per_CubicMeter.rawValue
            return DensityUnit(rawValue: savedValue) ?? .kg_per_CubicMeter
        }
        set {
            defaults.set(newValue.rawValue, forKey: "densityUnit")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var enthalpy: EnthalpyUnit {
        get {
            let savedValue = defaults.string(forKey: "enthalpyUnit") ?? EnthalpyUnit.kiloJoul_per_Kg.rawValue
            return EnthalpyUnit(rawValue: savedValue) ?? .kiloJoul_per_Kg
        }
        set {
            defaults.set(newValue.rawValue, forKey: "enthalpyUnit")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var entropy: EntropyUnit {
        get {
            let savedValue = defaults.string(forKey: "entropyUnit") ?? EntropyUnit.kiloJoul_per_KgKelvin.rawValue
            return EntropyUnit(rawValue: savedValue) ?? .kiloJoul_per_KgKelvin
        }
        set {
            defaults.set(newValue.rawValue, forKey: "entropyUnit")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var referenceState: ReferenceState {
        get {
            let savedValue = defaults.string(forKey: "refState") ?? ReferenceState.ashrae.rawValue
            return ReferenceState(rawValue: savedValue) ?? .ashrae
        }
        set {
            defaults.set(newValue.rawValue, forKey: "refState")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var appearance: AppAppearance {
        get {
            let savedValue = defaults.string(forKey: "appearanceSetting") ?? AppAppearance.system.rawValue
            return AppAppearance(rawValue: savedValue) ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: "appearanceSetting")
            applyTheme(newValue) // Instantly update the UI!
        }
    }
    
    var decimals: DecimalPlaces {
        get {
            let savedValue = defaults.string(forKey: "decimalSetting") ?? DecimalPlaces.four.rawValue
            return DecimalPlaces(rawValue: savedValue) ?? .four
        }
        set {
            defaults.set(newValue.rawValue, forKey: "decimalSetting")
            NotificationCenter.default.post(name: .unitsDidUpdate, object: nil)
        }
    }
    
    var autoSaveEnabled: Bool {
        get {
            return defaults.bool(forKey: "autoSaveEnabled")
        }
        set {
            defaults.set(newValue, forKey: "autoSaveEnabled")
        }
    }
    
    func applyTheme(_ theme: AppAppearance) {
        let style: UIUserInterfaceStyle
        switch theme {
        case .system: style = .unspecified
        case .light: style = .light
        case .dark: style = .dark
        }
        
        DispatchQueue.main.async {
            // This grabs the active window and forces the new style instantly
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
    }
}
