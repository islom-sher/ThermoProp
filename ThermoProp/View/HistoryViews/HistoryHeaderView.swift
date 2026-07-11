//
//  HistoryHeaderView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/28/26.
//

import UIKit

protocol HistoryHeaderDelegate: AnyObject {
    func didChangeViewMode(isThermodynamic: Bool)
}

class HistoryHeaderView: UIView {
    
    weak var delegate: HistoryHeaderDelegate?
    
    // MARK: - UI Components

    private lazy var fluidNameLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 24, pad: 26), weight: .bold)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .semibold)
        label.textColor = .secondaryLabel
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let viewModeSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["Themodynamic", "Transport"])
        sc.selectedSegmentIndex = 0
        sc.setContentCompressionResistancePriority(.required, for: .vertical)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private var param1Pill = ParameterPillView()
    private var param2Pill = ParameterPillView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        viewModeSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let labelStack = UIStackView(arrangedSubviews: [fluidNameLabel, timeLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 8
        labelStack.alignment = .leading
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let paramStack = UIStackView(arrangedSubviews: [param1Pill, param2Pill])
        paramStack.axis = .horizontal
        paramStack.spacing = 12
        paramStack.alignment = .leading
        paramStack.translatesAutoresizingMaskIntoConstraints = false
        paramStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addSubview(labelStack)
        addSubview(paramStack)
        addSubview(viewModeSegment)
        
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            paramStack.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 20),
            paramStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            viewModeSegment.topAnchor.constraint(equalTo: paramStack.bottomAnchor, constant: 20),
            viewModeSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            viewModeSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            viewModeSegment.heightAnchor.constraint(equalToConstant: 32),
            viewModeSegment.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    func configure(with record: HistoryRecord) {
        fluidNameLabel.text = record.fluidName
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let timeString = formatter.localizedString(for: record.date, relativeTo: Date())
        timeLabel.text = "Calculated \(timeString)"
        
        param1Pill.parameterLabel.text = record.param1
        param2Pill.parameterLabel.text = record.param2
        
        let hasTransportData = record.transportRows != nil && !(record.transportRows!.isEmpty)
        viewModeSegment.isHidden = !hasTransportData
        
        applyCategoryStyling(category: record.category)
    }
    
    @objc private func segmentChanged() {
        let isThermodynamic = viewModeSegment.selectedSegmentIndex == 0
        delegate?.didChangeViewMode(isThermodynamic: isThermodynamic)
    }
    
    private func applyCategoryStyling(category: CalculatorCategory) {
        let tintColor: UIColor
        let textLabelColor: UIColor
        let borderColor: UIColor
        
        switch category {
        case .statePoint:
            tintColor = .statePointBackground
            textLabelColor = .statePointText
            borderColor = .statePointBorder
        case .saturation:
            tintColor = .saturationBackground
            textLabelColor = .saturationText
            borderColor = .saturationBorder
        case .isoProcess:
            tintColor = .isoProcessBackground
            textLabelColor = .isoProcessText
            borderColor = .isoProcessBorder
        default:
            tintColor = .gray
            textLabelColor = .darkGray
            borderColor = .separator
        }
        
        param1Pill.backgroundColor = tintColor
        param1Pill.setDynamicBorder(color: borderColor, width: 0.4)
        param1Pill.parameterLabel.textColor = textLabelColor
        
        param2Pill.backgroundColor = tintColor
        param2Pill.setDynamicBorder(color: borderColor, width: 0.4)
        param2Pill.parameterLabel.textColor = textLabelColor
    }
}
