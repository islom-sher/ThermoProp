//
//  SettingsCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/15/26.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    static let identifier = "SettingsCell"
    var onToggle: ((Bool) -> Void)?
    
    // Zone A: Icon
    private let iconContainerView: UIView = {
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
    
    private let iconTextLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 18, pad: 22), weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Zone B: Text
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 11, pad: 13), weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let textVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let leftHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Zone C: Right-side Interactive Controls
    private let accessoryContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        self.layer.borderColor = UIColor.cardBorder.resolvedColor(with: self.traitCollection).cgColor
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: SettingsCell, previousTraitCollection: UITraitCollection) in
            view.layer.borderColor = UIColor.cardBorder.resolvedColor(with: view.traitCollection).cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupView() {
        backgroundColor = .cardBackground
        
        iconContainerView.addSubview(iconImageView)
        iconContainerView.addSubview(iconTextLabel)
        
        textVerticalStack.addArrangedSubview(titleLabel)
        textVerticalStack.addArrangedSubview(subtitleLabel)
        
        leftHorizontalStack.addArrangedSubview(iconContainerView)
        leftHorizontalStack.addArrangedSubview(textVerticalStack)
        
        contentView.addSubview(leftHorizontalStack)
        contentView.addSubview(accessoryContainer)
        
        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 32, pad: 40)),
            iconContainerView.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 32, pad: 40)),
            
            iconTextLabel.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconTextLabel.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: adaptiveSize(phone: 18, pad: 24)),
            iconImageView.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 18, pad: 24)),
            
            leftHorizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: adaptiveSize(phone: 12, pad: 16)),
            leftHorizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: adaptiveSize(phone: 12, pad: 16)),
            leftHorizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: adaptiveSize(phone: -12, pad: -16)),

            accessoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: adaptiveSize(phone: -12, pad: -16)),
            accessoryContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryContainer.heightAnchor.constraint(equalToConstant: 32),
            accessoryContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        
        self.separatorInset = UIEdgeInsets(top: 0, left: adaptiveSize(phone: 60, pad: 72), bottom: 0, right: adaptiveSize(phone: 12, pad: 16))
    }
    
    func configure(with item: SettingsItem) {
        titleLabel.text = item.title
        
        if let subtitleText = item.subtitle {
            subtitleLabel.text = subtitleText
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
        
        iconContainerView.backgroundColor = item.iconColor.withAlphaComponent(0.1)
        
        switch item.icon {
        case .symbol(let imageName):
            iconImageView.isHidden = false
            iconTextLabel.isHidden = true
            iconImageView.image = UIImage(systemName: imageName)
            iconImageView.tintColor = item.iconColor
            
        case .text(let variable):
            iconImageView.isHidden = true
            iconTextLabel.isHidden = false
            iconTextLabel.text = variable
            iconTextLabel.textColor = item.iconColor
        }
        
        buildAccessory(for: item.accessory)
    }
    
    private func buildAccessory(for type: SettingsAccessoryType) {
        
        accessoryContainer.subviews.forEach { $0.removeFromSuperview() }
        
        switch type {
        case .chevron(let value):
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 8
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            if let valueText = value {
                let label = UILabel()
                label.text = valueText
                label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .regular)
                label.textColor = .secondaryLabel
                stack.addArrangedSubview(label)
            }
            
            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = .tertiaryLabel
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            chevron.preferredSymbolConfiguration = config
            stack.addArrangedSubview(chevron)
            
            accessoryContainer.addSubview(stack)
            pinToContainer(stack)
            
        case .toggle(let isOn):
            let uiSwitch = UISwitch()
            uiSwitch.isOn = isOn
            uiSwitch.translatesAutoresizingMaskIntoConstraints = false
            uiSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            accessoryContainer.addSubview(uiSwitch)
            pinToContainer(uiSwitch)
            
        case .segment(let options):
            let segment = UISegmentedControl(items: options)
            segment.selectedSegmentIndex = 0
            
            segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segment.translatesAutoresizingMaskIntoConstraints = false
            segment.setContentCompressionResistancePriority(.required, for: .horizontal)
            accessoryContainer.addSubview(segment)
            pinToContainer(segment)
            
        case .externalLink:
            let arrow = UIImageView(image: UIImage(systemName: "arrow.up.forward.app"))
            arrow.tintColor = .tertiaryLabel
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            arrow.preferredSymbolConfiguration = config
            arrow.translatesAutoresizingMaskIntoConstraints = false
            accessoryContainer.addSubview(arrow)
            pinToContainer(arrow)
            
        case .none:
            break
        }
    }
    
    private func pinToContainer(_ view: UIView) {
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
            view.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            view.topAnchor.constraint(greaterThanOrEqualTo: accessoryContainer.topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: accessoryContainer.bottomAnchor)
        ])
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
}
