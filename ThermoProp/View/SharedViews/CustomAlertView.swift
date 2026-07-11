//
//  CustomAlertView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/6/26.
//

import UIKit

enum AlertType {
    case success
    case warning
    case error
    
    var styling: (backgroundColor: UIColor, foregroundColor: UIColor, iconName: String) {
        let dynamicBG: UIColor
        let dynamicFG: UIColor
        
        switch self {
        case .success:
            dynamicBG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 27/255, green: 62/255, blue: 34/255, alpha: 1.0) :
                UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1.0)
            }
            dynamicFG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1.0) :
                UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
            }
            return (dynamicBG, dynamicFG, "checkmark.circle.fill")
        case .warning:
            dynamicBG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 66/255, green: 50/255, blue: 16/255, alpha: 1.0) :
                UIColor(red: 255/255, green: 248/255, blue: 225/255, alpha: 1.0)
            }
            dynamicFG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 255/255, green: 213/255, blue: 79/255, alpha: 1.0) :
                UIColor(red: 255/255, green: 179/255, blue: 0/255, alpha: 1.0)
            }
            return (dynamicBG, dynamicFG, "exclamationmark.triangle.fill")
        case .error:
            dynamicBG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 74/255, green: 24/255, blue: 24/255, alpha: 1.0) :
                UIColor(red: 255/255, green: 235/255, blue: 238/255, alpha: 1.0)
            }
            dynamicFG = UIColor { trait in
                return trait.userInterfaceStyle == .dark ?
                UIColor(red: 239/255, green: 154/255, blue: 154/255, alpha: 1.0) :
                UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 1.0)
            }
            return (dynamicBG, dynamicFG, "xmark.circle.fill")
        }
    }
}

class CustomAlertView: UIView {

    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var dismissWorkItem: DispatchWorkItem?
    
    // MARK: - Init
    private init(type: AlertType, title: String, message: String) {
        super.init(frame: .zero)
        setupView(type: type, title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView(type: AlertType, title: String, message: String) {
        let style = type.styling
        
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 16
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        
        iconImageView.image = UIImage(systemName: style.iconName)
        iconImageView.tintColor = style.foregroundColor
        
        titleLabel.text = title
        titleLabel.textColor = style.foregroundColor
        messageLabel.text = message
        messageLabel.textColor = style.foregroundColor
        
        closeButton.tintColor = style.foregroundColor
        closeButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(dismissAlert))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconImageView)
        addSubview(textStack)
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Presentation Logic
    static func show(type: AlertType, title: String, message: String, duration: TimeInterval = 3.5) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
            
            let alert = CustomAlertView(type: type, title: title, message: message)
            alert.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(alert)
            
            NSLayoutConstraint.activate([
                alert.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 16),
                alert.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
                alert.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16)
            ])
            
            // Initial animation state
            alert.alpha = 0
            alert.transform = CGAffineTransform(translationX: 0, y: -100)
            
            // Haptic Feedback
            let generator = UINotificationFeedbackGenerator()
            switch type {
            case .success: generator.notificationOccurred(.success)
            case .warning: generator.notificationOccurred(.warning)
            case .error: generator.notificationOccurred(.error)
            }
            
            // Slide in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,options: .curveEaseOut) {
                alert.alpha = 1
                alert.transform = .identity
            }
            
            // Auto dismiss schedule
            alert.dismissWorkItem = DispatchWorkItem { [weak alert] in
                alert?.dismissAlert()
            }
            if let workItem = alert.dismissWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
            }
        }
    }
    
    @objc private func dismissAlert() {
        dismissWorkItem?.cancel()
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -100)
        }) { _ in
            self.removeFromSuperview()
        }
    }

}
