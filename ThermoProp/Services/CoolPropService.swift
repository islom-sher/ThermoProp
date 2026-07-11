//
//  CoolPropService.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import Foundation

class CoolPropService {
    
    static let shared = CoolPropService()
    
    private var lastConfiguredFluid: String? = nil
    private var lastConfiguredState: String? = nil
    
    private init() {}
    
    func fetchAvailableFluids() -> [String] {
        
        guard let cStringPointer = get_fluids_list() else { return [] }
        
        let rawFluidsString = String(cString: cStringPointer)
        
        return rawFluidsString.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func fetchFluidMetadata(for fluidName: String) -> FluidMetadata {
            
        func fetchParam(_ param: String) -> String {
            guard let cString = get_fluid_property(fluidName, param) else {
                return "UNKNOWN"
            }
            
            let result = String(cString: cString)

            if result == "false" || result.isEmpty {
                return "UNKNOWN"
            }
            return result
        }
        // Fetch and format the chemical formula
        let rawFormula = fetchParam("formula")
        let formattedFormula = rawFormula.formattingChemicalSubscripts()
        
        return FluidMetadata(
            formula: formattedFormula,
            cas: fetchParam("CAS"),
            safetyClass: fetchParam("ASHRAE34") // Note: Often returns "UNKNOWN" for standard fluids
        )
    }
    
    func calculateProperty(output: String, input1: String, val1: Double, input2: String, val2: Double, fluid: String) -> Result<Double,Error> {
        applyReferenceStateIfNeeded(for: fluid)
        
        let result = coolprop_props(output, input1, val1, input2, val2, fluid)
        
        if result == -1.0, let errorCpointer = coolprop_error() {
            let errorMessage = String(cString: errorCpointer)
            let error = NSError(domain: "CoolPropErrorDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            return .failure(error)
        }
        return .success(result)
    }
    
    func fetchConstants(for fluid: String) -> FluidCharacteristics? {
        
        applyReferenceStateIfNeeded(for: fluid)
        
        let rawMass = coolprop_props("molar_mass", "", 0, "", 0, fluid)
        let rawTc = coolprop_props("Tcrit", "", 0, "", 0, fluid)
        let rawPc = coolprop_props("Pcrit", "", 0, "", 0, fluid)
        let rawOmega = coolprop_props("acentric", "", 0, "", 0, fluid)
        let rawTt = coolprop_props("Ttriple", "", 0, "", 0, fluid)
        let rawPt = coolprop_props("ptriple", "", 0, "", 0, fluid)
        let rawGWP = coolprop_props("GWP100", "", 0, "", 0, fluid)
        let rawODP = coolprop_props("ODP", "", 0, "", 0, fluid)
        
        guard rawMass != -1.0, rawTc != -1.0, rawPc != -1.0 else {
            if let errorCpointer = coolprop_error() {
                let msg = String(cString: errorCpointer)
                print("DEBUG ERROR: Failed to fetch fluid constants for \(fluid). Reason: \(msg)")
            }
            return nil
        }
        
        let safeGWP = rawGWP.isFinite && rawGWP != -1.0 ? Int(rawGWP) : 0
        let safeODP = rawODP.isFinite && rawODP != -1.0 ? rawODP : 0.0
        
        return FluidCharacteristics(name: fluid,
                                    molarMass: rawMass * 1000.0,
                                    acentricFactor: rawOmega,
                                    criticalTemp: rawTc,
                                    criticalPress: rawPc,
                                    tripleTemp: rawTt,
                                    triplePress: rawPt,
                                    gwp: safeGWP,
                                    odp: safeODP)
    }
    
    private func applyReferenceStateIfNeeded(for fluid: String) {
        let currentState = SettingsManager.shared.referenceState.rawValue
        
        if fluid == lastConfiguredFluid && currentState == lastConfiguredState {
            return
        }
        
        _ = set_fluid_reference_state(fluid, currentState)
        
        lastConfiguredFluid = fluid
        lastConfiguredState = currentState
    }
}
