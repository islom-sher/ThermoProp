//
//  SaturationRowCell.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/16/26.
//

import UIKit

class GridRowCell: UICollectionViewCell {
    static let identifier = "GridRowCell"
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var labels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                if self.isSelected {
                    // Match the light green background from your screenshot
                    self.contentView.backgroundColor = .fluidSelectedBackground
                    
                    // Match the dark green/teal text color
                    let selectedTextColor = UIColor.fluidSelectedText
                    self.labels.forEach { $0.textColor = selectedTextColor }
                } else {
                    // Revert back to original clear background and default label colors
                    self.contentView.backgroundColor = .clear
                    self.labels.forEach { $0.textColor = .label }
                }
            }
        }
    }
    
    
    private func setupView() {
        contentView.addSubview(stackView)
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separator.isHidden = false
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        labels.removeAll()
    }
    
    func configure(with data: [String], isHeader: Bool) {
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        
        var firstLabel: UILabel? = nil
        
        for (index, text) in data.enumerated() {
            let label = UILabel()
            label.text = text
            label.numberOfLines = isHeader ? 2 : 1
            label.textAlignment = .center
    
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            
            if isHeader {
                label.font = .sfMono(size: adaptiveSize(phone: 11, pad: 13), weight: .bold)
                label.textColor = .secondaryLabel
            } else {
                label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
                label.textColor = .label
            }
            
            stackView.addArrangedSubview(label)
            labels.append(label)
            
            if let first = firstLabel {
                label.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
            } else {
                firstLabel = label
            }
        
            if index < data.count - 1 {
                let verticalLine = UIView()
                verticalLine.backgroundColor = .separator
                verticalLine.translatesAutoresizingMaskIntoConstraints = false
                
                verticalLine.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(verticalLine)
            }
        }
        
        contentView.backgroundColor = isHeader ? UIColor.secondarySystemBackground : .clear
    }
}
