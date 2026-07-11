//
//  IsoFixedInputCard.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import UIKit

class IsoFixedInputCard: UIView {

    let segmentControl = CustomSegmentedControl(items: IsoProcessModel.allCases.map { $0.symbol })
    
    let lockedContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .fluidSelectedBackground
        container.layer.cornerRadius = 12
        container.setDynamicBorder(color: .fluidSelectedBorder, width: 1)
        return container
    }()
    
    let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
    
    let valueField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.placeholder = "Enter..."
//        tf.text = "101325"
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .semibold),
            .foregroundColor: UIColor.fluidSelectedText,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        tf.defaultTextAttributes = textAttributes
        tf.textAlignment = .right
        return tf
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .fluidSelectedText
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 16), weight: .semibold)
        label.text = "Pressure fixed at"
        return label
    }()
    
    let unitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .fluidSelectedText
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 16), weight: .medium)
        label.text = "Pa"
        label.textAlignment = .right
        return label
    }()
    
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
        headerLabel.text = "FIXED PARAMETER"
        headerLabel.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
        headerLabel.textColor = .secondaryLabel
        
        segmentControl.selectedSegmentIndex = 0
        
        lockIcon.tintColor = .fluidSelectedText
        


        let views = [headerLabel, segmentControl, lockedContainer, lockIcon, titleLabel, valueField, unitLabel]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            if $0 != lockIcon && $0 != titleLabel && $0 != valueField && $0 != unitLabel {
                addSubview($0)
            }
        }
        
        lockedContainer.addSubview(lockIcon)
        lockedContainer.addSubview(titleLabel)
        lockedContainer.addSubview(valueField)
        lockedContainer.addSubview(unitLabel)

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        unitLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            segmentControl.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
            
            lockedContainer.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            lockedContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lockedContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            lockedContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            lockedContainer.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 45, pad: 50)),
            
            lockIcon.centerYAnchor.constraint(equalTo: lockedContainer.centerYAnchor),
            lockIcon.leadingAnchor.constraint(equalTo: lockedContainer.leadingAnchor, constant: 16),
            lockIcon.widthAnchor.constraint(equalToConstant: 14),
            lockIcon.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: lockedContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: lockIcon.trailingAnchor, constant: 8),
            
            unitLabel.centerYAnchor.constraint(equalTo: lockedContainer.centerYAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: lockedContainer.trailingAnchor, constant: -16),
            
            valueField.centerYAnchor.constraint(equalTo: lockedContainer.centerYAnchor),
            valueField.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor, constant: -8),
            valueField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    

}
