//
//  HistoryIsolatedGrid.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/28/26.
//

import UIKit

class TableGrid: UIView {

    private var currentRecord: HistoryRecord?
    private var headers: [String] = []
    private var rows: [[String]] = []
    
    private var currentGridWidth: CGFloat = 1100
    private var dynamicWidthConstraint: NSLayoutConstraint?
    private var dynamicHeightConstraint: NSLayoutConstraint?
    
    var onScrollStateChanged: ((CGFloat) -> Void)?
    private var lastScrollY: CGFloat = 0
    
    private let horizontalScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .cardBackground
        sv.layer.cornerRadius = 12
        sv.setDynamicBorder(color: .cardBorder)

        sv.clipsToBounds = true
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = .zero
        layout.sectionHeadersPinToVisibleBounds = true
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.clipsToBounds = true
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(GridRowCell.self, forCellWithReuseIdentifier: GridRowCell.identifier)
        cv.register(GridRowCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GridHeader")
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        
        addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(contentContainer)
        contentContainer.addSubview(collectionView)
        
        dynamicWidthConstraint = contentContainer.widthAnchor.constraint(equalToConstant: currentGridWidth)
        dynamicHeightConstraint = self.heightAnchor.constraint(equalToConstant: 100)
        dynamicHeightConstraint?.priority = .defaultHigh
        dynamicHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            horizontalScrollView.topAnchor.constraint(equalTo: topAnchor),
            horizontalScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            horizontalScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: horizontalScrollView.contentLayoutGuide.trailingAnchor),
            contentContainer.heightAnchor.constraint(equalTo: horizontalScrollView.frameLayoutGuide.heightAnchor),
            dynamicWidthConstraint!,
            
            collectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
    
    func updateData(headers: [String], rows: [[String]]) {
        self.headers = headers
        self.rows = rows

        let idealColumnWidth = adaptiveSize(phone: 100, pad: 122)
        let calculatedWidth = CGFloat(headers.count) * idealColumnWidth
        let activeWindowWidth = self.window?.bounds.width ?? 1000
        let availableScreenWidth = activeWindowWidth - 32
        
        currentGridWidth = max(calculatedWidth, availableScreenWidth)
        dynamicWidthConstraint?.constant = currentGridWidth
        
        let headerHeight = adaptiveSize(phone: 40, pad: 55)
        let rowHeight = adaptiveSize(phone: 25, pad: 35)
        let calculatedHeight = headerHeight + (CGFloat(rows.count) * rowHeight)
        
        dynamicHeightConstraint?.constant = calculatedHeight
        
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
    }
    
    func updateData(record: HistoryRecord, isThermodynamic: Bool = true) {
        self.currentRecord = record
            
        let extractedHeaders = isThermodynamic ? (record.headers ?? []) : (record.transportHeaders ?? record.headers ?? [])
        let extractedRows = isThermodynamic ? (record.rows ?? []) : (record.transportRows ?? record.rows ?? [])
        
        self.updateData(headers: extractedHeaders, rows: extractedRows)
    }
}

// MARK: - Collection View Setup
extension TableGrid: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HistoryHeaderDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows.count
    }
    
    // MARK: - Header Setup
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: currentGridWidth, height: adaptiveSize(phone: 40, pad: 55))
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GridHeader", for: indexPath) as! GridRowCell
            
            header.configure(with: headers, isHeader: true)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - Rows Setup
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridRowCell.identifier, for: indexPath) as! GridRowCell
        cell.configure(with: rows[indexPath.row], isHeader: false)
        if indexPath.row == rows.count - 1 {
            cell.separator.isHidden = true
        }
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: currentGridWidth, height: adaptiveSize(phone: 25, pad: 35))

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
        
    // MARK: - Delegate Actions
    
    // Segmented Control Action
    func didChangeViewMode(isThermodynamic: Bool) {
        guard let record = currentRecord else { return }
        updateData(record: record, isThermodynamic: isThermodynamic)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // Scroll Animation Callback
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentScrollY = scrollView.contentOffset.y
        let scrollDiff = currentScrollY - lastScrollY
        if currentScrollY > 0 && currentScrollY < (scrollView.contentSize.height - scrollView.bounds.height) {
            onScrollStateChanged?(scrollDiff)
        }
        lastScrollY = currentScrollY
    }
}
