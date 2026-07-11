//
//  CalculatorViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    var isFluidsExpanded = false
    var currentlySelectedFluid: FluidItem? = nil
    private var isSelectingFluid = false
    
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.delaysContentTouches = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
        
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let fluidSearchBar = FluidSearchBar()
    let metaDataView = FluidMetaDataView()
    private let searchListView = FluidSearchListView()
    private let optionsSection = CalculatorOptionsSectionView()
    
    var activeResults: [PropertyResult] = []
    
    private var cachedStatePointVC: StatePointViewController?
    private var cachedSaturationVC: SaturationTableViewConroller?
    private var cachedIsoProcessVC: IsoProcessViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "ThermoCalc"
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        
        let edgeAppearance = UINavigationBarAppearance()
        edgeAppearance.configureWithTransparentBackground()
        
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.standardAppearance = standardAppearance
        navBar.scrollEdgeAppearance = edgeAppearance
        navBar.compactAppearance = standardAppearance
        
        configureSearchBar()
        setupScrollView()
        setupInteractions()
        setupInitialEmptyGrid()
        setupCustomTapToDismissKeyboard()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnitChange),
            name: .unitsDidUpdate,
            object: nil
        )
    }
    
    // MARK: - Search Bar Configuration
    private func configureSearchBar() {
        fluidSearchBar.delegate = self
        if UIDevice.current.userInterfaceIdiom != .pad {
            navigationItem.titleView = fluidSearchBar
        }
    }
    
    // Sets up the scrollView and all elements inside it
    private func setupScrollView() {
        fluidSearchBar.accessibilityIdentifier = "MainFluidSearchBar"
        searchListView.tableView.accessibilityIdentifier = "FluidSearchTableView"
        
        searchListView.isHidden = true
        searchListView.alpha = 0
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isPad {
            view.addSubview(fluidSearchBar)
            fluidSearchBar.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(metaDataView)
        contentView.addSubview(optionsSection)
        
        view.addSubview(searchListView)
        
        metaDataView.translatesAutoresizingMaskIntoConstraints = false
        optionsSection.translatesAutoresizingMaskIntoConstraints = false
        searchListView.translatesAutoresizingMaskIntoConstraints = false

        
        var constraints: [NSLayoutConstraint] = [
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            metaDataView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            metaDataView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metaDataView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            optionsSection.topAnchor.constraint(equalTo: metaDataView.bottomAnchor, constant: 16),
            optionsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
        ]
        
        if isPad {
            constraints.append(contentsOf: [
                fluidSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                fluidSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                fluidSearchBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
                fluidSearchBar.heightAnchor.constraint(equalToConstant: 50),
                
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: fluidSearchBar.topAnchor, constant: -16),
                
                searchListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchListView.bottomAnchor.constraint(equalTo: fluidSearchBar.topAnchor, constant: -8)
            ])
        } else {
            constraints.append(contentsOf: [
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                searchListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    // Sets up initial grid info when app firstly opened
    private func setupInitialEmptyGrid() {
        let tempUnit = SettingsManager.shared.temperature.rawValue
        let pressUnit = SettingsManager.shared.pressure.rawValue
        
        let initialData = [
            CharacteristicItem(title: "Molar weight", value: "0", unit: "g/mol"),
            CharacteristicItem(title: "Critical T", value: "0", unit: tempUnit),
            CharacteristicItem(title: "Critical P", value: "0", unit: pressUnit),
            CharacteristicItem(title: "Triple point T", value: "0", unit: tempUnit),
            CharacteristicItem(title: "Triple point P", value: "0", unit: pressUnit),
            CharacteristicItem(title: "Acentric ω", value: "0", unit: "–"),
            CharacteristicItem(title: "GWP100", value: "0", unit: "-"),
            CharacteristicItem(title: "ODP", value: "0", unit: "-")
        ]
        
        metaDataView.updateData(initialData)
    }

    private func setupInteractions() {
        searchListView.onFluidSelected = { [weak self] chosenFluid in
            guard let self = self else { return }
            
            if self.currentlySelectedFluid?.name != chosenFluid.name {
                self.cachedStatePointVC = nil
                self.cachedSaturationVC = nil
                self.cachedIsoProcessVC = nil
                SessionDataManager.shared.clearAllData()
            }
            
            SessionDataManager.shared.clearAllData()
            
            self.isSelectingFluid = true
            self.currentlySelectedFluid = chosenFluid
            
            self.fluidSearchBar.resignFirstResponder()
            self.fluidSearchBar.configureAsSelected(for: chosenFluid)
            self.toggleViewMode(isSearching: false)
            
            if let constants = CoolPropService.shared.fetchConstants(for: chosenFluid.name) {
                self.refreshCharacteristicsGrid(with: constants)
            }
            
            DispatchQueue.main.async {
                self.isSelectingFluid = false
            }
        }
        
        optionsSection.onStatePointTapped = { [weak self] in
            guard let self = self, let fluid = self.currentlySelectedFluid else { return }
            
            if self.cachedStatePointVC == nil {
                self.cachedStatePointVC = StatePointViewController()
                self.cachedStatePointVC?.hidesBottomBarWhenPushed = true
                self.cachedStatePointVC?.fluidName = fluid.name
            }
            
            if let vc = self.cachedStatePointVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            print("Navigate to State Point Calculator for \(fluid.name)")
        }
        
        optionsSection.onSaturationTableTapped = { [weak self] in
            guard let self = self, let fluid = self.currentlySelectedFluid else { return }
            if self.cachedSaturationVC == nil {
                self.cachedSaturationVC = SaturationTableViewConroller()
                self.cachedSaturationVC?.hidesBottomBarWhenPushed = true
                self.cachedSaturationVC?.fluidName = fluid.name
            }
            if let vc = self.cachedSaturationVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            print("Navigate to Saturation Table")
        }
        
        optionsSection.onIsoProcessTapped = { [weak self] in
            guard let self = self, let fluid = self.currentlySelectedFluid else { return }
            
            if self.cachedIsoProcessVC == nil {
                self.cachedIsoProcessVC = IsoProcessViewController()
                self.cachedIsoProcessVC?.hidesBottomBarWhenPushed = true
                self.cachedIsoProcessVC?.fluidName = fluid.name
            }
            if let vc = self.cachedIsoProcessVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            print("Navigate to Iso-Process Table")
        }
    }
    
    private func toggleViewMode(isSearching: Bool) {
        if isSearching {
            self.searchListView.isHidden = false
        } else {
            self.scrollView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.searchListView.alpha = isSearching ? 1 : 0
            
            self.view.layoutIfNeeded()
        } completion: { _ in
            if isSearching {
                self.scrollView.isHidden = true
            } else {
                self.searchListView.isHidden = true
            }
        }
    }
    
    // Updates the collectionview when units are changed, when fluid search bar sets the fluid
    private func refreshCharacteristicsGrid(with constants: FluidCharacteristics) {
        let newData = constants.toDisplayItems()
        metaDataView.updateData(newData)
    }

//MARK: -
    
    // Handles the unit change all across the CalculatorVC
    @objc private func handleUnitChange() {
        guard let fluid = currentlySelectedFluid else {
            setupInitialEmptyGrid()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let constants = CoolPropService.shared.fetchConstants(for: fluid.name) {
                DispatchQueue.main.async {
                    self?.refreshCharacteristicsGrid(with: constants)
                }
            }
        }
    }
}

//MARK: - UISearchBarDelegate
extension CalculatorViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        fluidSearchBar.resetToEmptyState()
        searchListView.filter(with: "")
        toggleViewMode(isSearching: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fluidSearchBar.resetToEmptyState()
        }
        searchListView.filter(with: searchText)
    }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let fluid = currentlySelectedFluid {
            fluidSearchBar.configureAsSelected(for: fluid)
        } else {
            fluidSearchBar.resetToEmptyState()
        }
        toggleViewMode(isSearching: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let fluid = currentlySelectedFluid {
            fluidSearchBar.configureAsSelected(for: fluid)
        } else {
            fluidSearchBar.resetToEmptyState()
        }
        toggleViewMode(isSearching: false)
    }
}

// MARK: - Smart Keyboard Dismissal
extension CalculatorViewController: UIGestureRecognizerDelegate {
    
    func setupCustomTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        fluidSearchBar.resignFirstResponder()
        
        if let fluid = currentlySelectedFluid {
            fluidSearchBar.configureAsSelected(for: fluid)
        } else {
            fluidSearchBar.resetToEmptyState()
        }
        toggleViewMode(isSearching: false)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view {
            if touchedView.isDescendant(of: fluidSearchBar) {
                return false
            }
            
            if touchedView.isDescendant(of: searchListView.tableView) {
                return false
            }
        }
        
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return true
    }
}

