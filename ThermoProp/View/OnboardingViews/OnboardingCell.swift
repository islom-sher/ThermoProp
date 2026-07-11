//
//  OnboardingCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/8/26.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    static let identifier = "OnboardingCell"
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let wrapperView = UIView()
    
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let tagContainer = UIView()
    private let tagLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let customViewContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        iconContainer.backgroundColor = .label
        iconContainer.layer.cornerRadius = adaptiveSize(phone: 18, pad: 20)
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.tintColor = .systemBackground
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        
        tagContainer.layer.cornerRadius = 6
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        
        tagLabel.font = .systemFont(ofSize: adaptiveSize(phone: 11, pad: 13), weight: .bold)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagContainer.addSubview(tagLabel)
        
        titleLabel.font = .systemFont(ofSize: adaptiveSize(phone: 28, pad: 30), weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        subtitleLabel.font = .systemFont(ofSize: adaptiveSize(phone: 15, pad: 17), weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        customViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        headerStack.addArrangedSubview(iconContainer)
        headerStack.addArrangedSubview(tagContainer)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitleLabel)
        
        headerStack.setCustomSpacing(12, after: tagContainer)
        
        contentView.addSubview(headerStack)
        contentView.addSubview(customViewContainer)
        
        let centerGuide = UILayoutGuide()
        contentView.addLayoutGuide(centerGuide)
                
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 72, pad: 92)),
            iconContainer.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 72, pad: 92)),
            
            iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),

            tagLabel.topAnchor.constraint(equalTo: tagContainer.topAnchor, constant: adaptiveSize(phone: 4, pad: 6)),
            tagLabel.bottomAnchor.constraint(equalTo: tagContainer.bottomAnchor, constant: adaptiveSize(phone: -4, pad: -6)),
            tagLabel.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor, constant: adaptiveSize(phone: 8, pad: 10)),
            tagLabel.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: adaptiveSize(phone: -8, pad: -10)),
            
            centerGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            centerGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            centerGuide.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            centerGuide.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            headerStack.topAnchor.constraint(equalTo: centerGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: centerGuide.leadingAnchor, constant: adaptiveSize(phone: 32, pad: 48)),
            headerStack.trailingAnchor.constraint(equalTo: centerGuide.trailingAnchor, constant: adaptiveSize(phone: -32, pad: -48)),
            
            customViewContainer.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 32),
            customViewContainer.centerXAnchor.constraint(equalTo: centerGuide.centerXAnchor),
            customViewContainer.widthAnchor.constraint(equalTo: centerGuide.widthAnchor, multiplier: adaptiveSize(phone: 0.85, pad: 0.7)),
            customViewContainer.bottomAnchor.constraint(lessThanOrEqualTo: centerGuide.bottomAnchor)
        ])
        let centerY = centerGuide.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 40)
        centerY.priority = .defaultHigh
        centerY.isActive = true
    }
        
    func configure(with page: OnboardingPage) {
        
        if let iconName = page.iconName {
            iconImageView.image = UIImage(named: iconName)
            iconContainer.isHidden = false
        } else {
            iconContainer.isHidden = true
        }
        
        tagLabel.text = page.tagText.uppercased()
        tagLabel.textColor = page.tagTextColor
        tagContainer.backgroundColor = page.tagBgColor
        
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
        
        customViewContainer.subviews.forEach { $0.removeFromSuperview() }
 
        let customView = page.customView
        customView.translatesAutoresizingMaskIntoConstraints = false
        customViewContainer.addSubview(customView)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: customViewContainer.topAnchor),
            customView.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor)
        ])
    }
}
