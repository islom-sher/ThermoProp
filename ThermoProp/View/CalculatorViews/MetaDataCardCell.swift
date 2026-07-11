//
//  ResultCardCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/8/26.
//

import UIKit

class MetaDataCardCell: UICollectionViewCell {
    
    static let identifier = "MetaDataCardCell"
    
    // MARK: - UI Components -

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 11, pad: 14), weight: .semibold)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 18, pad: 22), weight: .semibold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 16), weight: .semibold)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    // MARK: - Layout Setup -
    private func setupView() {
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.bentoCellBackground.cgColor
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: MetaDataCardCell, previousTraitCollection) in
                self.layer.backgroundColor = UIColor.bentoCellBackground.cgColor
            }
        }
        
        let valueTitleStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueTitleStack.axis = .horizontal
        valueTitleStack.spacing = 15
        valueTitleStack.alignment = .trailing
        valueTitleStack.distribution = .fill
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, valueTitleStack])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.alignment = .leading
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Data Configuration -
    
    func configure(with item: CharacteristicItem) {
        titleLabel.text = item.title
        valueLabel.text = item.value
        unitLabel.text = item.unit
    }
}
