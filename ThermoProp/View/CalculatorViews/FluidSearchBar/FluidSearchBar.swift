//
//  FluidSearchBar.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/14/26.
//

import UIKit

class FluidSearchBar: UISearchBar {
    
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupStyle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    private func setupStyle() {
        let textField = self.searchTextField
        
        self.searchBarStyle = .minimal
        self.placeholder = "Search fluids..."
        self.translatesAutoresizingMaskIntoConstraints = false
        
        textField.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .bold)
        textField.borderStyle = .none
        textField.backgroundColor = .cardBackground
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.cardBorder.cgColor
        
        textField.layer.cornerRadius = 10
        textField.layer.cornerCurve = .continuous
        textField.clipsToBounds = true
        
        if isPad {
            textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }

    func configureAsSelected(for fluid: FluidItem) {
        let textField = self.searchTextField
        
        if textField.text == fluid.name && textField.rightView != nil {
            return
        }
        
        textField.text = fluid.name
        textField.textColor = .fluidSelectedText
        textField.layer.borderWidth = 1
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let customIcon = UIImage(systemName: fluid.iconName, withConfiguration: iconConfig)
        self.setImage(customIcon, for: .search, state: .normal)
        
        let iconTint = fluid.iconName == "leaf" ? UIColor.systemGreen : UIColor.systemIndigo
        if let leftView = textField.leftView as? UIImageView {
            leftView.tintColor = iconTint
        }
        
        let rightContainer = UIView()
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let formulaLabel = UILabel()
        formulaLabel.font = .sfMono(size: adaptiveSize(phone: 12, pad: 15), weight: .regular)
        formulaLabel.textColor = .fluidSelectedText
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let formula = fluid.subtitle.components(separatedBy: " • ").first {
            formulaLabel.text = formula
        }
        
        rightContainer.addSubview(formulaLabel)
        
        NSLayoutConstraint.activate([
            formulaLabel.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            formulaLabel.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            formulaLabel.centerYAnchor.constraint(equalTo: rightContainer.centerYAnchor),
            rightContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        textField.rightView = rightContainer
        textField.rightViewMode = .always
    }
    
    func resetToEmptyState() {
        let textField = self.searchTextField
        
        textField.text = ""
        textField.backgroundColor = .cardBackground
        textField.textColor = .label
        textField.layer.borderColor = UIColor.cardBorder.cgColor
        
        self.setImage(nil, for: .search, state: .normal)
        if let leftView = textField.leftView as? UIImageView {
            leftView.tintColor = .systemGray
        }
        
        textField.rightView = nil
        textField.rightViewMode = .never
    }

}
