//
//  Extensions.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/8/26.
//

import UIKit

// MARK: - formatting metadata of the fluids to user readable form
extension String {
    // Converts CoolProp "C_{2}H_{5}" into native "C₂H₅"
    func formattingChemicalSubscripts() -> String {
        var cleanString = self
            
        let subscriptMap: [String: String] = [
            "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
            "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉"
        ]
        // Remove the LaTeX brackets
        cleanString = cleanString.replacingOccurrences(of: "_{", with: "_")
        cleanString = cleanString.replacingOccurrences(of: "}", with: "")
        
        // Find underscores followed by digits and convert them
        while let range = cleanString.range(of: "_\\d+", options: .regularExpression) {
            let match = String(cleanString[range])
            var subscriptedMatch = ""
            
            for char in match where char != "_" {
                subscriptedMatch += subscriptMap[String(char)] ?? String(char)
            }
            
            cleanString.replaceSubrange(range, with: subscriptedMatch)
        }
        
        return cleanString
    }
}

extension UIView {
    
    // Applies a border width and a dynamic border color that automatically updates on Light/Dark mode changes.
    func setDynamicBorder(color: UIColor, width: CGFloat = 1.0) {
        
        // 1. Set the initial state
        self.layer.borderWidth = width
        self.layer.borderColor = color.resolvedColor(with: self.traitCollection).cgColor
        
        // 2. Handle future trait changes automatically (iOS 17+)
        if #available(iOS 17.0, *) {
            self.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIView, _) in
                view.layer.borderColor = color.resolvedColor(with: view.traitCollection).cgColor
            }
        }
    }
}

extension UIViewController {
    // Adds a tap gesture to the view that dismisses the keyboard when tapping anywhere outside a text field.
    func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboardAction() {
        view.endEditing(true)
    }
}

// MARK: - custom UIColors

extension UIColor {
    // Background color for screens
    static let appBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? .systemBackground
            : UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
    }
    
        //Background color elements
    static let cardBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? .secondarySystemBackground
            : .white
    }
    
    static let cardBorder = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? .tertiarySystemFill
            : UIColor.systemGray5
    }
    
    static let bentoCellBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? .tertiarySystemBackground
            : UIColor(red: 0.95, green: 0.95, blue: 0.93, alpha: 1.0)
    }
    
    // Dynamic Text Color for the green selected state
    static let fluidSelectedText = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.85, blue: 0.65, alpha: 1.0)
            : UIColor(red: 0.1, green: 0.4, blue: 0.25, alpha: 1.0)
    }
    
    // Dynamic Background Color for the green selected state
    static let fluidSelectedBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.2, blue: 0.1, alpha: 1.0)
            : UIColor(red: 0.89, green: 0.95, blue: 0.92, alpha: 1.0) 
    }
    
    // Dynamic Border Color for the green selected state
    static let fluidSelectedBorder = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.4, blue: 0.25, alpha: 1.0)
            : UIColor(red: 0.75, green: 0.9, blue: 0.85, alpha: 1.0)
    }
    
    // High-contrast filled button background color supporting dark/light switching
    static let buttonBackground = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.2, blue: 0.1, alpha: 1.0)
            : UIColor(red: 0.89, green: 0.95, blue: 0.92, alpha: 1.0)
    }
        
    // Tint/text color for elements placed directly inside the button
    static let buttonText = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.95, green: 0.98, blue: 0.96, alpha: 1.0)
            : UIColor(red: 0.1, green: 0.4, blue: 0.25, alpha: 1.0)
    }
}

class CustomSegmentedControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        setupStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    func setupStyle() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium),
            .foregroundColor: UIColor.label
        ]
        
        setTitleTextAttributes(normalAttributes, for: .normal)
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

extension UIDevice {
    
    static var isPad: Bool {
        return current.userInterfaceIdiom == .pad
    }
}



