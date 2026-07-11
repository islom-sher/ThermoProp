//
//  ExpandableIsoProcessInputCard.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/2/26.
//

import UIKit

protocol IsoProcessInputCardDelegate: AnyObject {
    func isoProcessCard(_ card: ExpandableIsoProcessInputCard, didTapCalculateWith fixedVal: String?, fromVal: String?, toVal: String?, stepVal: String?)
    func isoProcessCard(_ card: ExpandableIsoProcessInputCard, didChangeExpansionState isCollapsed: Bool)
}

class ExpandableIsoProcessInputCard: UIView {
    
    weak var delegate: IsoProcessInputCardDelegate?

    private(set) var isCollapsed: Bool = false {
        didSet { updateLayoutForState(animated: true) }
    }

    // MARK: - UI Components
    private let dragHandle: UIView = {
        let handle = UIView()
        handle.backgroundColor = .tertiaryLabel
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()

    let fixedCard = IsoFixedInputCard()
    let iteratedCard = IsoIteratedInputCard()

    let calculateButton = CalculateButton(title: "Calculate Process", iconName: "chart.xyaxis.line", style: .primary)

    private let collapsedSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()

    // MARK: - Constraints
    private var expandedConstraints: [NSLayoutConstraint] = []
    private var collapsedConstraints: [NSLayoutConstraint] = []

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGesture()
        syncCards()

        fixedCard.segmentControl.addTarget(self, action: #selector(syncCards), for: .valueChanged)
        calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    private func setupLayout() {
        backgroundColor = .clear

        fixedCard.translatesAutoresizingMaskIntoConstraints = false
        iteratedCard.translatesAutoresizingMaskIntoConstraints = false
        calculateButton.translatesAutoresizingMaskIntoConstraints = false

        fixedCard.layer.zPosition = 0
        iteratedCard.layer.zPosition = 1
        collapsedSummaryLabel.layer.zPosition = 2

        fixedCard.layer.shadowColor = UIColor.black.cgColor
        fixedCard.layer.shadowOpacity = 0.08
        fixedCard.layer.shadowRadius = 8
        fixedCard.layer.shadowOffset = CGSize(width: 0, height: 4)

        iteratedCard.layer.shadowColor = UIColor.black.cgColor
        iteratedCard.layer.shadowOpacity = 0.12
        iteratedCard.layer.shadowRadius = 12
        iteratedCard.layer.shadowOffset = CGSize(width: 0, height: 6)

        addSubview(dragHandle)
        addSubview(fixedCard)
        addSubview(iteratedCard)
        addSubview(calculateButton)
        addSubview(collapsedSummaryLabel)
        
        fixedCard.valueField.accessibilityIdentifier = "IsoFixedInput"
        iteratedCard.fromInput.textField.accessibilityIdentifier = "IsoFromInput"
        iteratedCard.toInput.textField.accessibilityIdentifier = "IsoToInput"
        iteratedCard.stepInput.textField.accessibilityIdentifier = "IsoStepInput"

        NSLayoutConstraint.activate([
            dragHandle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dragHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            dragHandle.widthAnchor.constraint(equalToConstant: 40),
            dragHandle.heightAnchor.constraint(equalToConstant: 5),
        ])

        expandedConstraints = [
            fixedCard.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 4),
            fixedCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            fixedCard.trailingAnchor.constraint(equalTo: trailingAnchor),

            iteratedCard.topAnchor.constraint(equalTo: fixedCard.bottomAnchor, constant: 16),
            iteratedCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            iteratedCard.trailingAnchor.constraint(equalTo: trailingAnchor),

            calculateButton.topAnchor.constraint(equalTo: iteratedCard.bottomAnchor, constant: 20),
            calculateButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            calculateButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            calculateButton.heightAnchor.constraint(equalToConstant: 50),
            calculateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ]
            
        collapsedConstraints = [
            fixedCard.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 4),
            fixedCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            fixedCard.trailingAnchor.constraint(equalTo: trailingAnchor),
//            fixedCard.heightAnchor.constraint(equalToConstant: 120),

            iteratedCard.topAnchor.constraint(equalTo: fixedCard.topAnchor, constant: 35),
            iteratedCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            iteratedCard.trailingAnchor.constraint(equalTo: trailingAnchor),
//            iteratedCard.heightAnchor.constraint(equalToConstant: 80),
            iteratedCard.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            collapsedSummaryLabel.topAnchor.constraint(equalTo: iteratedCard.topAnchor, constant: 16),
            collapsedSummaryLabel.leadingAnchor.constraint(equalTo: iteratedCard.leadingAnchor, constant: 16),
            collapsedSummaryLabel.trailingAnchor.constraint(equalTo: iteratedCard.trailingAnchor, constant: -16),
            collapsedSummaryLabel.bottomAnchor.constraint(equalTo: iteratedCard.bottomAnchor, constant: -20)
        ]

        NSLayoutConstraint.activate(expandedConstraints)
    }
    
