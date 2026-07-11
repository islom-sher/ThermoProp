//
//  SessionDataManager.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/23/26.
//

import Foundation

class SessionDataManager {
    static let shared = SessionDataManager()
    
    private init() {}
    
    // MARK: - State Point Data
    var statePointCoreRows: [[String]] = []
    var statePointTransportRows: [[String]] = []
    
    // MARK: - Saturation Table Data
    var saturationCoreHeaders: [String] = []
    var saturationCoreRows: [[String]] = []
    var saturationTransportHeaders: [String] = []
    var saturationTransportRows: [[String]] = []
    
    // MARK: - Iso-Process Table Data
    var isoProcessCoreHeaders: [String] = []
    var isoProcessCoreRows: [[String]] = []
    var isoProcessTransportHeaders: [String] = []
    var isoProcessTransportRows: [[String]] = []
    
    // MARK: - Global Clear Helper
    func clearAllData() {
        statePointCoreRows.removeAll()
        statePointTransportRows.removeAll()
        
        saturationCoreHeaders.removeAll()
        saturationCoreRows.removeAll()
        saturationTransportHeaders.removeAll()
        saturationTransportRows.removeAll()
        
        isoProcessCoreHeaders.removeAll()
        isoProcessCoreRows.removeAll()
        isoProcessTransportHeaders.removeAll()
        isoProcessTransportRows.removeAll()
    }
}
