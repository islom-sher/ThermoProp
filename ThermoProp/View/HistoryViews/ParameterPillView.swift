//
//  ParameterPillView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/26/26.
//

import UIKit

class ParameterPillView: UIView {
    
    let parameterLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 15), weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(parameterLabel)
        
        layer.cornerRadius = 8
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            parameterLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            parameterLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            parameterLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
            parameterLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, backColor: UIColor, textColor: UIColor, borderColor: CGColor) {
        parameterLabel.text = title
        parameterLabel.textColor = textColor
        
        backgroundColor = backColor
        self.layer.borderColor = borderColor
        
    }

}
