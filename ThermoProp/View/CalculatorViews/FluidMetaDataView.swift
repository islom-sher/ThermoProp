//
//  ThermodynamicsResultsView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/8/26.
//

import UIKit

class FluidMetaDataView: UIView {
    
    private var characteristicsData: [CharacteristicItem] = []
    
//MARK: - The view card components -
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .left
        label.text = "FLUID CHARACTERISTICS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var characteristicsCollectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = .zero
        
        let cv = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
// MARK: - init -
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
// MARK: - Setup the components -
    private func setupView() {
        self.characteristicsCollectionView.allowsSelection = false
        
        backgroundColor = .cardBackground
        layer.cornerRadius = 12
        self.setDynamicBorder(color: .cardBorder, width: 1)
        
        characteristicsCollectionView.delegate = self
        characteristicsCollectionView.dataSource = self
        characteristicsCollectionView.register(MetaDataCardCell.self, forCellWithReuseIdentifier: MetaDataCardCell.identifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.4
        characteristicsCollectionView.addGestureRecognizer(longPressGesture)
        
        let contentStack = UIStackView(arrangedSubviews: [headerLabel, characteristicsCollectionView])
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
//        if #available(iOS 17.0, *) {
//            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: ThermodynamicsResultsView, previousTraitCollection) in
//                view.layer.borderColor = UIColor.cardBorder.cgColor
//            }
//        }
    }
    
    // MARK: - Public Data Injector -
    func updateData(_ items: [CharacteristicItem]) {
        self.characteristicsData = items
        DispatchQueue.main.async {
            self.characteristicsCollectionView.reloadData()
        }
    }
    
    // MARK: - Interaction & Animation Logic -
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let touchPoint = gesture.location(in: characteristicsCollectionView)
        
        if let indexPath = characteristicsCollectionView.indexPathForItem(at: touchPoint) {
            let tappedCharacteristic = characteristicsData[indexPath.item]
            
            UIPasteboard.general.string = tappedCharacteristic.value
            print("DEBUG: Direct copied \(tappedCharacteristic.value) from long press")
            
            let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred()
            
            if let cell = characteristicsCollectionView.cellForItem(at: indexPath) as? MetaDataCardCell {
                performCopyFlashAnimation(on: cell)
            }
        }
    }
    
    private func performCopyFlashAnimation(on cell: MetaDataCardCell) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            cell.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            cell.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                cell.transform = .identity
                cell.alpha = 1.0
            }, completion: nil)
        }
    }
}

// MARK: - CollectionView Protocols -
extension FluidMetaDataView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // UICollectionView numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characteristicsData.count
    }
    
    // UICollectionView cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetaDataCardCell.identifier, for: indexPath) as? MetaDataCardCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: characteristicsData[indexPath.item])
        return cell
    }
    
    // UICollectionView didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MetaDataCardCell {
            performCopyFlashAnimation(on: cell)
            let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 2
        return CGSize(width: width, height: 65)
    }
}


// MARK: - Public Configuration -
class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
    
}
