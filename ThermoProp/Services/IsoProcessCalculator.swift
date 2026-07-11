//
//  IsoProcessCalculator.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/11/26.
//

import Foundation

/*
 The calculator is intented to calculate the properties of the fluid by fixing one parameter and changing the second one arbitrarly
 */
struct IsoProcessCalculator {
    
    static func generateIsoTableAsync(
        fluidName: String,
        fixedParam: IsoProcessModel,
        fixedValue: Double,
        iteratedParam: IsoProcessModel,
        startValue: Double,
        endValue: Double,
        stepValue: Double,
        completion: @escaping (_ coreHeaders: [String], _ coreRows: [[String]], _ transportHeaders: [String], _ transportRows: [[String]]) -> Void)
    {
        
        let tempSetting = SettingsManager.shared.temperature
        let pressSetting = SettingsManager.shared.pressure
        let densSetting = SettingsManager.shared.density
        let enthSetting = SettingsManager.shared.enthalpy
        let entrSetting = SettingsManager.shared.entropy
        
        let decimals = Int(SettingsManager.shared.decimals.rawValue) ?? 4
        let fmt = "%.\(decimals)f"
        
        func toBaseSI(param: IsoProcessModel, value: Double) -> Double {
            switch param {
            case .pressure: return pressSetting.toBaseSI(value: value)
            case .temperature: return tempSetting.toBaseSI(value: value)
            case .density: return densSetting.toBaseSI(value: value)
            case .enthalpy: return enthSetting.toBaseSI(value: value)
            case .entropy: return entrSetting.toBaseSI(value: value)
            }
        }
        
        func getCPKey(param: IsoProcessModel) -> String {
            switch param {
            case .pressure: return "P"
            case .temperature: return "T"
            case .density: return "D"
            case .enthalpy: return "H"
            case .entropy: return "S"
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var coreRows: [[String]] = []
            var transportRows: [[String]] = []
            
            let fixedKey = getCPKey(param: fixedParam)
            let fixedSI = toBaseSI(param: fixedParam, value: fixedValue)
            let iterKey = getCPKey(param: iteratedParam)
            
            let steps = stride(from: startValue, through: endValue, by: stepValue)
            
            for stepVal in steps {
                let iterSI = toBaseSI(param: iteratedParam, value: stepVal)
            
                let tRes = CoolPropService.shared.calculateProperty(output: "T", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let pRes = CoolPropService.shared.calculateProperty(output: "P", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let dRes = CoolPropService.shared.calculateProperty(output: "D", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let uRes = CoolPropService.shared.calculateProperty(output: "U", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let hRes = CoolPropService.shared.calculateProperty(output: "H", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let sRes = CoolPropService.shared.calculateProperty(output: "S", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let cpRes = CoolPropService.shared.calculateProperty(output: "C", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                let cvRes = CoolPropService.shared.calculateProperty(output: "O", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                
                let qRes = CoolPropService.shared.calculateProperty(output: "Q", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                
                // Validate that the phase state point exists and calculation succeeded
                if case .success(let t) = tRes,
                   case .success(let p) = pRes,
                   case .success(let d) = dRes,
                   case .success(let u) = uRes,
                   case .success(let h) = hRes,
                   case .success(let s) = sRes,
                   case .success(let cp) = cpRes,
                   case .success(let cv) = cvRes {
                    
                    var phaseStr = "Unknown"
                    if case .success(let q) = qRes, q >= 0.0, q <= 1.0 {
                        // It is a valid two-phase mixture!
                        phaseStr = String(format: "%.2f", q)
                    } else {
                        // Q failed or returned a nonsense value (single phase).
                        // Let's find Tsat at this exact Pressure to see where we are.
                        let tSatRes = CoolPropService.shared.calculateProperty(output: "T", input1: "P", val1: p, input2: "Q", val2: 0, fluid: fluidName)
                        
                        if case .success(let tSat) = tSatRes {
                            phaseStr = t > (tSat + 0.001) ? "Superheated" : "Subcooled"          // 0.001 buffer for floating point math
                        } else {
                            phaseStr = "Supercritical"
                        }
                    }
                    
                    
                    let coreRow: [String] = [
                        String(format: fmt, tempSetting.fromBaseSI(kelvin: t)),
                        String(format: fmt, pressSetting.fromBaseSI(pascal: p)),
                        String(format: fmt, densSetting.fromBaseSI(kg_per_CubicMeter: d)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: u)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: h)),
                        String(format: fmt, entrSetting.fromBaseSI(joul_per_KgKelvin: s)),
                        String(format: fmt, entrSetting.fromBaseSI(joul_per_KgKelvin: cp)),
                        String(format: fmt, entrSetting.fromBaseSI(joul_per_KgKelvin: cv)),
                        phaseStr
                    ]
                    coreRows.append(coreRow)
                    
                    var v_str = "-", nu_str = "-", k_str = "-", pr_str = "-", sigma_str = "-"
                    // If Phase is a number (e.g. "0.50"), it's inside the dome! Skip transport math.
                    let isTwoPhase = Double(phaseStr) != nil
                    
                    if !isTwoPhase {
                        let visc = CoolPropService.shared.calculateProperty(output: "V", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                        let cond = CoolPropService.shared.calculateProperty(output: "L", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                        let prandtl = CoolPropService.shared.calculateProperty(output: "Prandtl", input1: fixedKey, val1: fixedSI, input2: iterKey, val2: iterSI, fluid: fluidName)
                                            
                        if case .success(let mu) = visc {
                            v_str = String(format: "%.4e", mu)
                            nu_str = String(format: "%.4e", mu / d)
                        }
                        if case .success(let k) = cond { k_str = String(format: "%.4f", k) }
                        if case .success(let pr) = prandtl { pr_str = String(format: "%.3f", pr) }
                    }
                    
                    let transportRow = [v_str, nu_str, k_str, pr_str, sigma_str, phaseStr]
                    transportRows.append(transportRow)
                }
            }
            
            let coreHeaders = [
                "T\n(\(tempSetting.rawValue))", "P\n(\(pressSetting.rawValue))",
                "ρ\n(\(densSetting.rawValue))", "u\n(\(enthSetting.rawValue))", "h\n(\(enthSetting.rawValue))",
                "s\n(\(entrSetting.rawValue))", "Cp\n(\(entrSetting.rawValue))", "Cv\n(\(entrSetting.rawValue))", "State\n(Q)"
            ]
                        
            let transportHeaders = [
                "μ\n(Pa·s)", "ν\n(m²/s)", "k\n(W/m·K)", "Pr\n(-)", "σ\n(N/m)", "State\n(Q)"
            ]

            DispatchQueue.main.async {
                completion(coreHeaders, coreRows, transportHeaders, transportRows)
            }
        }
    }
}
