//
//  SaturationTableViewConroller.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/16/26.
//

import UIKit
import SwiftUI
import QuickLook

class SaturationTableViewConroller: UIViewController {

    var fluidName: String = "Water"
    private var generatedFileURL: URL?
    private var isCurrentResultSaved: Bool = false
    
    private var lastIsTemp: Bool = true
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
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
    
    private let resultsGrid = TableGrid()
    private let inputCard = ExpandableSaturationInputCard()
    private let generateButton = CalculateButton(title: "Generate table", iconName: "tablecells", style: .primary)
    private let emptyStateView = EmptyStateView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.menu = createOptionsMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saturation table"
        view.backgroundColor = .appBackground
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        
        let edgeAppearance = UINavigationBarAppearance()
        edgeAppearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = edgeAppearance
        definesPresentationContext = true
    
        setupLayout()
        configureInitialState()
        setupTapToDismissKeyboard()
        setupKeyboardObservers()
        
        inputCard.delegate = self
        
        inputCard.segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        viewModeSegment.addTarget(self, action: #selector(refreshGrid), for: .valueChanged)
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: createOptionsMenu())
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func setupLayout() {
        view.addSubview(subtitleLabel)
        view.addSubview(emptyStateView)
        view.addSubview(resultsGrid)
        view.addSubview(viewModeSegment)
        view.addSubview(inputCard)
        
        resultsGrid.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        inputCard.translatesAutoresizingMaskIntoConstraints = false
        viewModeSegment.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        resultsGrid.isHidden = true
        viewModeSegment.isHidden = true
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: inputCard.topAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            viewModeSegment.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            viewModeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            viewModeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            viewModeSegment.heightAnchor.constraint(equalToConstant: 32),
            
            resultsGrid.topAnchor.constraint(equalTo: viewModeSegment.bottomAnchor, constant: 16),
            resultsGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsGrid.bottomAnchor.constraint(lessThanOrEqualTo: inputCard.topAnchor, constant: -16),

            inputCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputCard.trailingAnchor.constraint(equalTo: view.trailingAnchor,  constant: -16),
            inputCard.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
        
        emptyStateView.configure(message: "Enter parameter range below to iterate and generate fluid properties")
    }
    
    @objc private func segmentChanged() {
        updateUnitsForSelection()
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
    }
    
