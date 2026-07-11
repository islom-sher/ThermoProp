//
//  ThermodynamicChartView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/5/26.
//

import SwiftUI
import Charts

struct ThermodynamicChartView: View {

    var domeData: SaturationDomeData
    var xAxisTitle: String
    var yAxisTitle: String
    var isLogarithmicY: Bool = false

    var body: some View {
            Chart {
                // Saturated Liquid Line
                ForEach(domeData.liquidLine) { point in
                    LineMark(
                        x: .value(xAxisTitle, point.x),
                        y: .value(yAxisTitle, point.y)
                    )
                    .foregroundStyle(Color(uiColor: .systemBlue))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                
                // Saturated Vapor Line
                ForEach(domeData.vaporLine) { point in
                    LineMark(
                        x: .value(xAxisTitle, point.x),
                        y: .value(yAxisTitle, point.y)
                    )
                    .foregroundStyle(Color(uiColor: .systemRed))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartXAxisLabel(xAxisTitle, alignment: .center)
            .chartYAxisLabel(yAxisTitle, alignment: .center)
            // If it is a p-h diagram, pressure is usually plotted on a Log10 scale
            .chartYScale(domain: .automatic, type: isLogarithmicY ? .log : .linear)
            .padding()
        }
}
