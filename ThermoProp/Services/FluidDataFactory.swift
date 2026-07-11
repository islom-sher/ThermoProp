//
//  FluidDataFactory.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/14/26.
//

import UIKit

class FluidDataFactory {
    
    private static let knownNaturalFluids: Set<String> = [
        "Water", "Air", "Ammonia", "CarbonDioxide", "Propane", "IsoButane",
        "n-Butane", "Isopentane", "n-Pentane", "Methane", "Ethane", "Ethylene",
        "Propylene", "Nitrogen", "Oxygen", "Argon", "Helium", "Hydrogen",
        "Neon", "Krypton", "Xenon", "CycloPentane", "CycloHexane", "SulfurDioxide",
        "HydrogenSulfide", "CarbonMonoxide", "HeavyWater", "Deuterium",
        "ParaHydrogen", "OrthoHydrogen"
    ]
    
    static func fetchAndCategorizeLibrary() -> [FluidSection] {
        let rawFluids = CoolPropService.shared.fetchAvailableFluids()
        
        var naturalFluids: [FluidItem] = []
        var syntheticFluids: [FluidItem] = []
        
        for name in rawFluids {
            let item = enrich(fluidName: name)
            if knownNaturalFluids.contains(name) {
                naturalFluids.append(item)
            } else {
                syntheticFluids.append(item)
            }
        }
        
        naturalFluids.sort { $0.name < $1.name }
        syntheticFluids.sort { $0.name < $1.name }
        
        return [
            FluidSection(title: "NATURAL FLUIDS", fluids: naturalFluids),
            FluidSection(title: "SYNTHETIC FLUIDS", fluids: syntheticFluids)
        ].filter { !$0.fluids.isEmpty }
    }

    
    private static func enrich(fluidName name: String) -> FluidItem {
            
        let metadata = CoolPropService.shared.fetchFluidMetadata(for: name)
        let icon = knownNaturalFluids.contains(name) ? "leaf" : "hexagon"
        
        var subtitleParts: [String] = []
        
        if metadata.formula != "UNKNOWN" && !metadata.formula.isEmpty {
            subtitleParts.append(metadata.formula)
        }
        if metadata.cas != "UNKNOWN" && !metadata.cas.isEmpty {
            subtitleParts.append("CAS: \(metadata.cas)")
        }
        if metadata.safetyClass != "UNKNOWN" && !metadata.safetyClass.isEmpty {
            subtitleParts.append("Class: \(metadata.safetyClass)")
        }
        
        let finalSubtitle = subtitleParts.isEmpty ? "Pure fluid" : subtitleParts.joined(separator: " • ")
        
        return FluidItem(
            name: name,
            subtitle: finalSubtitle,
            iconName: icon,
            isSelected: false
        )
    }
    


}
