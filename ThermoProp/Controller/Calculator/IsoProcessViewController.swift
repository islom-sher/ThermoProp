//
//  IsopropertyTableViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import UIKit

class IsoProcessViewController: UIViewController {
    
    var fluidName: String = "Water"
    
    private var isCurrentResultSaved: Bool = false
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .bold)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModeSegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["Thermodynamic", "Transport"])
        sc.selectedSegmentIndex = 0
        sc.isHidden = true
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let inputCard = ExpandableIsoProcessInputCard()
    private let resultsGrid = TableGrid()
    private let emptyStateView = EmptyStateView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems?.first?.menu = createOptionsMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Iso-process table"
        view.backgroundColor = .appBackground
        inputCard.delegate = self
        
        setupLayout()
        configureInitialState()
        setupTapToDismissKeyboard()
        setupKeyboardObservers()
        
        viewModeSegment.addTarget(self, action: #selector(refreshGrid), for: .valueChanged)
        inputCard.fixedCard.segmentControl.addTarget(self, action: #selector(updateUIState), for: .valueChanged)
        inputCard.iteratedCard.segmentControl.addTarget(self, action: #selector(updateUIState), for: .valueChanged)
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: createOptionsMenu())
        navigationItem.rightBarButtonItems = [menuButton]
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
        resultsTitleLabel.isHidden = true
        viewModeSegment.isHidden = true
        
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
       
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
            
            resultsGrid.topAnchor.constraint(equalTo: viewModeSegment.bottomAnchor, constant: 8),
            resultsGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultsGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultsGrid.bottomAnchor.constraint(lessThanOrEqualTo: inputCard.topAnchor, constant: -16),
            
            inputCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputCard.trailingAnchor.constraint(equalTo: view.trailingAnchor,  constant: -16),
            inputCard.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
        emptyStateView.configure(message: "Iterate through one parameter while other one is fixed at some point")
    }
    
    private func configureInitialState() {
        subtitleLabel.text = fluidName
        
        DispatchQueue.main.async { self.updateUIState() }
    }
    
    @objc private func updateUIState() {
        let fixedIndex = inputCard.fixedCard.segmentControl.selectedSegmentIndex
        let fixedParam = IsoProcessModel.allCases[fixedIndex]
        
        inputCard.fixedCard.titleLabel.text = "\(fixedParam.name) fixed at"
        
        let iteratedIndex = inputCard.iteratedCard.segmentControl.selectedSegmentIndex
        guard iteratedIndex >= 0 && iteratedIndex < inputCard.iteratedCard.currentDisplayedParams.count else { return }
        let iteratedParam = inputCard.iteratedCard.currentDisplayedParams[iteratedIndex]
        
        func getUnit(for param: IsoProcessModel) -> String {
            switch param {
            case .pressure: return SettingsManager.shared.pressure.rawValue
            case .temperature: return SettingsManager.shared.temperature.rawValue
            case .density: return SettingsManager.shared.density.rawValue
            case .enthalpy: return SettingsManager.shared.enthalpy.rawValue
            case .entropy: return SettingsManager.shared.entropy.rawValue
            }
        }
        
        inputCard.updateUnits(fixedUnit: getUnit(for: fixedParam), iteratedUnit: getUnit(for: iteratedParam))
    }
    
    @objc private func refreshGrid() {
        let isCore = viewModeSegment.selectedSegmentIndex == 0
    
        let headers = isCore ? SessionDataManager.shared.isoProcessCoreHeaders : SessionDataManager.shared.isoProcessTransportHeaders
        let rows = isCore ? SessionDataManager.shared.isoProcessCoreRows : SessionDataManager.shared.isoProcessTransportRows
        
        resultsGrid.updateData(headers: headers, rows: rows)
        UISelectionFeedbackGenerator().selectionChanged()
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    @objc private func saveToHistory() {
        guard !isCurrentResultSaved else {
            CustomAlertView.show(type: .warning, title: "Already Saved", message: "This result is already in your history")
            return
        }
        
        guard let constantText = inputCard.fixedCard.valueField.text, !constantText.isEmpty,
              let startText = inputCard.iteratedCard.fromInput.textField.text, !startText.isEmpty,
              let endText = inputCard.iteratedCard.toInput.textField.text, !endText.isEmpty else {
            CustomAlertView.show(type: .error, title: "Save Failed", message: "Please calculate a valid process before saving")
            return
        }
        
        guard let fixedParam = IsoProcessModel(rawValue: inputCard.fixedCard.segmentControl.selectedSegmentIndex) else { return }
        let iteratedIndex = inputCard.iteratedCard.segmentControl.selectedSegmentIndex
        guard iteratedIndex >= 0 && iteratedIndex < inputCard.iteratedCard.currentDisplayedParams.count else { return }
        let iteratedParam = inputCard.iteratedCard.currentDisplayedParams[iteratedIndex]

        func getSymbolAndUnit(for param: IsoProcessModel) -> (symbol: String, unit: String) {
            switch param {
            case .temperature: return ("T", SettingsManager.shared.temperature.rawValue)
            case .pressure: return ("P", SettingsManager.shared.pressure.rawValue)
            case .density: return ("ρ", SettingsManager.shared.density.rawValue)
            case .enthalpy: return ("h", SettingsManager.shared.enthalpy.rawValue)
            case .entropy: return ("s", SettingsManager.shared.entropy.rawValue)
            }
        }
        
        let fixedInfo = getSymbolAndUnit(for: fixedParam)
        let iteratedInfo = getSymbolAndUnit(for: iteratedParam)
        
        let param1Str = "\(fixedInfo.symbol) = \(constantText) \(fixedInfo.unit)"
        let param2Str = "\(iteratedInfo.symbol): \(startText) → \(endText) \(iteratedInfo.unit)"
        
        let newRecord = HistoryRecord(
            category: .isoProcess,
            fluidName: self.fluidName,
            param1: param1Str,
            param2: param2Str,
            headers: SessionDataManager.shared.isoProcessCoreHeaders,
            rows: SessionDataManager.shared.isoProcessCoreRows,
            transportHeaders: SessionDataManager.shared.isoProcessTransportHeaders,
            transportRows: SessionDataManager.shared.isoProcessTransportRows
        )
        
        SwiftDataManager.shared.saveRecord(newRecord)
        isCurrentResultSaved = true
        
        if !SettingsManager.shared.autoSaveEnabled {
            CustomAlertView.show(type: .success, title: "Success", message: "Results saved successfully")
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
//        
//        CustomAlertView.show(type: .success, title: "Success", message: "Results saved successfully")
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
        
        var children: [UIMenuElement] = [pdfAction, csvAction]
        
        if !SettingsManager.shared.autoSaveEnabled {
            let saveAction = UIAction(title: "Save to history", image: UIImage(systemName: "clock.arrow.circlepath")) { [weak self] _ in
                self?.saveToHistory()
            }
            children.append(saveAction)
        }
        
        return UIMenu(title: "", children: children)
    }
    
    private func handleExport(format: ExportFormat) {
        let coreHeaders = SessionDataManager.shared.isoProcessCoreHeaders
        let coreRows = SessionDataManager.shared.isoProcessCoreRows
        let transportHeaders = SessionDataManager.shared.isoProcessTransportHeaders
        let transportRows = SessionDataManager.shared.isoProcessTransportRows
        let tableName = "Iso-Process Table"
            
        guard !coreHeaders.isEmpty, !coreRows.isEmpty else { return }
            
        if format == .pdf {
            DataExportManager.shared.exportAsPDF(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        } else {
            DataExportManager.shared.exportAsCSV(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        }
    }
    
    func applyPrefill(fixedSymbol: String, fixedVal: String, iteratedSymbol: String, fromVal: String, toVal: String) {
        _ = self.view // Force view to load
        
        let fixedKeys = ["P", "T", "ρ", "h", "s"]
        inputCard.fixedCard.segmentControl.selectedSegmentIndex = fixedKeys.firstIndex(of: fixedSymbol) ?? 0
        inputCard.fixedCard.valueField.text = fixedVal
        
        updateUIState()
        
        let iterKeys = inputCard.iteratedCard.currentDisplayedParams.map { param -> String in
            switch param {
            case .temperature: return "T"
            case .pressure: return "P"
            case .density: return "ρ"
            case .enthalpy: return "h"
            case .entropy: return "s"
            }
        }
        inputCard.iteratedCard.segmentControl.selectedSegmentIndex = iterKeys.firstIndex(of: iteratedSymbol) ?? 0
        inputCard.iteratedCard.fromInput.textField.text = fromVal
        inputCard.iteratedCard.toInput.textField.text = toVal
        
        updateUIState()
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

// MARK: - IsoProcessInputCardDelegate
extension IsoProcessViewController: IsoProcessInputCardDelegate {
    
    func isoProcessCard(_ card: ExpandableIsoProcessInputCard, didTapCalculateWith fixedVal: String?, fromVal: String?, toVal: String?, stepVal: String?) {
        
        let safeFixed = fixedVal?.replacingOccurrences(of: ",", with: ".") ?? ""
        let safeFrom = fromVal?.replacingOccurrences(of: ",", with: ".") ?? ""
        let safeTo = toVal?.replacingOccurrences(of: ",", with: ".") ?? ""
        let safeStep = stepVal?.replacingOccurrences(of: ",", with: ".") ?? ""
        
        guard let fVal = Double(safeFixed),
                let startVal = Double(safeFrom),
                let endVal = Double(safeTo),
                let step = Double(safeStep), step > 0 else {

            let alert = UIAlertController(
                title: "Invalid Input",
                message: "Please ensure all fields are filled with valid numbers and the step is greater than 0.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        let fixedIndex = card.fixedCard.segmentControl.selectedSegmentIndex
        let fixedParam = IsoProcessModel.allCases[fixedIndex]
                
        let iteratedIndex = card.iteratedCard.segmentControl.selectedSegmentIndex
        guard iteratedIndex >= 0 && iteratedIndex < card.iteratedCard.currentDisplayedParams.count else { return }
        let iteratedParam = card.iteratedCard.currentDisplayedParams[iteratedIndex]
        
        switch fixedParam {
            case .pressure: resultsTitleLabel.text = "RESULTS — ISOBARIC PROCESS"
            case .temperature: resultsTitleLabel.text = "RESULTS — ISOTHERMAL PROCESS"
            case .density: resultsTitleLabel.text = "RESULTS — ISOCHORIC PROCESS"
            case .enthalpy: resultsTitleLabel.text = "RESULTS — ISENTHALPIC PROCESS"
            case .entropy: resultsTitleLabel.text = "RESULTS — ISENTROPIC PROCESS"
        }
        
        view.endEditing(true)
        card.calculateButton.setLoadingState(isCalculating: true, defaultTitle: "Calculate Process")
        
        IsoProcessCalculator.generateIsoTableAsync(
            fluidName: self.fluidName,
            fixedParam: fixedParam,
            fixedValue: fVal,
            iteratedParam: iteratedParam,
            startValue: startVal,
            endValue: endVal,
            stepValue: step
        ) { [weak self] (coreHeaders, coreRows, transportHeaders, transportRows) in
            guard let self = self else { return }
            
            self.isCurrentResultSaved = false
            
            SessionDataManager.shared.isoProcessCoreHeaders = coreHeaders
            SessionDataManager.shared.isoProcessCoreRows = coreRows
            SessionDataManager.shared.isoProcessTransportHeaders = transportHeaders
            SessionDataManager.shared.isoProcessTransportRows = transportRows
            
            self.emptyStateView.isHidden = true
            self.resultsTitleLabel.isHidden = false
            self.viewModeSegment.isHidden = false
            self.resultsGrid.isHidden = false
            
            self.viewModeSegment.selectedSegmentIndex = 0
            self.refreshGrid()
            
            if SettingsManager.shared.autoSaveEnabled {
                self.saveToHistory()
            }
        
            card.setCollapsed(true, animated: true)
            card.calculateButton.setLoadingState(isCalculating: false, defaultTitle: "Calculate Process")
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        }
    }
    
    func isoProcessCard(_ card: ExpandableIsoProcessInputCard, didChangeExpansionState isCollapsed: Bool) {
        if isCollapsed {
            view.endEditing(true)
        }
    }
}
