//
//  FluidSearchCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/14/26.
//

import UIKit

class FluidSearchCell: UITableViewCell {
    static let identifier = "FluidSearchCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 10, pad: 14), weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark")

        iv.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        backgroundColor = .cardBackground
        selectionStyle = .none
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(iconContainer)
        contentView.addSubview(textStack)
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -16),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 18),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 18),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }
    
    func configure(with fluid: FluidItem) {
        titleLabel.text = fluid.name
        subtitleLabel.text = fluid.subtitle
        iconImageView.image = UIImage(systemName: fluid.iconName)
        
        if fluid.iconName == "leaf" {
            iconImageView.tintColor = .systemGreen
            iconContainer.backgroundColor = .systemGreen.withAlphaComponent(0.15)
        } else {
            iconImageView.tintColor = .systemIndigo
            iconContainer.backgroundColor = .systemIndigo.withAlphaComponent(0.15)
        }
        
        checkmarkImageView.isHidden = !fluid.isSelected
        
        // Active Selection Styling
        if fluid.isSelected {
            contentView.backgroundColor = .fluidSelectedBackground
            titleLabel.textColor = .fluidSelectedText
        } else {
            contentView.backgroundColor = .cardBackground
            titleLabel.textColor = .label
        }
    }

}
