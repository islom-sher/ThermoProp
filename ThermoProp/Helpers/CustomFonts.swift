//
//  CustomFonts.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import UIKit

// MARK: - enabling SF Mono font for all labels, textfields, and textViews
extension UIFont {
    
    static func sfMono(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let monoDescriptor = systemFont.fontDescriptor.withDesign(.monospaced) {
            return UIFont(descriptor: monoDescriptor, size: size)
        }
        return systemFont
    }
}


