//
//  ChartCalculator.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/5/26.
//

import Foundation

class ChartCalculator {
    
    static func generatePhDomeAsync(
            fluidName: String,
            tripleT: Double,
            criticalT: Double,
            steps: Int = 40,
            completion: @escaping (SaturationDomeData) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            var data = SaturationDomeData()
            
            let stepSize = (criticalT - tripleT) / Double(steps)
            
            for i in 0...steps {
                // Stop slightly below Critical T to prevent CoolProp singularities at the exact peak
                let currentT = min(tripleT + (Double(i) * stepSize), criticalT - 0.05)
                
                // 1. Saturated Liquid (Q = 0)
                let pLiqRes = CoolPropService.shared.calculateProperty(output: "P", input1: "T", val1: currentT, input2: "Q", val2: 0, fluid: fluidName)
                let hLiqRes = CoolPropService.shared.calculateProperty(output: "H", input1: "T", val1: currentT, input2: "Q", val2: 0, fluid: fluidName)
                
                if case .success(let pLiq) = pLiqRes, case .success(let hLiq) = hLiqRes {
                    let pDisplay = SettingsManager.shared.pressure.fromBaseSI(pascal: pLiq)
                    let hDisplay = SettingsManager.shared.enthalpy.fromBaseSI(joul_per_Kg: hLiq)
                    data.liquidLine.append(ChartDataPoint(x: hDisplay, y: pDisplay))
                }
                
                // 2. Saturated Vapor (Q = 1)
                let pVapRes = CoolPropService.shared.calculateProperty(output: "P", input1: "T", val1: currentT, input2: "Q", val2: 1, fluid: fluidName)
                let hVapRes = CoolPropService.shared.calculateProperty(output: "H", input1: "T", val1: currentT, input2: "Q", val2: 1, fluid: fluidName)
                
                if case .success(let pVap) = pVapRes, case .success(let hVap) = hVapRes {
                    let pDisplay = SettingsManager.shared.pressure.fromBaseSI(pascal: pVap)
                    let hDisplay = SettingsManager.shared.enthalpy.fromBaseSI(joul_per_Kg: hVap)
                    data.vaporLine.append(ChartDataPoint(x: hDisplay, y: pDisplay))
                }
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
}
