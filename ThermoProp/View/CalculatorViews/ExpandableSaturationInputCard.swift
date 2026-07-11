//
//  TestInputCard.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/30/26.
//

import UIKit

protocol SaturationInputCardDelegate: AnyObject {
    func inputCard(_ card: ExpandableSaturationInputCard, didTapGenerateWith from: String?, to: String?, step: String?, isTemperature: Bool)
    func inputCard(_ card: ExpandableSaturationInputCard, didChangeExpansionState isCollapsed: Bool)
}

class ExpandableSaturationInputCard: UIView {

    weak var delegate: SaturationInputCardDelegate?
   
    private(set) var isCollapsed: Bool = false {
        didSet {
            updateLayoutForState(animated: true)
        }
    }
    
    private let dragHandle: UIView = {
        let handle = UIView()
        handle.backgroundColor = .tertiaryLabel
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()
    
    private let parameterTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "INPUT PARAMETER"
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let segmentControl: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["Temperature", "Pressure"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let fromInput = InputFieldBox()
    let toInput = InputFieldBox()
    let stepInput = InputFieldBox()
    
    private lazy var rangeHorizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [fromInput, toInput, stepInput])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let generateButton = CalculateButton(title: "Generate table", iconName: "tablecells", style: .primary)
    
    private let collapsedSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 16, pad: 18), weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    // MARK: - Layout Constraints
        private var expandedConstraints: [NSLayoutConstraint] = []
        private var collapsedConstraints: [NSLayoutConstraint] = []
        
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardLayout()
        setupGesture()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCardLayout()
        setupGesture()
    }
    
    // MARK: - Setup
    private func setupCardLayout() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 24
        
        self.setDynamicBorder(color: .cardBorder, width: 1)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: ExpandableSaturationInputCard, _) in
            view.layer.borderColor = UIColor.cardBorder.resolvedColor(with: view.traitCollection).cgColor
        }
        layer.borderColor = UIColor.cardBorder.resolvedColor(with: traitCollection).cgColor
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        fromInput.iterationLabel.text = "FROM"
        toInput.iterationLabel.text = "TO"
        stepInput.iterationLabel.text = "STEP"
        
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        addSubview(dragHandle)
        addSubview(parameterTitleLabel)
        addSubview(segmentControl)
        addSubview(rangeHorizontalStack)
        addSubview(generateButton)
        addSubview(collapsedSummaryLabel)
        
        fromInput.textField.accessibilityIdentifier = "SaturationFromInput"
        toInput.textField.accessibilityIdentifier = "SaturationToInput"
        stepInput.textField.accessibilityIdentifier = "SaturationStepInput"
        
        setupConstraints()
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(pan)
    }
    
    // MARK: - Auto Layout
    private func setupConstraints() {
        // Shared constraints (always active)
        NSLayoutConstraint.activate([
            dragHandle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dragHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            dragHandle.widthAnchor.constraint(equalToConstant: 40),
            dragHandle.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        // Expanded constraints
        expandedConstraints = [
            parameterTitleLabel.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 16),
            parameterTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            segmentControl.topAnchor.constraint(equalTo: parameterTitleLabel.bottomAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
            
            rangeHorizontalStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            rangeHorizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rangeHorizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            generateButton.topAnchor.constraint(equalTo: rangeHorizontalStack.bottomAnchor, constant: 20),
            generateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            generateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            generateButton.heightAnchor.constraint(equalToConstant: 50),
            generateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ]
        
        // Collapsed constraints
        collapsedConstraints = [
            collapsedSummaryLabel.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 16),
            collapsedSummaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collapsedSummaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collapsedSummaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(expandedConstraints)
    }
    
    // MARK: - Animations
    private func updateLayoutForState(animated: Bool) {
        if isCollapsed {
            NSLayoutConstraint.deactivate(expandedConstraints)
            NSLayoutConstraint.activate(collapsedConstraints)
            updateSummaryLabelText()
        } else {
            NSLayoutConstraint.deactivate(collapsedConstraints)
            NSLayoutConstraint.activate(expandedConstraints)
        }
        
        let animationBlock = {
            self.parameterTitleLabel.alpha = self.isCollapsed ? 0 : 1
            self.segmentControl.alpha = self.isCollapsed ? 0 : 1
            self.rangeHorizontalStack.alpha = self.isCollapsed ? 0 : 1
            self.generateButton.alpha = self.isCollapsed ? 0 : 1
            
            self.collapsedSummaryLabel.alpha = self.isCollapsed ? 1 : 0
            
            self.superview?.layoutIfNeeded()
        }
        
        if animated {
            UISelectionFeedbackGenerator().selectionChanged()
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    // MARK: - Actions & Helpers
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .ended, .cancelled:
            if isCollapsed {
                // Currently collapsed: Listen for UPWARD swipe (negative Y)
                if velocity.y < -300 || translation.y < -40 {
                    self.setCollapsed(false, animated: true)
                    self.delegate?.inputCard(self, didChangeExpansionState: false)
                }
            } else {
                // Currently expanded: Listen for DOWNWARD swipe (positive Y)
                if velocity.y > 300 || translation.y > 40 {
                    self.setCollapsed(true, animated: true)
                    self.delegate?.inputCard(self, didChangeExpansionState: true)
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handleCardTap() {
        if isCollapsed {
            isCollapsed = false
            delegate?.inputCard(self, didChangeExpansionState: false)
        }
    }
    
    @objc private func generateButtonTapped() {
        delegate?.inputCard(
            self,
            didTapGenerateWith: fromInput.textField.text,
            to: toInput.textField.text,
            step: stepInput.textField.text,
            isTemperature: segmentControl.selectedSegmentIndex == 0
        )
    }
        
    @objc private func segmentChanged() {
        // Will be handled by the VC to update units
    }
    
    private func updateSummaryLabelText() {
        let isTemp = segmentControl.selectedSegmentIndex == 0
        let symbol = isTemp ? "T" : "P"
        let unit = fromInput.unitLabel.text ?? ""
        
        let fromVal = fromInput.textField.text ?? "?"
        let toVal = toInput.textField.text ?? "?"
        let stepVal = stepInput.textField.text ?? "?"
        
        let plainText = "\(symbol): \(fromVal) → \(toVal) \(unit) (step \(stepVal))"
        let attributedString = NSMutableAttributedString(
            string: plainText,
            attributes: [.font: UIFont.sfMono(size: adaptiveSize(phone: 16, pad: 18), weight: .medium), .foregroundColor: UIColor.label]
        )
            
        collapsedSummaryLabel.attributedText = attributedString
    }
    
    func updateUnits(_ unit: String) {
        fromInput.unitLabel.text = unit
        toInput.unitLabel.text = unit
        stepInput.unitLabel.text = unit
    }
    
    func setCollapsed(_ collapsed: Bool, animated: Bool) {
        guard isCollapsed != collapsed else { return }
        if !animated {
            // Temporarily disable the property observer animation if requested
            UIView.performWithoutAnimation {
                isCollapsed = collapsed
            }
        } else {
            isCollapsed = collapsed
        }
    }

}
