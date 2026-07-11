//
//  ExpandableStatePointInputCard.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/2/26.
//

import UIKit

protocol StatePointInputCardDelegate: AnyObject {
    func statePointCard(_ card: ExpandableStatePointInputCard, didTapCalculateWith val1: String?, val2: String?)
    func statePointCard(_ card: ExpandableStatePointInputCard, didChangeExpansionState isCollapsed: Bool)
}

class ExpandableStatePointInputCard: UIView {

    weak var delegate: StatePointInputCardDelegate?
    let parameters = ["T", "P", "ρ", "h", "s", "Q"]
    
    private(set) var isCollapsed: Bool = false {
        didSet {
            updateLayoutForState(animated: true)
        }
    }
    
    // MARK: - UI Components
    private let dragHandle: UIView = {
        let handle = UIView()
        handle.backgroundColor = .tertiaryLabel
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()
    
    private let inputLabel: UILabel = {
        let label = UILabel()
        label.text = "INPUT PAIR"
        label.font = .sfMono(size: adaptiveSize(phone: 13, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let firstSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["T", "P", "ρ", "h", "s", "Q"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let secondSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["T", "P", "ρ", "h", "s", "Q"])
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let firstInputField = InputFieldBox()
    let secondInputField = InputFieldBox()
    
    lazy var segmentsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstSegment, secondSegment])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var inputsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstInputField, secondInputField])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let calculateButton = CalculateButton(title: "Calculate State", iconName: "point.3.filled", style: .primary)
    
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
        syncSegments()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCardLayout()
        setupGesture()
        syncSegments()
    }
    
    // MARK: - Setup
    private func setupCardLayout() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 24
        
        self.setDynamicBorder(color: .cardBorder, width: 1)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: ExpandableStatePointInputCard, _) in
            view.layer.borderColor = UIColor.cardBorder.resolvedColor(with: view.traitCollection).cgColor
        }
        layer.borderColor = UIColor.cardBorder.resolvedColor(with: traitCollection).cgColor
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        calculateButton.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        
        firstSegment.addTarget(self, action: #selector(syncSegments), for: .valueChanged)
        secondSegment.addTarget(self, action: #selector(syncSegments), for: .valueChanged)
        
        addSubview(dragHandle)
        addSubview(inputLabel)
        addSubview(segmentsStackView)
        addSubview(inputsStackView)
        addSubview(calculateButton)
        addSubview(collapsedSummaryLabel)
        
        firstInputField.textField.accessibilityIdentifier = "StatePointInput1"
        secondInputField.textField.accessibilityIdentifier = "StatePointInput2"
        
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
        NSLayoutConstraint.activate([
            dragHandle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dragHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            dragHandle.widthAnchor.constraint(equalToConstant: 40),
            dragHandle.heightAnchor.constraint(equalToConstant: 5),
            
            firstSegment.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
            secondSegment.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
        ])
        
        expandedConstraints = [
            inputLabel.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 16),
            inputLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            segmentsStackView.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 12),
            segmentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            inputsStackView.topAnchor.constraint(equalTo: segmentsStackView.bottomAnchor, constant: 20),
            inputsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            inputsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            calculateButton.topAnchor.constraint(equalTo: inputsStackView.bottomAnchor, constant: 20),
            calculateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            calculateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            calculateButton.heightAnchor.constraint(equalToConstant: 50),
            calculateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ]
        
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
            self.inputLabel.alpha = self.isCollapsed ? 0 : 1
            self.segmentsStackView.alpha = self.isCollapsed ? 0 : 1
            self.inputsStackView.alpha = self.isCollapsed ? 0 : 1
            self.calculateButton.alpha = self.isCollapsed ? 0 : 1
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
                if velocity.y < -300 || translation.y < -40 {
                    self.setCollapsed(false, animated: true)
                    self.delegate?.statePointCard(self, didChangeExpansionState: false)
                }
            } else {
                if velocity.y > 300 || translation.y > 40 {
                    self.setCollapsed(true, animated: true)
                    self.delegate?.statePointCard(self, didChangeExpansionState: true)
                }
            }
        default:
            break
        }
    }
    
    @objc private func handleCardTap() {
        if isCollapsed {
            isCollapsed = false
            delegate?.statePointCard(self, didChangeExpansionState: false)
        }
    }
    
    @objc private func calculateButtonTapped() {
        delegate?.statePointCard(
            self,
            didTapCalculateWith: firstInputField.textField.text,
            val2: secondInputField.textField.text
        )
    }
        
    @objc func syncSegments() {
        let firstIndex = firstSegment.selectedSegmentIndex
        let secondIndex = secondSegment.selectedSegmentIndex
        
        firstInputField.iterationLabel.text = firstSegment.titleForSegment(at: firstIndex)
        secondInputField.iterationLabel.text = secondSegment.titleForSegment(at: secondIndex)
        
        for i in 0..<secondSegment.numberOfSegments {
            secondSegment.setEnabled(i != firstIndex, forSegmentAt: i)
        }
        
        if firstIndex == secondIndex {
            secondSegment.selectedSegmentIndex = (firstIndex == 0) ? 1 : 0
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func updateSummaryLabelText() {
        let key1 = parameters[firstSegment.selectedSegmentIndex]
        let key2 = parameters[secondSegment.selectedSegmentIndex]
        
        let unit1 = firstInputField.unitLabel.text ?? ""
        let unit2 = secondInputField.unitLabel.text ?? ""
        
        let val1 = firstInputField.textField.text ?? "?"
        let val2 = secondInputField.textField.text ?? "?"
        
        let plainText = "\(key1): \(val1) \(unit1)  •  \(key2): \(val2) \(unit2)"
        let attributedString = NSMutableAttributedString(
            string: plainText,
            attributes: [.font: UIFont.sfMono(size: adaptiveSize(phone: 15, pad: 17), weight: .medium), .foregroundColor: UIColor.label]
        )
            
        collapsedSummaryLabel.attributedText = attributedString
    }
        
    func updateUnits(firstUnit: String, secondUnit: String) {
        firstInputField.unitLabel.text = firstUnit
        secondInputField.unitLabel.text = secondUnit
    }
    
    func setCollapsed(_ collapsed: Bool, animated: Bool) {
        guard isCollapsed != collapsed else { return }
        if !animated {
            UIView.performWithoutAnimation {
                isCollapsed = collapsed
            }
        } else {
            isCollapsed = collapsed
        }
    }
}
