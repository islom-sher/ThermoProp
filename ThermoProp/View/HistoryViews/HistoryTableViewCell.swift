//
//  HistoryTableViewCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/23/26.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    static let identifier = "HistoryTableViewCell"
    
    private let mainIconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let categoryPillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 11, pad: 13), weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fluidNameLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 17, pad: 20), weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let param1PillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let param1Label: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let param2PillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let param2Label: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 15), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 11, pad: 14), weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
        
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let fluidNameStack = UIStackView(arrangedSubviews: [categoryPillView, fluidNameLabel])
        fluidNameStack.axis = .vertical
        fluidNameStack.alignment = .leading
        fluidNameStack.spacing = 5
        fluidNameStack.distribution = .equalSpacing
        fluidNameStack.translatesAutoresizingMaskIntoConstraints = false
        
        let paramsStack = UIStackView(arrangedSubviews: [param1PillView, param2PillView])
        paramsStack.axis = .vertical
        paramsStack.alignment = .trailing
        paramsStack.spacing = 3
        paramsStack.distribution = .equalSpacing
        paramsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let leftStack = UIStackView(arrangedSubviews: [mainIconContainer, fluidNameStack])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 16
        leftStack.distribution = .equalSpacing
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        
        let rightStack = UIStackView(arrangedSubviews: [paramsStack, timeLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 6
        rightStack.distribution = .equalSpacing
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainIconContainer.addSubview(mainIconView)

        categoryPillView.addSubview(categoryLabel)
        param1PillView.addSubview(param1Label)
        param2PillView.addSubview(param2Label)
        
        contentView.addSubview(leftStack)
        contentView.addSubview(rightStack)
        
        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            rightStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: adaptiveSize(phone: 10, pad: 14)),
            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: adaptiveSize(phone: -5, pad: -10)),
            
            mainIconContainer.widthAnchor.constraint(equalToConstant: 36),
            mainIconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            mainIconView.centerXAnchor.constraint(equalTo: mainIconContainer.centerXAnchor),
            mainIconView.centerYAnchor.constraint(equalTo: mainIconContainer.centerYAnchor),
            mainIconView.widthAnchor.constraint(equalToConstant: 18),
            mainIconView.heightAnchor.constraint(equalToConstant: 18),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryPillView.topAnchor, constant: 2),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryPillView.leadingAnchor, constant: 6),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryPillView.trailingAnchor, constant: -6),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryPillView.bottomAnchor, constant: -2),
            
            param1Label.topAnchor.constraint(equalTo: param1PillView.topAnchor, constant: 2),
            param1Label.leadingAnchor.constraint(equalTo: param1PillView.leadingAnchor, constant: 6),
            param1Label.trailingAnchor.constraint(equalTo: param1PillView.trailingAnchor, constant: -6),
            param1Label.bottomAnchor.constraint(equalTo: param1PillView.bottomAnchor, constant: -2),

            param2Label.topAnchor.constraint(equalTo: param2PillView.topAnchor, constant: 2),
            param2Label.leadingAnchor.constraint(equalTo: param2PillView.leadingAnchor, constant: 6),
            param2Label.trailingAnchor.constraint(equalTo: param2PillView.trailingAnchor, constant: -6),
            param2Label.bottomAnchor.constraint(equalTo: param2PillView.bottomAnchor, constant: -2),
            
        ])
    }
    
    func configure(with record: HistoryRecord) {
        fluidNameLabel.text = record.fluidName
        categoryLabel.text = record.category.rawValue
        
        param1Label.text = record.param1
        param2Label.text = record.param2
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        timeLabel.text = formatter.localizedString(for: record.date, relativeTo: Date())
        
        applyCategoryStyling(category: record.category)
    }
    
    private func applyCategoryStyling(category: CalculatorCategory) {
        let tintColor: UIColor
        let textLabelColor: UIColor
        let borderColor: UIColor
        let mainIconName: String
        
        switch category {
        case .statePoint:
            tintColor = .statePointBackground
            textLabelColor = .statePointText
            borderColor = .statePointBorder
            mainIconName = "smallcircle.filled.circle"
        case .saturation:
            tintColor = .saturationBackground
            textLabelColor = .saturationText
            borderColor = .saturationBorder
            mainIconName = "tablecells.fill"
        case .isoProcess:
            tintColor = .isoProcessBackground
            textLabelColor = .isoProcessText
            borderColor = .isoProcessBorder
            mainIconName = "chart.line.uptrend.xyaxis"
        default:
            tintColor = .gray
            textLabelColor = .darkGray
            borderColor = .separator
            mainIconName = "circle"
        }
        
        mainIconView.image = UIImage(systemName: mainIconName)
        mainIconView.tintColor = textLabelColor
        mainIconContainer.backgroundColor = tintColor
        mainIconContainer.setDynamicBorder(color: borderColor, width: 0.4)
        
        categoryLabel.textColor = textLabelColor
        categoryPillView.backgroundColor = tintColor
        categoryPillView.setDynamicBorder(color: borderColor, width: 0.4)
        
        param1PillView.backgroundColor = tintColor
        param1PillView.setDynamicBorder(color: borderColor, width: 0.4)
        param1Label.textColor = textLabelColor
        
        param2PillView.backgroundColor = tintColor
        param2PillView.setDynamicBorder(color: borderColor, width: 0.4)
        param2Label.textColor = textLabelColor
    }

}

extension UIColor {
    
    static let statePointText = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.55, green: 0.85, blue: 0.65, alpha: 1.0)
        : UIColor(red: 0.1, green: 0.4, blue: 0.25, alpha: 1.0)
    }
    
    static let statePointBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.05, green: 0.20, blue: 0.10, alpha: 1.0)
        : UIColor(red: 0.89, green: 0.95, blue: 0.92, alpha: 1.0)
    }
    
    static let statePointBorder = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.40, blue: 0.25, alpha: 1.0)
            : UIColor(red: 0.75, green: 0.90, blue: 0.85, alpha: 1.0)
    }
    
    // MARK: - Saturation (Blue)
    static let saturationText = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.40, green: 0.75, blue: 1.00, alpha: 1.0) // Vibrant Cyan-Blue
            : UIColor(red: 0.15, green: 0.35, blue: 0.70, alpha: 1.0) // Deep Blue
    }
    static let saturationBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.15, blue: 0.30, alpha: 1.0) // Deep Navy Wash
            : UIColor(red: 0.90, green: 0.94, blue: 0.98, alpha: 1.0) // Soft Ice Blue
    }
    
    static let saturationBorder = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.15, green: 0.35, blue: 0.60, alpha: 1.0)
        : UIColor(red: 0.70, green: 0.85, blue: 0.95, alpha: 1.0)
    }
    
    //MARK: - Iso-Process
    static let isoProcessText = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.70, blue: 0.30, alpha: 1.0) // Vibrant Gold/Orange
            : UIColor(red: 0.60, green: 0.35, blue: 0.10, alpha: 1.0) // Earthy Brown-Orange
    }

    static let isoProcessBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.12, blue: 0.05, alpha: 1.0) // Dark Rust Wash
            : UIColor(red: 0.98, green: 0.93, blue: 0.88, alpha: 1.0) // Soft Sand/Peach
    }
    
    static let isoProcessBorder = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.45, green: 0.25, blue: 0.10, alpha: 1.0)
            : UIColor(red: 0.92, green: 0.82, blue: 0.72, alpha: 1.0)
    }
}
