//
//  FeaturesOverviewView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/8/26.
//

import UIKit

class FeaturesOverviewView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let mainStack = subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            mainStack.arrangedSubviews.forEach { row in
                row.layer.borderColor = UIColor.cardBorder.cgColor
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
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let features = [
            createFeatureRow(
                iconName: "smallcircle.filled.circle",
                iconColor: .dynamic(light: "#6C5BB5", dark: "#B3A6EB"),
                bgColor: .dynamic(light: "#E8E4F4", dark: "#2B2250"),
                title: "State point calculator",
                description: "Enter any two properties (T & P, P & h, T & s…) and instantly get all thermodynamic properties of the fluid."
            ),
            createFeatureRow(
                iconName: "tablecells",
                iconColor: .dynamic(light: "#4A78BE", dark: "#92B7EB"),
                bgColor: .dynamic(light: "#E4EDF8", dark: "#1D2D44"),
                title: "Saturation tables",
                description: "Generate liquid–vapor saturation data over a T or P range with custom step sizes. Export as PDF or CSV."
            ),
            createFeatureRow(
                iconName: "chart.xyaxis.line",
                iconColor: .dynamic(light: "#C4783A", dark: "#E8A874"),
                bgColor: .dynamic(light: "#FBF0E4", dark: "#4A2B14"),
                title: "Iso-process tables",
                description: "Fix one parameter (P, T, ρ, h or s) and iterate another over a range — perfect for process simulation."
            ),
            createFeatureRow(
                iconName: "chart.line.uptrend.xyaxis",
                iconColor: .dynamic(light: "#3A7A52", dark: "#9FE1CB"),
                bgColor: .dynamic(light: "#E8F3EE", dark: "#1A3B2A"),
                title: "Thermodynamic charts",
                description: "P–h and T–s diagrams, property curves, saturation envelopes — visualized with Swift Charts."
            )
        ]
            
        features.forEach { mainStack.addArrangedSubview($0) }
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createFeatureRow(iconName: String, iconColor: UIColor, bgColor: UIColor, title: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        
        let iconBg = UIView()
        iconBg.backgroundColor = bgColor
        iconBg.layer.cornerRadius = adaptiveSize(phone: 10, pad: 12)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: adaptiveSize(phone: 14, pad: 16), weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: adaptiveSize(phone: 12, pad: 14), weight: .regular)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconBg.addSubview(iconView)
        container.addSubview(iconBg)
        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconBg.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBg.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBg.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 36, pad: 46)),
            iconBg.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 36, pad: 46)),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 18, pad: 23)),
            iconView.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 18, pad: 23)),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
}
