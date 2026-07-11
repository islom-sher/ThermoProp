//
//  ChartDataModels.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/5/26.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}

struct SaturationDomeData {
    var liquidLine: [ChartDataPoint] = []
    var vaporLine: [ChartDataPoint] = []
}
