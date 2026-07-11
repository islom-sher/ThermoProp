//
//  SaturationStateCalculator.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/11/26.
//

import Foundation

/*
 The calculator is intented to calculate the properties of the fluid at saturation condition with known one parameter: (T) temperature or (P) pressure
 */

struct SaturationTableCalculator {
    
    static func generateSaturationTableAsync(fluidName: String, isTemperatureBased: Bool, startValue: Double, endValue: Double, stepValue: Double, completion: @escaping (_ coreHeaders: [String], _ coreRows: [[String]], _ transportHeaders: [String], _ transportRows: [[String]]) -> Void) {
        
        let tempSetting = SettingsManager.shared.temperature
        let pressSetting = SettingsManager.shared.pressure
        let densSetting = SettingsManager.shared.density
        let enthSetting = SettingsManager.shared.enthalpy
        let entrSetting = SettingsManager.shared.entropy
        
        let decimals = Int(SettingsManager.shared.decimals.rawValue) ?? 4
        let fmt = "%.\(decimals)f"
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var coreRows: [[String]] = []
            var transportRows: [[String]] = []
            
            let steps = stride(from: startValue, through: endValue, by: stepValue)
            
            for stepVal in steps {
                let baseInput = isTemperatureBased ? tempSetting.toBaseSI(value: stepVal) : pressSetting.toBaseSI(value: stepVal)
                let inputKey = isTemperatureBased ? "T" : "P"
                
                let t_base: Double
                let p_base: Double
                
                if isTemperatureBased {
                    t_base = baseInput // We already know T!
                    let pSatResult = CoolPropService.shared.calculateProperty(output: "P", input1: "T", val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                    if case .success(let p) = pSatResult { p_base = p } else { continue }
                } else {
                    p_base = baseInput // We already know P!
                    let tSatResult = CoolPropService.shared.calculateProperty(output: "T", input1: "P", val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                    if case .success(let t) = tSatResult { t_base = t } else { continue }
                }
                
                // Calculate Liquid Phase (Q = 0)
                let densL = CoolPropService.shared.calculateProperty(output: "D", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                let enthL = CoolPropService.shared.calculateProperty(output: "H", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                let intL = CoolPropService.shared.calculateProperty(output: "U", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                let entL = CoolPropService.shared.calculateProperty(output: "S", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                
                // Calculate Vapor Phase (Q = 1)
                let densV = CoolPropService.shared.calculateProperty(output: "D", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                let enthV = CoolPropService.shared.calculateProperty(output: "H", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                let intV = CoolPropService.shared.calculateProperty(output: "U", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                let entV = CoolPropService.shared.calculateProperty(output: "S", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                
                // Transport properties
                let viscL = CoolPropService.shared.calculateProperty(output: "V", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                let condL = CoolPropService.shared.calculateProperty(output: "L", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                let prandtlL = CoolPropService.shared.calculateProperty(output: "Prandtl", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                
                let viscV = CoolPropService.shared.calculateProperty(output: "V", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                let condV = CoolPropService.shared.calculateProperty(output: "L", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                let prandtlV = CoolPropService.shared.calculateProperty(output: "Prandtl", input1: inputKey, val1: baseInput, input2: "Q", val2: 1, fluid: fluidName)
                
                let surfTen = CoolPropService.shared.calculateProperty(output: "I", input1: inputKey, val1: baseInput, input2: "Q", val2: 0, fluid: fluidName)
                
                // If all properties successfully calculated, convert them back to user's units
                if case .success(let dl) = densL, case .success(let dv) = densV,
                   case .success(let hl) = enthL, case .success(let hv) = enthV,
                   case .success(let ul) = intL, case .success(let uv) = intV,
                   case .success(let sl) = entL, case .success(let sv) = entV {
                    
                    let col1 = isTemperatureBased ? String(format: fmt, tempSetting.fromBaseSI(kelvin: t_base)) : String(format: fmt, pressSetting.fromBaseSI(pascal: p_base))
                    let col2 = isTemperatureBased ? String(format: fmt, pressSetting.fromBaseSI(pascal: p_base)) : String(format: fmt, tempSetting.fromBaseSI(kelvin: t_base))
                    
                    let coreRow: [String] = [
                        col1, col2,
                        String(format: fmt, densSetting.fromBaseSI(kg_per_CubicMeter: dl)),
                        String(format: fmt, densSetting.fromBaseSI(kg_per_CubicMeter: dv)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: ul)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: uv)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: hl)),
                        String(format: fmt, enthSetting.fromBaseSI(joul_per_Kg: hv)),
                        String(format: fmt, entrSetting.fromBaseSI(joul_per_KgKelvin: sl)),
                        String(format: fmt, entrSetting.fromBaseSI(joul_per_KgKelvin: sv))
                    ]
                    coreRows.append(coreRow)
                    
                    var v_l = "-", v_v = "-", k_l = "-", k_v = "-", pr_l = "-", pr_v = "-", sigma = "-", nu_l = "-", nu_v = "-"
                    
                    if case .success(let val) = viscL {
                        v_l = String(format: "%.4e", val)
                        nu_l = String(format: "%.4e", val / dl)
                    }
                    if case .success(let val) = viscV {
                        v_v = String(format: "%.4e", val)
                        nu_v = String(format: "%.4e", val / dv)
                    }
                    if case .success(let val) = condL { k_l = String(format: "%.4f", val) }
                    if case .success(let val) = condV { k_v = String(format: "%.4f", val) }
                    if case .success(let val) = prandtlL { pr_l = String(format: "%.3f", val) }
                    if case .success(let val) = prandtlV { pr_v = String(format: "%.3f", val) }
                    if case .success(let val) = surfTen { sigma = String(format: "%.4f", val) }
                    
                    let transportRow = [v_l, v_v, nu_l, nu_v, k_l, k_v, pr_l, pr_v, sigma]
                    transportRows.append(transportRow)
                }
            }
            
            let h1 = isTemperatureBased ? "T\n(\(tempSetting.rawValue))" : "P\n(\(pressSetting.rawValue))"
            let h2 = isTemperatureBased ? "P\n(\(pressSetting.rawValue))" : "T\n(\(tempSetting.rawValue))"
            
            let coreHeaders = [
                h1, h2, "ρ_l\n(\(densSetting.rawValue))", "ρ_v\n(\(densSetting.rawValue))",
                "u_l\n(\(enthSetting.rawValue))", "u_v\n(\(enthSetting.rawValue))",
                "h_l\n(\(enthSetting.rawValue))", "h_v\n(\(enthSetting.rawValue))",
                "s_l\n(\(entrSetting.rawValue))", "s_v\n(\(entrSetting.rawValue))"
            ]
            
            let transportHeaders = [
                "μ_l\n(Pa·s)", "μ_v\n(Pa·s)", "ν_l\n(m²/s)", "ν_v\n(m²/s)",
                "k_l\n(W/m·K)", "k_v\n(W/m·K)", "Pr_l\n(-)", "Pr_v\n(-)", "σ\n(N/m)"
            ]
            
            DispatchQueue.main.async {
                completion(coreHeaders, coreRows, transportHeaders, transportRows)
            }
        }
    }
}

