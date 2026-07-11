//
//  CustomiseExportView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/8/26.
//

import UIKit

class CustomiseExportView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if let mainStack = subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            for card in mainStack.arrangedSubviews {
                card.layer.borderColor = UIColor.cardBorder.cgColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.addArrangedSubview(createUnitPreferencesCard())
        mainStack.addArrangedSubview(createExportFormatsCard())
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    // MARK: - Unit Preferences Card
    private func createUnitPreferencesCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.clipsToBounds = true
        
        let header = createCardHeader(title: "Unit preferences")
        
        let row1 = createUnitRow(iconText: "T", iconColor: .dynamic(light: "#6C5BB5", dark: "#B3A6EB"), bgColor: .dynamic(light: "#E8E4F4", dark: "#2B2250"), title: "Temperature", unit: "°C", showDivider: true)
        let row2 = createUnitRow(iconText: "P", iconColor: .dynamic(light: "#4A78BE", dark: "#92B7EB"), bgColor: .dynamic(light: "#E4EDF8", dark: "#1D2D44"), title: "Pressure", unit: "bar", showDivider: true)
        let row3 = createUnitRow(iconText: "h", iconColor: .dynamic(light: "#C4783A", dark: "#E8A874"), bgColor: .dynamic(light: "#FBF0E4", dark: "#4A2B14"), title: "Enthalpy", unit: "kJ/kg", showDivider: false)
            
        let stack = UIStackView(arrangedSubviews: [header, row1, row2, row3])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        
        return card
    }
    
    private func createUnitRow(iconText: String, iconColor: UIColor, bgColor: UIColor, title: String, unit: String, showDivider: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBg = UIView()
        iconBg.backgroundColor = bgColor
        iconBg.layer.cornerRadius = adaptiveSize(phone: 7, pad: 10)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLbl = UILabel()
        iconLbl.text = iconText
        iconLbl.font = .systemFont(ofSize: adaptiveSize(phone: 12, pad: 14), weight: .semibold)
        iconLbl.textColor = iconColor
        iconLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .sfMono(size: adaptiveSize(phone: 13, pad: 15), weight: .regular)
        titleLbl.textColor = .label
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let unitLbl = UILabel()
        unitLbl.text = unit
        unitLbl.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .regular)
        unitLbl.textColor = .secondaryLabel
        unitLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        iconBg.addSubview(iconLbl)
        container.addSubview(iconBg)
        container.addSubview(titleLbl)
        container.addSubview(unitLbl)
        container.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 44, pad: 54)),
            
            iconBg.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 26, pad: 36)),
            iconBg.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 26, pad: 36)),
            
            iconLbl.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconLbl.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            
            titleLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            titleLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 12, pad: 14)),
            chevron.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 12, pad: 14)),
            
            unitLbl.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            unitLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
            
        if showDivider {
            let divider = UIView()
            divider.backgroundColor = UIColor.systemGray5
            divider.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
                divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
                divider.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        return container
    }
    
    // MARK: - Export Formats Card
    private func createExportFormatsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.clipsToBounds = true
        
        let header = createCardHeader(title: "Export formats")
        
        let leftBox = createExportBox(iconName: "doc.text.fill", iconColor: .dynamic(light: "#A32D2D", dark: "#F08A8A"), bgColor: .dynamic(light: "#FCEBEB", dark: "#4A1515"), title: "PDF", subtitle: "Print-ready", hasRightBorder: true)
        let rightBox = createExportBox(iconName: "tablecells.fill", iconColor: .dynamic(light: "#3B6D11", dark: "#9BD069"), bgColor: .dynamic(light: "#EAF3DE", dark: "#1B3608"), title: "CSV", subtitle: "Excel / Sheets", hasRightBorder: false)
            
        let gridStack = UIStackView(arrangedSubviews: [leftBox, rightBox])
        gridStack.axis = .horizontal
        gridStack.distribution = .fillEqually
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [header, gridStack])
        mainStack.axis = .vertical
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        return card
    }
    
    private func createExportBox(iconName: String, iconColor: UIColor, bgColor: UIColor, title: String, subtitle: String, hasRightBorder: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBg = UIView()
        iconBg.backgroundColor = bgColor
        iconBg.layer.cornerRadius = adaptiveSize(phone: 8, pad: 10)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = iconColor
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .sfMono(size: adaptiveSize(phone: 12, pad: 15), weight: .medium)
        titleLbl.textColor = .label
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let subLbl = UILabel()
        subLbl.text = subtitle
        subLbl.font = .sfMono(size: adaptiveSize(phone: 10, pad: 12), weight: .regular)
        subLbl.textColor = .secondaryLabel
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        
        iconBg.addSubview(icon)
        container.addSubview(iconBg)
        container.addSubview(titleLbl)
        container.addSubview(subLbl)
            
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 52, pad: 62)),
            
            iconBg.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 28, pad: 38)),
            iconBg.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 28, pad: 38)),
            
            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 14, pad: 19)),
            icon.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 14, pad: 19)),
            
            titleLbl.topAnchor.constraint(equalTo: iconBg.topAnchor, constant: 3),
            titleLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 8),
            
            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 0),
            subLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 8)
        ])
        
        if hasRightBorder {
            let border = UIView()
            border.backgroundColor = UIColor.systemGray5
            border.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(border)
            NSLayoutConstraint.activate([
                border.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                border.topAnchor.constraint(equalTo: container.topAnchor),
                border.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                border.widthAnchor.constraint(equalToConstant: 0.5)
            ])
        }
            
        return container
    }
    
    // MARK: - Helper
    private func createCardHeader(title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title.uppercased()
        label.font = .sfMono(size: adaptiveSize(phone: 10, pad: 12), weight: .medium)
        label.textColor = .secondaryLabel
        label.letterSpacing(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray5
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(divider)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 32, pad: 42)),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return container
    }

}

// UILabel Extension to handle Letter Spacing
extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
}
