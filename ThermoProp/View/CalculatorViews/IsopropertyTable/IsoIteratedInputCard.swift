//
//  IsoIteratedInputCard.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import UIKit

class IsoIteratedInputCard: UIView {
    
    var currentDisplayedParams: [IsoProcessModel] = []
    
    let segmentControl = CustomSegmentedControl(items: [])

    let fromInput = InputFieldBox()
    let toInput = InputFieldBox()
    let stepInput = InputFieldBox()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 16
        self.setDynamicBorder(color: .cardBorder, width: 1)
        
        let headerLabel = UILabel()
        headerLabel.text = "ITERATED PARAMETER"
        headerLabel.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
        headerLabel.textColor = .secondaryLabel
        
        segmentControl.selectedSegmentIndex = 1 // Default to Temperature
        
        fromInput.iterationLabel.text = "FROM"
        toInput.iterationLabel.text = "TO"
        stepInput.iterationLabel.text = "STEP"
        
        let stackView = UIStackView(arrangedSubviews: [fromInput, toInput, stepInput])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        let views = [headerLabel, segmentControl, stackView]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            segmentControl.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
            
            stackView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateSegments(excluding fixedParam: IsoProcessModel) {
        let allIteratedOptions: [IsoProcessModel] = [.pressure, .temperature, .density]
        
        // Filter out the parameter that is currently locked in the top card
        currentDisplayedParams = allIteratedOptions.filter { $0 != fixedParam }
        
        segmentControl.removeAllSegments()
        
        for (index, param) in currentDisplayedParams.enumerated() {
            segmentControl.insertSegment(withTitle: param.symbol, at: index, animated: false)
        }
    }

}
