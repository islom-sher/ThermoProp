//
//  FirstPage.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/8/26.
//

import UIKit

class FirstPage: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor.cardBorder.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBg = UIView()
        iconBg.backgroundColor = .dynamic(light: "#E8F3EE", dark: "#1A3B2A")
        iconBg.layer.cornerRadius = adaptiveSize(phone: 8, pad: 10)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "drop.fill"))
        iconView.tintColor = .dynamic(light: "#3A7A52", dark: "#9FE1CB")
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Water"
        titleLabel.font = .systemFont(ofSize: adaptiveSize(phone: 14, pad: 16), weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let formulaLabel = UILabel()
        formulaLabel.text = "H₂O"
        formulaLabel.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
        formulaLabel.textColor = .dynamic(light: "#3A7A52", dark: "#9FE1CB")
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray5
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 6
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        let row1 = UIStackView(arrangedSubviews: [
            createPropertyBox(title: "Density", value: "997.05", unit: "kg/m³", isHighlighted: false),
            createPropertyBox(title: "Enthalpy", value: "104.9", unit: "kJ/kg", isHighlighted: true)
        ])
        row1.spacing = 6
        row1.distribution = .fillEqually
        
        let row2 = UIStackView(arrangedSubviews: [
            createPropertyBox(title: "Entropy", value: "0.3672", unit: "kJ/kg·K", isHighlighted: false),
            createPropertyBox(title: "Cp", value: "4181.8", unit: "J/kg·K", isHighlighted: false)
        ])
        row2.spacing = 6
        row2.distribution = .fillEqually
        
        gridStack.addArrangedSubview(row1)
        gridStack.addArrangedSubview(row2)
        
        iconBg.addSubview(iconView)
        headerView.addSubview(iconBg)
        headerView.addSubview(titleLabel)
        headerView.addSubview(formulaLabel)
        
        addSubview(headerView)
        addSubview(divider)
        addSubview(gridStack)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 44, pad: 60)),
            
            iconBg.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 28, pad: 38)),
            iconBg.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 28, pad: 38)),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 14, pad: 19)),
            iconView.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 14, pad: 19)),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            formulaLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -14),
            formulaLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            divider.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            gridStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
            gridStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            gridStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            gridStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    private func createPropertyBox(title: String, value: String, unit: String, isHighlighted: Bool) -> UIView {
        let box = UIView()
        box.backgroundColor = isHighlighted ? .dynamic(light: "#E8F3EE", dark: "#1A3B2A") : UIColor.systemGray6
        box.layer.cornerRadius = 8
        box.layer.cornerCurve = .continuous
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: adaptiveSize(phone: 10, pad: 12), weight: .medium)
        titleLbl.textColor = isHighlighted ? .dynamic(light: "#3A7A52", dark: "#9FE1CB") : .secondaryLabel
        
        let valLbl = UILabel()
        valLbl.text = value
        valLbl.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .semibold)
        valLbl.textColor = isHighlighted ? .dynamic(light: "#1A5C40", dark: "#B2EAC4") : .label
        
        let unitLbl = UILabel()
        unitLbl.text = unit
        unitLbl.font = .systemFont(ofSize: adaptiveSize(phone: 10, pad: 12), weight: .medium)
        unitLbl.textColor = isHighlighted ? .dynamic(light: "#3A7A52", dark: "#9FE1CB") : .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [titleLbl, valLbl, unitLbl])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: adaptiveSize(phone: 8, pad: 10)),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: adaptiveSize(phone: 10, pad: 12)),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: adaptiveSize(phone: -10, pad: -12)),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: adaptiveSize(phone: -8, pad: -10))
        ])
        
        return box
    }

}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static func dynamic(light: String, dark: String) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }
}


