//
//  HistoryDetailViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/25/26.
//

import UIKit

class HistoryDetailViewController: UIViewController, HistoryHeaderDelegate {
    
    // MARK: - Data
    var record: HistoryRecord
    
    // MARK: - UI Components
    private let headerView = HistoryHeaderView()
    private let resultsGrid = TableGrid()
    
    // Bottom Buttons
    private let deleteButton = CalculateButton(title: "Delete", iconName: "trash", style: .secondary)
    private let recalculateButton = CalculateButton(title: "Recalculate", iconName: "calculator", style: .primary)
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let floatingContainer: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.borderWidth = 1.2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        
        return view
    }()
    
    
    // MARK: - Initialization
    init(record: HistoryRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: createOptionsMenu())
        navigationItem.rightBarButtonItem = menuButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        headerView.delegate = self
        headerView.configure(with: record)
        
        setupLayout()
        setupActions()
        
        resultsGrid.updateData(record: record, isThermodynamic: true)
    }
    
    // MARK: - Setup
    private func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(resultsGrid)
        
        view.addSubview(floatingContainer)
        floatingContainer.contentView.addSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(deleteButton)
        buttonsStack.addArrangedSubview(recalculateButton)
        
        headerView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            resultsGrid.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            resultsGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsGrid.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            floatingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            floatingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            floatingContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -16),
            
            buttonsStack.topAnchor.constraint(equalTo: floatingContainer.contentView.topAnchor, constant: 8),
            buttonsStack.bottomAnchor.constraint(equalTo: floatingContainer.contentView.bottomAnchor, constant: -8),
            buttonsStack.leadingAnchor.constraint(equalTo: floatingContainer.contentView.leadingAnchor, constant: 8),
            buttonsStack.trailingAnchor.constraint(equalTo: floatingContainer.contentView.trailingAnchor, constant: -8),
            buttonsStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        resultsGrid.onScrollStateChanged = { [weak self] diff in
            self?.animateFloatingButtons(scrollDiff: diff)
        }
    }

    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        recalculateButton.addTarget(self, action: #selector(recalculateTapped), for: .touchUpInside)
    }
    
    // MARK: - Header Delegate
    func didChangeViewMode(isThermodynamic: Bool) {
        resultsGrid.updateData(record: record, isThermodynamic: isThermodynamic)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Animations
    private func animateFloatingButtons(scrollDiff: CGFloat) {
        if scrollDiff > 5 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                
                self.floatingContainer.transform = CGAffineTransform(translationX: 0, y: 120)
                self.floatingContainer.alpha = 0
            }
        } else if scrollDiff < -5 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                self.floatingContainer.transform = .identity
                self.floatingContainer.alpha = 1
            }
        }
    }
    //MARK: - Loading data from storage
    private enum ExportFormat { case pdf, csv }
    private func createOptionsMenu() -> UIMenu {
        let pdfAction = UIAction(title: "Export as .pdf", image: UIImage(systemName: "doc.text")) { [weak self] _ in
            self?.handleExport(format: .pdf)
        }
        
        let csvAction = UIAction(title: "Export as .csv", image: UIImage(systemName: "tablecells")) { [weak self] _ in
            self?.handleExport(format: .csv)
        }
        
        return UIMenu(title: "Export Record", children: [pdfAction, csvAction])
    }
    
    private func handleExport(format: ExportFormat) {
        let tableName: String
        switch record.category {
        case .statePoint: tableName = "State Point Table"
        case .saturation: tableName = "Saturation Table"
        case .isoProcess: tableName = "Iso-Process Table"
        default: tableName = "History Record"
        }
        
        let coreHeaders = record.headers ?? []
        let coreRows = record.rows ?? []
        
        let transportHeaders = record.transportHeaders ?? []
        let transportRows = record.transportRows ?? []
        
        if format == .pdf {
            DataExportManager.shared.exportAsPDF(from: self, fluidName: record.fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        } else {
            DataExportManager.shared.exportAsCSV(from: self, fluidName: record.fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        }
    }
    
    // Delete button interaction
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this calculation from your history? This action cannot be undone.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            SwiftDataManager.shared.deleteRecord(self.record)
            self.navigationController?.popViewController(animated: true)
            CustomAlertView.show(type: .success, title: "Deleted", message: "Record successfully removed from history.")
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    // Recalculation button interaction
    @objc private func recalculateTapped() {
        switch record.category {
        case .statePoint:
            let vc = StatePointViewController()
            vc.fluidName = record.fluidName
            
            let sym1 = extractSymbol(from: record.param1)
            let sym2 = extractSymbol(from: record.param2)
            let vals1 = extractNumbers(from: record.param1)
            let vals2 = extractNumbers(from: record.param2)
            
            let keys = ["T", "P", "ρ", "h", "s", "Q"]
            let idx1 = keys.firstIndex(of: sym1) ?? 0
            let idx2 = keys.firstIndex(of: sym2) ?? 1
            
            vc.applyPrefill(index1: idx1, val1: vals1.first ?? "", index2: idx2, val2: vals2.first ?? "")
            navigationController?.pushViewController(vc, animated: true)
            
        case .isoProcess:
            let vc = IsoProcessViewController()
            vc.fluidName = record.fluidName
            
            let symFixed = extractSymbol(from: record.param1)
            let symIter = extractSymbol(from: record.param2)
            let valsFixed = extractNumbers(from: record.param1)
            let valsIter = extractNumbers(from: record.param2)
            
            vc.applyPrefill(fixedSymbol: symFixed, fixedVal: valsFixed.first ?? "", iteratedSymbol: symIter, fromVal: valsIter.first ?? "", toVal: valsIter.last ?? "")
            navigationController?.pushViewController(vc, animated: true)
            
        case .saturation:
            let vc = SaturationTableViewConroller()
            vc.fluidName = record.fluidName
            
            let sym = extractSymbol(from: record.param1)
            let isTemp = (sym == "T")
            let vals1 = extractNumbers(from: record.param1)
            let vals2 = extractNumbers(from: record.param2)
            
            vc.applyPrefill(isTemp: isTemp, fromVal: vals1.first ?? "", toVal: vals1.last ?? "", stepVal: vals2.first ?? "")
            navigationController?.pushViewController(vc, animated: true)
            
        default: break
        }
    }
    
    // MARK: - Parsing Helpers
    private func extractNumbers(from text: String) -> [String] {
        let pattern = "[-+]?[0-9]*\\.?[0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range) }
    }
    
    private func extractSymbol(from text: String) -> String {
        return text.components(separatedBy: .whitespaces).first?.replacingOccurrences(of: ":", with: "") ?? ""
    }
}
