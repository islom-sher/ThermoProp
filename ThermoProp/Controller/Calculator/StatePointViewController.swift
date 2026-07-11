//
//  StatePointViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/22/26.
//

import UIKit

class StatePointViewController: UIViewController {
    
    var fluidName: String = "Water"
    
    private var isCurrentResultSaved: Bool = false
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModeSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["Themodynamic", "Transport"])
        sc.selectedSegmentIndex = 0
        sc.isHidden = true
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let inputCard = ExpandableStatePointInputCard()
    private let resultsGrid = TableGrid()
    private let emptyStateView = EmptyStateView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.menu = createOptionsMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "State point"
        view.backgroundColor = .appBackground
        subtitleLabel.text = "\(fluidName)"
        
        inputCard.delegate = self
        
        setupLayout()
        updateUnits()
        setupTapToDismissKeyboard()
        setupKeyboardObservers()
        
        viewModeSegment.addTarget(self, action: #selector(refreshGrid), for: .valueChanged)
        inputCard.firstSegment.addTarget(self, action: #selector(updateUnits), for: .valueChanged)
        inputCard.secondSegment.addTarget(self, action: #selector(updateUnits), for: .valueChanged)
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: createOptionsMenu())
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func setupLayout() {
        view.addSubview(subtitleLabel)
        view.addSubview(viewModeSegment)
        view.addSubview(resultsGrid)
        view.addSubview(inputCard)
        view.addSubview(emptyStateView)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        viewModeSegment.translatesAutoresizingMaskIntoConstraints = false
        resultsGrid.translatesAutoresizingMaskIntoConstraints = false
        inputCard.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        resultsGrid.isHidden = true
        viewModeSegment.isHidden = true
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: inputCard.topAnchor),
            
            viewModeSegment.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            viewModeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            viewModeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            viewModeSegment.heightAnchor.constraint(equalToConstant: 32),
            
            resultsGrid.topAnchor.constraint(equalTo: viewModeSegment.bottomAnchor, constant: 16),
            resultsGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultsGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultsGrid.bottomAnchor.constraint(lessThanOrEqualTo: inputCard.topAnchor, constant: -16),
            
            inputCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputCard.trailingAnchor.constraint(equalTo: view.trailingAnchor,  constant: -16),
            inputCard.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
        
        emptyStateView.configure(message: "Calculate the state of the chosen fluid at exact point by entering two known parameters")
    }
    
    @objc private func refreshGrid() {
        let coreHeaders = [
            "T\n(\(SettingsManager.shared.temperature.rawValue))", "P\n(\(SettingsManager.shared.pressure.rawValue))",
            "ρ\n(\(SettingsManager.shared.density.rawValue))", "u\n(\(SettingsManager.shared.enthalpy.rawValue))",
            "h\n(\(SettingsManager.shared.enthalpy.rawValue))", "s\n(\(SettingsManager.shared.entropy.rawValue))",
            "Cp\n(\(SettingsManager.shared.entropy.rawValue))", "Cv\n(\(SettingsManager.shared.entropy.rawValue))",
            "State\n(Q)"
        ]
        
        let transportHeaders = [
            "k\n(W/m·K)", "μ\n(Pa·s)", "ν\n(m²/s)", "Pr\n(-)", "σ\n(N/m)", "State\n(Q)"
        ]
        
        let isCore = viewModeSegment.selectedSegmentIndex == 0
        let headers = isCore ? coreHeaders : transportHeaders
        let rows = isCore ? SessionDataManager.shared.statePointCoreRows : SessionDataManager.shared.statePointTransportRows
        
        resultsGrid.updateData(headers: headers, rows: rows)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc private func updateUnits() {
        func getUnit(for index: Int) -> String {
            switch index {
            case 0: return SettingsManager.shared.temperature.rawValue
            case 1: return SettingsManager.shared.pressure.rawValue
            case 2: return SettingsManager.shared.density.rawValue
            case 3, 4: return SettingsManager.shared.enthalpy.rawValue
            case 5: return ""
            default: return ""
            }
        }
        
        let unit1 = getUnit(for: inputCard.firstSegment.selectedSegmentIndex)
        let unit2 = getUnit(for: inputCard.secondSegment.selectedSegmentIndex)
        
        inputCard.updateUnits(firstUnit: unit1, secondUnit: unit2)
    }
    
    @objc private func clearTable() {
        
        SessionDataManager.shared.statePointCoreRows.removeAll()
        SessionDataManager.shared.statePointTransportRows.removeAll()
        
        resultsGrid.isHidden = true
        viewModeSegment.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func saveToHistory() {
        guard !isCurrentResultSaved else {
            CustomAlertView.show(type: .warning, title: "Already Saved", message: "This result is already in your history")
            return
        }
        
        guard let text1 = inputCard.firstInputField.textField.text,
              let text2 = inputCard.secondInputField.textField.text,
              let latestRow = SessionDataManager.shared.statePointCoreRows.last else {
            CustomAlertView.show(type: .error, title: "Save Failed", message: "Please calculate a valid process before saving")
            return
        }
        
        let index1 = inputCard.firstSegment.selectedSegmentIndex
        let index2 = inputCard.secondSegment.selectedSegmentIndex
        
        let symbols = ["T", "P", "ρ", "h", "s", "Q"]
        let key1 = symbols[index1]
        let key2 = symbols[index2]
        
        func getUnit(for index: Int) -> String {
            switch index {
            case 0: return SettingsManager.shared.temperature.rawValue
            case 1: return SettingsManager.shared.pressure.rawValue
            case 2: return SettingsManager.shared.density.rawValue
            case 3, 4: return SettingsManager.shared.enthalpy.rawValue
            case 5: return ""
            default: return ""
            }
        }
        
        let unit1 = getUnit(for: index1)
        let unit2 = getUnit(for: index2)
        
        let param1Str = "\(key1) = \(text1)\(unit1.isEmpty ? "" : " \(unit1)")"
        let param2Str = "\(key2) = \(text2)\(unit2.isEmpty ? "" : " \(unit2)")"
        
        let coreHeaders = [
            "T\n(\(SettingsManager.shared.temperature.rawValue))", "P\n(\(SettingsManager.shared.pressure.rawValue))",
            "ρ\n(\(SettingsManager.shared.density.rawValue))", "u\n(\(SettingsManager.shared.enthalpy.rawValue))",
            "h\n(\(SettingsManager.shared.enthalpy.rawValue))", "s\n(\(SettingsManager.shared.entropy.rawValue))",
            "Cp\n(\(SettingsManager.shared.entropy.rawValue))", "Cv\n(\(SettingsManager.shared.entropy.rawValue))", "State\n(Q)"
        ]
                
        let transportHeaders = [
            "k\n(W/m·K)", "μ\n(Pa·s)", "ν\n(m²/s)", "Pr\n(-)", "σ\n(N/m)", "State\n(Q)"
        ]
        
        let newRecord = HistoryRecord(
            category: .statePoint,
            fluidName: self.fluidName,
            param1: param1Str,
            param2: param2Str,
            headers: coreHeaders,
            rows: SessionDataManager.shared.statePointCoreRows,
            transportHeaders: transportHeaders,
            transportRows: SessionDataManager.shared.statePointTransportRows
        )
        
        SwiftDataManager.shared.saveRecord(newRecord)
        isCurrentResultSaved = true
        
        if !SettingsManager.shared.autoSaveEnabled {
            CustomAlertView.show(type: .success, title: "Success", message: "Results saved successfully")
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
//        CustomAlertView.show(type: .success, title: "Success", message: "Modifications saved successfully")
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: - Navigation Menu Options
    private enum ExportFormat { case pdf, csv }
    
    private func createOptionsMenu() -> UIMenu {
        let pdfAction = UIAction(title: "Export as .pdf", image: UIImage(systemName: "doc.text")) { [weak self] _ in
            self?.handleExport(format: .pdf)
        }
        
        let csvAction = UIAction(title: "Export as .csv", image: UIImage(systemName: "tablecells")) { [weak self] _ in
            self?.handleExport(format: .csv)
        }
   
        let clearAction = UIAction(title: "Clear table", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.clearTable()
        }
        
        var children: [UIMenuElement] = [pdfAction, csvAction]
                
            if !SettingsManager.shared.autoSaveEnabled {
                let saveAction = UIAction(title: "Save to history", image: UIImage(systemName: "clock.arrow.circlepath")) { [weak self] _ in
                self?.saveToHistory()
            }
            children.append(saveAction)
        }
        children.append(clearAction)
        
        return UIMenu(title: "", children: children)
    }
    
    private func handleExport(format: ExportFormat) {
        let coreHeaders = [
            "T\n(\(SettingsManager.shared.temperature.rawValue))", "P\n(\(SettingsManager.shared.pressure.rawValue))",
            "ρ\n(\(SettingsManager.shared.density.rawValue))", "u\n(\(SettingsManager.shared.enthalpy.rawValue))",
            "h\n(\(SettingsManager.shared.enthalpy.rawValue))", "s\n(\(SettingsManager.shared.entropy.rawValue))",
            "Cp\n(\(SettingsManager.shared.entropy.rawValue))", "Cv\n(\(SettingsManager.shared.entropy.rawValue))",
            "State\n(Q)"
        ]
        
        let transportHeaders = [
            "k\n(W/m·K)", "μ\n(Pa·s)", "ν\n(m²/s)", "Pr\n(-)", "σ\n(N/m)", "State\n(Q)"
        ]
        
        let transportRows = SessionDataManager.shared.statePointTransportRows
        let coreRows = SessionDataManager.shared.statePointCoreRows
        let tableName = "State Point Table"
        
        guard !coreHeaders.isEmpty, !coreRows.isEmpty else { return }
        
        if format == .pdf {
            DataExportManager.shared.exportAsPDF(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        } else {
            DataExportManager.shared.exportAsCSV(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        }
    }
    
    func applyPrefill(index1: Int, val1: String, index2: Int, val2: String) {
        _ = self.view
        inputCard.firstSegment.selectedSegmentIndex = index1
        inputCard.firstInputField.textField.text = val1
        inputCard.secondSegment.selectedSegmentIndex = index2
        inputCard.secondInputField.textField.text = val2
        updateUnits()
    }
    
    // MARK: - Keyboard Animations
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @objc private func keyboardWillShow() {
        // Fade out the empty state smoothly when the keyboard rises
        UIView.animate(withDuration: 0.3) {
            self.emptyStateView.alpha = 0
        }
    }
    
    @objc private func keyboardWillHide() {
        // Only fade it back in if the user hasn't generated a table yet
        if self.resultsGrid.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.emptyStateView.alpha = 1
            }
        }
    }
}

extension StatePointViewController: StatePointInputCardDelegate {
    
    func statePointCard(_ card: ExpandableStatePointInputCard, didTapCalculateWith val1: String?, val2: String?) {
        guard let text1 = val1, let value1 = Double(text1),
                let text2 = val2, let value2 = Double(text2) else { return }
        
        view.endEditing(true)
        card.calculateButton.setLoadingState(isCalculating: true, defaultTitle: "Calculate State")
        
        let keys = ["T", "P", "D", "H", "S", "Q"]
        let key1 = keys[card.firstSegment.selectedSegmentIndex]
        let key2 = keys[card.secondSegment.selectedSegmentIndex]
        
        func toSI(val: Double, key: String) -> Double {
            switch key {
            case "T": return SettingsManager.shared.temperature.toBaseSI(value: val)
            case "P": return SettingsManager.shared.pressure.toBaseSI(value: val)
            case "D": return SettingsManager.shared.density.toBaseSI(value: val)
            case "H": return SettingsManager.shared.enthalpy.toBaseSI(value: val)
            case "S": return SettingsManager.shared.entropy.toBaseSI(value: val)
            case "Q": return val
            default: return val
            }
        }
        
        let siVal1 = toSI(val: value1, key: key1)
        let siVal2 = toSI(val: value2, key: key2)
            
        StatePointCalculator.fetchCorePropertiesAsync(
            fluidName: self.fluidName,
            key1: key1,
            siVal1: siVal1,
            key2: key2,
            siVal2: siVal2
        ) { [weak self] (success, coreHeaders, coreRow, density) in
            guard let self = self else { return }
            
            if success, let safeDensity = density {
                let currentPhase = coreRow[8]
                
                StatePointCalculator.fetchTransportPropertiesAsync(
                    fluidName: self.fluidName, key1: key1, siVal1: siVal1, key2: key2, siVal2: siVal2, density:safeDensity, phaseStr: currentPhase
                ) { (transportHeaders, transportRow) in
                    
                    SessionDataManager.shared.statePointCoreRows.append(coreRow)
                    self.isCurrentResultSaved = false
                    
                    let phaseCol = coreRow[8]
                    let fullTransportRow = transportRow + [phaseCol]
                    
                    SessionDataManager.shared.statePointTransportRows.append(fullTransportRow)
                    
                    self.emptyStateView.isHidden = true
                    self.viewModeSegment.isHidden = false
                    self.resultsGrid.isHidden = false
                    
                    self.refreshGrid()
                    
                    if SettingsManager.shared.autoSaveEnabled {
                        self.saveToHistory()
                    }
                
                    card.setCollapsed(true, animated: true)
                    card.calculateButton.setLoadingState(isCalculating: false, defaultTitle: "Calculate State")
                    UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                }
                
            } else {
                card.calculateButton.setLoadingState(isCalculating: false, defaultTitle: "Calculate State")
                let alert = UIAlertController(
                    title: "Calculation Failed",
                    message: "The combination of inputs provided is either physically impossible or outside thevalid calculation range for \(self.fluidName).",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func statePointCard(_ card: ExpandableStatePointInputCard, didChangeExpansionState isCollapsed: Bool) {
        if isCollapsed {
            // Ensure keyboard is dropped if the user manually swipes the card down
            view.endEditing(true)
        }
    }
    
    
}
