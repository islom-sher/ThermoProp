//
//  InputFieldBox.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/7/26.
//

import UIKit

final class PaddedTextField: UITextField {

    private let horizontalInset: CGFloat

    init(inset: CGFloat) {
        self.horizontalInset = inset
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        self.horizontalInset = 12
        super.init(coder: coder)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset))
    }
}

class InputFieldBox: UIView {
    
    var iterationLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let textField: PaddedTextField = {
        let textfield = PaddedTextField(inset: 12)
        textfield.font = .sfMono(size: adaptiveSize(phone: 16, pad: 20), weight: .semibold)
        textfield.textColor = .label
        textfield.backgroundColor = .appBackground
        textfield.placeholder = "Input value"
        textfield.layer.cornerRadius = 8
        textfield.clipsToBounds = true
        textfield.keyboardType = .decimalPad
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        return textfield
    }()
    
    let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
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
        backgroundColor = .clear
    
        addSubview(iterationLabel)
        addSubview(unitLabel)
        addSubview(textField)
        
        let tfHeight: CGFloat = adaptiveSize(phone: 40, pad: 50)
        let labelToFieldSpacing: CGFloat = 6
        
        NSLayoutConstraint.activate([
            iterationLabel.topAnchor.constraint(equalTo: topAnchor),
            iterationLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            iterationLabel.trailingAnchor.constraint(lessThanOrEqualTo: unitLabel.leadingAnchor, constant: -4),
            
            unitLabel.topAnchor.constraint(equalTo: topAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            unitLabel.centerYAnchor.constraint(equalTo: iterationLabel.centerYAnchor),
            
            textField.topAnchor.constraint(equalTo: iterationLabel.bottomAnchor, constant: labelToFieldSpacing),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: tfHeight),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(placeholderValue: String, unitText: String) {
        textField.placeholder = placeholderValue
        unitLabel.text = unitText
//        iterationLabel.text = iteration
    }

}