    @objc private func syncCards() {
        let fixedIndex = fixedCard.segmentControl.selectedSegmentIndex
        let fixedModels = IsoProcessModel.allCases
        let selectedFixed = fixedModels[fixedIndex]

        // Safely grab the currently iterating parameter BEFORE we refresh the segments
        var currentlyIterating: IsoProcessModel? = nil
        let currentIndex = iteratedCard.segmentControl.selectedSegmentIndex
            
        if currentIndex >= 0 && currentIndex < iteratedCard.currentDisplayedParams.count {
            currentlyIterating = iteratedCard.currentDisplayedParams[currentIndex]
        }

        // Update the segments
        iteratedCard.updateSegments(excluding: selectedFixed)
        
        // Restore the selection safely
        if let oldParam = currentlyIterating, oldParam != selectedFixed, let newIndex = iteratedCard.currentDisplayedParams.firstIndex(of: oldParam) {
            iteratedCard.segmentControl.selectedSegmentIndex = newIndex
        } else {
            iteratedCard.segmentControl.selectedSegmentIndex = 0
        }
        
        // Ensure UI updates if the user changes segments while typing
        if isCollapsed { updateSummaryLabelText() }
    }
    
    // MARK: - Gestures
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handleCardTap() {
        if isCollapsed {
            setCollapsed(false, animated: true)
            delegate?.isoProcessCard(self, didChangeExpansionState: false)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .ended, .cancelled:
            if isCollapsed {
                if velocity.y < -300 || translation.y < -40 {
                    setCollapsed(false, animated: true)
                    delegate?.isoProcessCard(self, didChangeExpansionState: false)
                }
            } else {
                if velocity.y > 300 || translation.y > 40 {
                    setCollapsed(true, animated: true)
                    delegate?.isoProcessCard(self, didChangeExpansionState: true)
                }
            }
        default: break
        }
    }
    
    @objc private func calculateTapped() {
        delegate?.isoProcessCard(self,
            didTapCalculateWith: fixedCard.valueField.text,
            fromVal: iteratedCard.fromInput.textField.text,
            toVal: iteratedCard.toInput.textField.text,
            stepVal: iteratedCard.stepInput.textField.text
        )
    }
    
    // MARK: - State Animations
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
            // Top card scales slightly down creating the 3D depth effect
            self.fixedCard.transform = self.isCollapsed ? CGAffineTransform(scaleX: 0.94, y: 0.94) : .identity

            // Fade out the internal elements so the Headers remain visible!
            self.fixedCard.lockedContainer.alpha = self.isCollapsed ? 0 : 1
            self.fixedCard.segmentControl.alpha = self.isCollapsed ? 0 : 1
            
            self.iteratedCard.segmentControl.alpha = self.isCollapsed ? 0 : 1
            self.iteratedCard.fromInput.alpha = self.isCollapsed ? 0 : 1
            self.iteratedCard.toInput.alpha = self.isCollapsed ? 0 : 1
            self.iteratedCard.stepInput.alpha = self.isCollapsed ? 0 : 1

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
    
    private func updateSummaryLabelText() {
        let fixedIndex = fixedCard.segmentControl.selectedSegmentIndex
        let fixedSymbol = IsoProcessModel.allCases[fixedIndex].symbol
        let fixedUnit = fixedCard.unitLabel.text ?? ""
        let fixedVal = fixedCard.valueField.text ?? "?"

        let iteratedIndex = iteratedCard.segmentControl.selectedSegmentIndex
        guard iteratedIndex >= 0 && iteratedIndex < iteratedCard.currentDisplayedParams.count else { return }
        
        let iteratedSymbol = iteratedCard.currentDisplayedParams[iteratedIndex].symbol
        let iteratedUnit = iteratedCard.fromInput.unitLabel.text ?? ""
        let fromVal = iteratedCard.fromInput.textField.text ?? "?"
        let toVal = iteratedCard.toInput.textField.text ?? "?"
        let stepVal = iteratedCard.stepInput.textField.text ?? "?"

        let plainText = "\(fixedSymbol) fixed at \(fixedVal) \(fixedUnit)\nIterating \(iteratedSymbol): \(fromVal) → \(toVal) \(iteratedUnit) (step \(stepVal))"

        let attributedString = NSMutableAttributedString(
            string: plainText,
            attributes: [.font: UIFont.sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .medium), .foregroundColor: UIColor.label])

        collapsedSummaryLabel.attributedText = attributedString
    }
    
    // MARK: - Helpers
    func updateUnits(fixedUnit: String, iteratedUnit: String) {
        fixedCard.unitLabel.text = fixedUnit
        iteratedCard.fromInput.unitLabel.text = iteratedUnit
        iteratedCard.toInput.unitLabel.text = iteratedUnit
        iteratedCard.stepInput.unitLabel.text = iteratedUnit
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
