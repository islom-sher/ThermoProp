//
//  CalculateButton.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/8/26.
//

import UIKit

class CalculateButton: UIButton {
    
    enum ButtonStyle {
        case primary
        case secondary
    }
    
    private var currentStyle: ButtonStyle = .primary
    
    init(title: String, iconName: String? = nil, style: ButtonStyle = .primary) {
        self.currentStyle = style
        super.init(frame: .zero)
        configureButton(title: title, iconName: iconName)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton(title: "Calculate", iconName: "equal.square")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton(title: "Calculate", iconName: "equal.square")
    }
    
    private func configureButton(title: String, iconName: String?) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        layer.masksToBounds = true
        
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        config.imagePlacement = .leading
        config.imagePadding = 10
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .sfMono(size: adaptiveSize(phone: 16, pad: 18), weight: .bold)
        config.attributedTitle = AttributedString(title, attributes: textAttributes)
        
        if let iconName = iconName, let systemImage = UIImage(systemName: iconName) {
            config.image = systemImage
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        }
        
        switch currentStyle {
        case .primary:
            config.baseBackgroundColor = .buttonBackground
            config.baseForegroundColor = .buttonText
            self.setDynamicBorder(color: .fluidSelectedBorder, width: 1)
            
        case .secondary:
            config.baseBackgroundColor = .cardBackground
            config.baseForegroundColor = .label
            self.setDynamicBorder(color: .cardBorder, width: 1)
        }
        
        self.configuration = config
        
        if currentStyle == .secondary {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (button: CalculateButton, _) in
                button.layer.borderColor = UIColor.cardBorder.cgColor
            }
        } else {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (button: CalculateButton, _) in
                button.layer.borderColor = UIColor.cardBorder.cgColor
            }
        }
    }
    
    func setLoadingState(isCalculating: Bool, defaultTitle: String = "Generate table") {
        guard var config = self.configuration else { return }
        
        let newTitle = isCalculating ? "Calculating..." : defaultTitle
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .sfMono(size: adaptiveSize(phone: 16, pad: 18), weight: .bold)
        config.attributedTitle = AttributedString(newTitle, attributes: textAttributes)
        
        config.showsActivityIndicator = isCalculating
        self.configuration = config
        self.isUserInteractionEnabled = !isCalculating
    }
}
