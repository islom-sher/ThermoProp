//
//  HistoryManager.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/23/26.
//

import Foundation
import SwiftData

enum CalculatorCategory: String, Codable {
    case all = "All"
    case statePoint = "State Point"
    case saturation = "Saturation"
    case isoProcess = "Iso-Process"
}

@Model
class HistoryRecord {
    var id: UUID
    var date: Date
    var category: CalculatorCategory
    var fluidName: String
    var param1: String
    var param2: String
    
    var headers: [String]?
    var rows: [[String]]?
    
    var transportHeaders: [String]?
    var transportRows: [[String]]?
    
    init(category: CalculatorCategory, fluidName: String, param1: String, param2: String,
             headers: [String]? = nil, rows: [[String]]? = nil,
             transportHeaders: [String]? = nil, transportRows: [[String]]? = nil) {
        
        self.id = UUID()
        self.date = Date()
        self.category = category
        self.fluidName = fluidName
        self.param1 = param1
        self.param2 = param2
        self.headers = headers
        self.rows = rows
        self.transportHeaders = transportHeaders 
        self.transportRows = transportRows
    }
}
