//
//  LicenseHeaderCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/7/26.
//

import UIKit

class ExpandableLicenseCell: UITableViewCell {
    
    static let identifier = "ExpandableLicenseCell"
        
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .darkGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 16, pad: 18), weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let licenseTextLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .cardBackground
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        iconContainer.addSubview(iconImageView)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(iconContainer)
        headerContainer.addSubview(textStack)
        headerContainer.addSubview(chevronImageView)
        
        mainStack.addArrangedSubview(headerContainer)
        mainStack.addArrangedSubview(separatorLine)
        mainStack.addArrangedSubview(licenseTextLabel)
        
        contentView.addSubview(mainStack)
        
        let bottomConstraint = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottomConstraint.priority = .init(999)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomConstraint,
            
            iconContainer.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            iconContainer.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            iconContainer.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(with license: OpenSourceLicense, isExpanded: Bool) {
        titleLabel.text = license.name
        subtitleLabel.text = license.version
        iconImageView.image = UIImage(systemName: license.iconSymbol)
        licenseTextLabel.text = license.text
        
        toggleExpansion(isExpanded: isExpanded)
    }
    
    func toggleExpansion(isExpanded: Bool) {
        licenseTextLabel.isHidden = !isExpanded
        separatorLine.isHidden = !isExpanded
        
        licenseTextLabel.alpha = isExpanded ? 1 : 0
        separatorLine.alpha = isExpanded ? 1 : 0
        
        let rotation: CGFloat = isExpanded ? .pi / 2 : 0
        chevronImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