    @objc private func refreshGrid() {
        let isCore = viewModeSegment.selectedSegmentIndex == 0
        
        let headers = isCore ? SessionDataManager.shared.saturationCoreHeaders : SessionDataManager.shared.saturationTransportHeaders
        let rows = isCore ? SessionDataManager.shared.saturationCoreRows : SessionDataManager.shared.saturationTransportRows
            
        resultsGrid.updateData(headers: headers, rows: rows)
        
        UISelectionFeedbackGenerator().selectionChanged()
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    @objc private func saveToHistory() {
        guard !isCurrentResultSaved else {
            CustomAlertView.show(type: .warning, title: "Already Saved", message: "This result is already in your history")
            return
        }
        
        guard let startText = inputCard.fromInput.textField.text, !startText.isEmpty,
                let endText = inputCard.toInput.textField.text, !endText.isEmpty,
                let stepText = inputCard.stepInput.textField.text, !stepText.isEmpty else {
            CustomAlertView.show(type: .error, title: "Save Failed", message: "Please calculate a valid process before saving")
            return
        }
        
        let isTemp = inputCard.segmentControl.selectedSegmentIndex == 0
        let symbol = isTemp ? "T" : "P"
        let unit = isTemp ? SettingsManager.shared.temperature.rawValue : SettingsManager.shared.pressure.rawValue
        
        let param1Str = "\(symbol): \(startText) → \(endText) \(unit)"
        let param2Str = "step \(stepText) \(unit)"
        
        let newRecord = HistoryRecord(
            category: .saturation,
            fluidName: self.fluidName,
            param1: param1Str,
            param2: param2Str,
            headers: SessionDataManager.shared.saturationCoreHeaders,
            rows: SessionDataManager.shared.saturationCoreRows,
            transportHeaders: SessionDataManager.shared.saturationTransportHeaders,
            transportRows: SessionDataManager.shared.saturationTransportRows
        )
        
        SwiftDataManager.shared.saveRecord(newRecord)
        isCurrentResultSaved = true
        if !SettingsManager.shared.autoSaveEnabled {
            CustomAlertView.show(type: .success, title: "Success", message: "Modifications saved successfully")
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
//        CustomAlertView.show(type: .success, title: "Success", message: "Modifications saved successfully")
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func configureInitialState() {
        subtitleLabel.text = fluidName
        updateUnitsForSelection()
    }
    
    private func updateUnitsForSelection() {
        let isTemp = inputCard.segmentControl.selectedSegmentIndex == 0
        let currentUnit = isTemp ? SettingsManager.shared.temperature.rawValue: SettingsManager.shared.pressure.rawValue
        
        inputCard.updateUnits(currentUnit)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func generateTableTapped() {
        guard let fromText = inputCard.fromInput.textField.text, let fromVal = Double(fromText),
              let toText = inputCard.toInput.textField.text, let toVal = Double(toText),
              let stepText = inputCard.stepInput.textField.text, let stepVal = Double(stepText),
              stepVal > 0 else {
            print("DEBUG: Invalid Inputs! Check text fields.")
            return
        }
        
        
        let estimatedRows = abs(toVal - fromVal) / stepVal
        if estimatedRows > 50 {
            let alert = UIAlertController(title: "Large Data Set", message: "This range will generate approximately \(Int(estimatedRows)) rows, which may slow down presentation. Do you want to proceed?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                self.executeCalculation(fromVal: fromVal, toVal: toVal, stepVal: stepVal)
            }))
            present(alert, animated: true)
            return
        }
        
        executeCalculation(fromVal: fromVal, toVal: toVal, stepVal: stepVal)
    }
    
    private func executeCalculation(fromVal: Double, toVal: Double, stepVal: Double) {
        let isTemp = inputCard.segmentControl.selectedSegmentIndex == 0
        
        let tempSetting = SettingsManager.shared.temperature
        let pressSetting = SettingsManager.shared.pressure
        
        let baseFrom = isTemp ? tempSetting.toBaseSI(value: fromVal) : pressSetting.toBaseSI(value: fromVal)
        let baseTo = isTemp ? tempSetting.toBaseSI(value: toVal) : pressSetting.toBaseSI(value: toVal)
        let inputKey = isTemp ? "T" : "P"
        
        let fromTest = CoolPropService.shared.calculateProperty(output: "D", input1: inputKey, val1: baseFrom, input2: "Q", val2: 0, fluid: fluidName)
        let toTest = CoolPropService.shared.calculateProperty(output: "D", input1: inputKey, val1: baseTo, input2: "Q", val2: 0, fluid: fluidName)
        
        if case .success(let fVal) = fromTest, fVal.isFinite,
            case .success(let tVal) = toTest, tVal.isFinite {
            // Both boundaries are completely valid and finite numbers! Proceed.
        } else {
            // One or both returned an error, Infinity, or NaN.
            let paramName = isTemp ? "temperature" : "pressure"
            let alert = UIAlertController(
                title: "Invalid Saturation State",
                message: "The \(paramName) range you entered falls outside the saturation dome for \(fluidName).\n\nPlease check your inputs and ensure they lie between the fluid's triple point and critical point.",
                        preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                return
        }
        
        view.endEditing(true)
        self.generateButton.setLoadingState(isCalculating: true)

        SaturationTableCalculator.generateSaturationTableAsync(
            fluidName: self.fluidName,
            isTemperatureBased: isTemp,
            startValue: fromVal,
            endValue: toVal,
            stepValue: stepVal
        ) { [weak self] (coreHeaders, coreRows, transportHeaders, transportRows) in
            guard let self = self else { return }
        
            self.isCurrentResultSaved = false
            self.lastIsTemp = isTemp
            
            SessionDataManager.shared.saturationCoreHeaders = coreHeaders
            SessionDataManager.shared.saturationCoreRows = coreRows
            SessionDataManager.shared.saturationTransportHeaders = transportHeaders
            SessionDataManager.shared.saturationTransportRows = transportRows
            
            self.emptyStateView.isHidden = true
            self.viewModeSegment.isHidden = false
            self.resultsGrid.isHidden = false
            
            self.viewModeSegment.selectedSegmentIndex = 0
            self.refreshGrid()
            
            if SettingsManager.shared.autoSaveEnabled {
                self.saveToHistory()
            }
            
            self.inputCard.setCollapsed(true, animated: true)
            self.inputCard.generateButton.setLoadingState(isCalculating: false)
            
            let unit = isTemp ? SettingsManager.shared.temperature.rawValue : SettingsManager.shared.pressure.rawValue

            self.generateButton.setLoadingState(isCalculating: false)
        }
    }
    
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
        let coreHeaders = SessionDataManager.shared.saturationCoreHeaders
        let coreRows = SessionDataManager.shared.saturationCoreRows
        let transportHeaders = SessionDataManager.shared.saturationTransportHeaders
        let transportRows = SessionDataManager.shared.saturationTransportRows
        let tableName = "Saturation Table"
            
        guard !coreHeaders.isEmpty, !coreRows.isEmpty else { return }
                
        if format == .pdf {
            DataExportManager.shared.exportAsPDF(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        } else {
            DataExportManager.shared.exportAsCSV(from: self, fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows)
        }
    }
    
    func applyPrefill(isTemp: Bool, fromVal: String, toVal: String, stepVal: String) {
        _ = self.view
        inputCard.segmentControl.selectedSegmentIndex = isTemp ? 0 : 1
        inputCard.fromInput.textField.text = fromVal
        inputCard.toInput.textField.text = toVal
        inputCard.stepInput.textField.text = stepVal
        segmentChanged()
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

extension SaturationTableViewConroller: SaturationInputCardDelegate {
    
    func inputCard(_ card: ExpandableSaturationInputCard, didTapGenerateWith from: String?, to: String?, step: String?, isTemperature: Bool) {
            
            guard let fromText = from, let fromVal = Double(fromText),
                  let toText = to, let toVal = Double(toText),
                  let stepText = step, let stepVal = Double(stepText),
                  stepVal > 0 else {
                print("DEBUG: Invalid Inputs! Check text fields.")
                return
            }
            
            let estimatedRows = abs(toVal - fromVal) / stepVal
            if estimatedRows > 50 {
                let alert = UIAlertController(title: "Large Data Set", message: "This range will generate approximately \(Int(estimatedRows)) rows. Proceed?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                    self.executeCalculation(fromVal: fromVal, toVal: toVal, stepVal: stepVal)
                }))
                present(alert, animated: true)
                return
            }
            
            executeCalculation(fromVal: fromVal, toVal: toVal, stepVal: stepVal)
        }
        
        func inputCard(_ card: ExpandableSaturationInputCard, didChangeExpansionState isCollapsed: Bool) {
            // Optional: Hide the export button while the user is typing in the expanded card
            UIView.animate(withDuration: 0.3) {
//                self.exportButton.alpha = isCollapsed ? 1 : 0
            }
        }
}
