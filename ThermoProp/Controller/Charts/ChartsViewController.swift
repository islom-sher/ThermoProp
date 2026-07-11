//
//  ChartsViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import UIKit
import SwiftUI

class ChartsViewController: UIViewController {
    
    var fluidName: String = "Water"
    var tripleT: Double = 273.16
    var criticalT: Double = 647.096
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chartTypeSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["p-h", "T-s", "Prop vs T"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let chartContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 24
        view.setDynamicBorder(color: .cardBorder, width: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()
    
    private var hostingController: UIHostingController<ThermodynamicChartView>?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Charts"
        subtitleLabel.text = "\(fluidName) · Saturation dome"
        
        setupLayout()
        chartTypeSegment.addTarget(self, action: #selector(chartTypeChanged), for: .valueChanged)
        
        renderChart(typeIndex: 0)
    }
    
    private func setupLayout() {
        view.addSubview(subtitleLabel)
        view.addSubview(chartTypeSegment)
        view.addSubview(chartContainerView)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            chartTypeSegment.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            chartTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartTypeSegment.heightAnchor.constraint(equalToConstant: 40),
            
            chartContainerView.topAnchor.constraint(equalTo: chartTypeSegment.bottomAnchor, constant: 24),
            chartContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func chartTypeChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
        renderChart(typeIndex: chartTypeSegment.selectedSegmentIndex)
    }
    
    private func renderChart(typeIndex: Int) {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        var xAxisTitle = ""
        var yAxisTitle = ""
        var isLogScale = false
        
        switch typeIndex {
        case 0:
            xAxisTitle = "Enthalpy (\(SettingsManager.shared.enthalpy.rawValue))"
            yAxisTitle = "Pressure (\(SettingsManager.shared.pressure.rawValue))"
            isLogScale = true
            
            ChartCalculator.generatePhDomeAsync(fluidName: fluidName, tripleT: tripleT, criticalT: criticalT) { [weak self] domeData in
                self?.embedSwiftUIChart(domeData: domeData, xAxisTitle: xAxisTitle, yAxisTitle: yAxisTitle, isLogScale: isLogScale)
            }
            return
                
        case 1:
            xAxisTitle = "Entropy (\(SettingsManager.shared.entropy.rawValue))"
            yAxisTitle = "Temperature (\(SettingsManager.shared.temperature.rawValue))"
        case 2:
            xAxisTitle = "Temperature (\(SettingsManager.shared.temperature.rawValue))"
            yAxisTitle = "Density (\(SettingsManager.shared.density.rawValue))"
        default: break
        }
            
        let emptyData = SaturationDomeData()
        embedSwiftUIChart(domeData: emptyData, xAxisTitle: xAxisTitle, yAxisTitle: yAxisTitle, isLogScale: isLogScale)
    }
    
    private func embedSwiftUIChart(domeData: SaturationDomeData, xAxisTitle: String, yAxisTitle: String, isLogScale: Bool) {
        let chartView = ThermodynamicChartView(
            domeData: domeData,
            xAxisTitle: xAxisTitle,
            yAxisTitle: yAxisTitle,
            isLogarithmicY: isLogScale
        )
        
        let host = UIHostingController(rootView: chartView)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        
        addChild(host)
        chartContainerView.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 16),
            host.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 16),
            host.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -16),
            host.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -16)
        ])
        
        host.didMove(toParent: self)
        self.hostingController = host
    }


}
