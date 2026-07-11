//
//  SpecifiedStateCalculator.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/12/26.
//

import Foundation


/*
 The calculator is intenteded to calculate the properties of the fluid by entering two known parameter of the fluid
 */

class StatePointCalculator {
    
    //MARK: - 1. Thermodynamic Properties
    static func fetchCorePropertiesAsync(
        fluidName: String,
        key1: String,
        siVal1: Double,
        key2: String,
        siVal2: Double,
        completion: @escaping (_ success: Bool, _ headers: [String], _ rows: [String], _ density: Double?) -> Void
    ) {
        // Run all math on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            let testDensity = CoolPropService.shared.calculateProperty(output: "D", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            
            guard case .success(let dTest) = testDensity, dTest.isFinite else {
                DispatchQueue.main.async {
                    completion(false, [], [], nil)
                }
                return
            }
            
            let tRes = CoolPropService.shared.calculateProperty(output: "T", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let pRes = CoolPropService.shared.calculateProperty(output: "P", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let uRes = CoolPropService.shared.calculateProperty(output: "U", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let hRes = CoolPropService.shared.calculateProperty(output: "H", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let sRes = CoolPropService.shared.calculateProperty(output: "S", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let cpRes = CoolPropService.shared.calculateProperty(output: "C", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let cvRes = CoolPropService.shared.calculateProperty(output: "O", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            let qRes = CoolPropService.shared.calculateProperty(output: "Q", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
            
            let decimals = Int(SettingsManager.shared.decimals.rawValue) ?? 4
            let fmt = "%.\(decimals)f"
            
            if case .success(let t) = tRes, case .success(let p) = pRes,
               case .success(let u) = uRes, case .success(let h) = hRes,
               case .success(let s) = sRes, case .success(let cp) = cpRes,
               case .success(let cv) = cvRes {
                
                // Determine Phase State
                var phaseStr = "Unknown"
                if case .success(let q) = qRes, q >= 0.0, q <= 1.0 {
                    phaseStr = String(format: "%.2f", q)
                } else {
                    let tSatRes = CoolPropService.shared.calculateProperty(output: "T", input1: "P", val1: p, input2: "Q", val2: 0, fluid: fluidName)
                    if case .success(let tSat) = tSatRes {
                        phaseStr = t > (tSat + 0.001) ? "Superheated" : "Subcooled"
                    } else {
                        phaseStr = "Supercritical"
                    }
                }
                
                // Format Rows
                let row = [
                    String(format: fmt, SettingsManager.shared.temperature.fromBaseSI(kelvin: t)),
                    String(format: fmt, SettingsManager.shared.pressure.fromBaseSI(pascal: p)),
                    String(format: fmt, SettingsManager.shared.density.fromBaseSI(kg_per_CubicMeter: dTest)),
                    String(format: fmt, SettingsManager.shared.enthalpy.fromBaseSI(joul_per_Kg: u)),
                    String(format: fmt, SettingsManager.shared.enthalpy.fromBaseSI(joul_per_Kg: h)),
                    String(format: fmt, SettingsManager.shared.entropy.fromBaseSI(joul_per_KgKelvin: s)),
                    String(format: fmt, SettingsManager.shared.entropy.fromBaseSI(joul_per_KgKelvin: cp)),
                    String(format: fmt, SettingsManager.shared.entropy.fromBaseSI(joul_per_KgKelvin: cv)),
                    phaseStr
                ]
                
                // Format Headers dynamically
                let headers = [
                    "T\n(\(SettingsManager.shared.temperature.rawValue))",
                    "P\n(\(SettingsManager.shared.pressure.rawValue))",
                    "ρ\n(\(SettingsManager.shared.density.rawValue))",
                    "u\n(\(SettingsManager.shared.enthalpy.rawValue))",
                    "h\n(\(SettingsManager.shared.enthalpy.rawValue))",
                    "s\n(\(SettingsManager.shared.entropy.rawValue))",
                    "Cp\n(\(SettingsManager.shared.entropy.rawValue))",
                    "Cv\n(\(SettingsManager.shared.entropy.rawValue))",
                    "State\n(Q)"
                ]
                
                DispatchQueue.main.async { completion(true, headers, row, dTest) }
            } else {
                DispatchQueue.main.async { completion(false, [], [], nil) }
            }
        }
    }
    
    // MARK: - 2. Transport Properties
    
    static func fetchTransportPropertiesAsync(
        fluidName: String,
        key1: String,
        siVal1: Double,
        key2: String,
        siVal2: Double,
        density: Double,
        phaseStr: String,
        completion: @escaping (_ headers: [String], _ row: [String]) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let decimals = Int(SettingsManager.shared.decimals.rawValue) ?? 4
            let fmt = "%.\(decimals)f"
            let sciFmt = "%.\(decimals)e"
            
            var kStr = "-"
            var muStr = "-"
            var nuStr = "-"
            var prStr = "-"
            var sigmaStr = "-"
            
            let isTwoPhase = Double(phaseStr) != nil
            
            if isTwoPhase {
                // IN THE DOME: Only Surface Tension exists. Skip the others!
                let surfRes = CoolPropService.shared.calculateProperty(output: "I", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
                if case .success(let sigma) = surfRes, sigma.isFinite { sigmaStr = String(format: fmt, sigma) }
        
            } else {
                // SINGLE PHASE: Conductivity and Viscosity exist. Surface Tension does not!
                let condRes = CoolPropService.shared.calculateProperty(output: "L", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
                let viscRes = CoolPropService.shared.calculateProperty(output: "V", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
                let prandtlRes = CoolPropService.shared.calculateProperty(output: "Prandtl", input1: key1, val1: siVal1, input2: key2, val2: siVal2, fluid: fluidName)
        
                if case .success(let k) = condRes, k.isFinite { kStr = String(format: fmt, k) }
        
                if case .success(let mu) = viscRes, mu.isFinite {
                    muStr = String(format: sciFmt, mu)
                    nuStr = String(format: sciFmt, mu / density)
                }
        
                if case .success(let pr) = prandtlRes, pr.isFinite { prStr = String(format: fmt, pr) }
            }
            let row = [kStr, muStr, nuStr, prStr, sigmaStr]
            
            let headers = [
                "k\n(W/m·K)",
                "μ\n(Pa·s)",
                "ν\n(m²/s)",
                "Pr\n()",
                "σ\n(N/m)"
            ]
            
            DispatchQueue.main.async { completion(headers, row) }
        }
    }
}
