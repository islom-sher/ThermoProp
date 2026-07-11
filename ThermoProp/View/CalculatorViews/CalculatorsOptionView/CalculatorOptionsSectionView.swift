//
//  CalculatorOptionsSectionView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/14/26.
//

import UIKit

class CalculatorOptionsSectionView: UIView {
    
    var onStatePointTapped: (() -> Void)?
    var onSaturationTableTapped: (() -> Void)?
    var onIsoProcessTapped: (() -> Void)?
    
    private let headerLabel: UILabel = {
       let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
       label.textColor = .darkGray
       label.text = "CHOOSE CALCULATOR"
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }()
   
   private lazy var statePointButton: CalculatorOptionButton = {
       let btn = CalculatorOptionButton(title: "State point",
                                        subtitle: "Two inputs → all properties",
                                        iconName: "smallcircle.filled.circle",
                                        iconColor: .statePointText,
                                        backgroundColor: .statePointBackground,
                                        borderColor: UIColor.statePointBorder)
       
       btn.addTarget(self, action: #selector(statePointPressed), for: .touchUpInside)
       return btn
   }()
   
   private lazy var saturationTableButton: CalculatorOptionButton = {
       let btn = CalculatorOptionButton(title: "Saturation table",
                                        subtitle: "One input iterated over range",
                                        iconName: "tablecells.fill",
                                        iconColor: .saturationText,
                                        backgroundColor: .saturationBackground,
                                        borderColor: UIColor.saturationBorder)
       
       btn.addTarget(self, action: #selector(saturationTablePressed), for: .touchUpInside)
       return btn
   }()
   
   private lazy var isoProcessButton: CalculatorOptionButton = {
       let btn = CalculatorOptionButton(title: "Iso-process table",
                                        subtitle: "Fixed + iterated parameter",
                                        iconName: "chart.line.uptrend.xyaxis",
                                        iconColor: .isoProcessText,
                                        backgroundColor: .isoProcessBackground,
                                        borderColor: UIColor.isoProcessBorder)
       
       btn.addTarget(self, action: #selector(isoProcessPressed), for: .touchUpInside)
       return btn
   }()
    
    override init(frame: CGRect) {
       super.init(frame: frame)
       setupView()
   }
   
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [statePointButton, saturationTableButton, isoProcessButton])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(headerLabel)
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            
            stack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func statePointPressed() { onStatePointTapped?() }
    @objc private func saturationTablePressed() { onSaturationTableTapped?() }
    @objc private func isoProcessPressed() { onIsoProcessTapped?() }
}
