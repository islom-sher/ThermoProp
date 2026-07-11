//
//  EmptyStateView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/1/26.
//

import UIKit

class EmptyStateView: UIView {
            
    let icon: UIImageView = {
        let iconImage = UIImageView(image: UIImage(systemName: "thermometer.sun.fill"))
        iconImage.tintColor = .tertiaryLabel
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        return iconImage
    }()

    let title: UILabel = {
        let label = UILabel()
        label.text = "Ready to Calculate"
        label.font = .sfMono(size: adaptiveSize(phone: 20, pad: 24), weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    let message: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 15, pad: 18), weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    
    private func setupLayout() {
        addSubview(stack)
        
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(message)
   
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 60, pad: 80)),
            icon.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 60, pad: 80)),
            
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
    
    func configure(icon: String = "thermometer.sun.fill", message: String) {
        self.icon.image = UIImage(systemName: icon)
        self.message.text = message
    }
}
