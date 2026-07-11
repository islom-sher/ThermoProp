//
//  SettingsViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let deviceVersion = UIDevice.current.systemVersion
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .appBackground
        tv.showsVerticalScrollIndicator = false
        
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        
        tv.delegate = self
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return tv
    }()
    
    private var sections: [SettingsSection] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
        setAppApearance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Settings"
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        
        let edgeAppearance = UINavigationBarAppearance()
        edgeAppearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = edgeAppearance
        definesPresentationContext = true
    
        setupData()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func deviceType() -> String {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isPad {
            return "iPadOS"
        }
        return "iOS"
    }
    
    private func setupData() {
        let currentTemp = SettingsManager.shared.temperature.rawValue
        let currentPress = SettingsManager.shared.pressure.rawValue
        let currentDens = SettingsManager.shared.density.rawValue
        let currentEnth = SettingsManager.shared.enthalpy.rawValue
        let currentEntr = SettingsManager.shared.entropy.rawValue
        
        let currentRefState = SettingsManager.shared.referenceState.rawValue
        let currentDecimals = SettingsManager.shared.decimals.rawValue
        let currentAppearance = SettingsManager.shared.appearance.rawValue
        
        let profileSection = SettingsSection(title: nil, items: [
            SettingsItem(title: "ThermoProp App", subtitle: "v1.0.0 · \(deviceType()) \(deviceVersion)", icon: .symbol("person"), iconColor: .systemGray, accessory: .none)])
                
        let unitsSection = SettingsSection(title: "UNITS", items: [
            SettingsItem(title: "Temperature", subtitle: nil, icon: .text("T"), iconColor: .systemRed, accessory: .chevron(value: currentTemp)),
            SettingsItem(title: "Pressure", subtitle: nil, icon: .text("P"), iconColor: .systemBlue, accessory: .chevron(value: currentPress)),
            SettingsItem(title: "Density", subtitle: nil, icon: .text("ρ"), iconColor: .systemGreen, accessory: .chevron(value: currentDens)),
            SettingsItem(title: "Enthalpy", subtitle: nil, icon: .text("h"), iconColor: .systemOrange, accessory: .chevron(value: currentEnth)),
            SettingsItem(title: "Entropy", subtitle: nil, icon: .text("s"), iconColor: .systemRed, accessory: .chevron(value: currentEntr)),
            
            SettingsItem(title: "Reference state", subtitle: nil, icon: .symbol("building.2"), iconColor: .systemGreen, accessory: .chevron(value: currentRefState))
        ])
        
        let displaySection = SettingsSection(title: "DISPLAY", items: [
            SettingsItem(title: "Appearance", subtitle: nil, icon: .symbol("sun.max"), iconColor: .systemYellow, accessory: .chevron(value: currentAppearance)),
            SettingsItem(title: "Decimal places", subtitle: "\(currentDecimals) digits", icon: .symbol("00.circle"), iconColor: .systemBlue, accessory: .chevron(value: currentDecimals)),
            SettingsItem(title: "Save results automatically", subtitle: "Store past results", icon: .symbol("clock.arrow.circlepath"), iconColor: .systemBrown, accessory: .toggle(isOn: SettingsManager.shared.autoSaveEnabled))
        ])
        
        let aboutSection = SettingsSection(title: "ABOUT & SUPPORT", items: [
            SettingsItem(title: "Send feedback", subtitle: "support@coolpropapp.com", icon: .symbol("envelope"), iconColor: .systemGreen, accessory: .externalLink),
            SettingsItem(title: "Licenses", subtitle: "CoolProp & open source", icon: .symbol("doc.text"), iconColor: .systemGray, accessory: .chevron(value: "")),
            SettingsItem(title: "ThermoProp source", subtitle: "github.com/ThermoProp", icon: .symbol("chevron.left.forwardslash.chevron.right"), iconColor: .systemGray, accessory: .externalLink)
        ])
        
        self.sections = [profileSection, unitsSection, displaySection, aboutSection]
        tableView.reloadData()
    }
    
    private func setAppApearance() {
        let currentAppearance = SettingsManager.shared.appearance.rawValue
        
        _ = SettingsSection(title: "DISPLAY", items: [
            SettingsItem(title: "Appearance", subtitle: nil, icon: .symbol("moon"), iconColor: .systemIndigo, accessory: .chevron(value: currentAppearance))
        ])
        tableView.reloadData()
    }
    
    private func showUnitPicker(for title: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Select \(title)", message: nil, preferredStyle: .actionSheet)
        var options: [String] = []
        
        if title == "Temperature" {
            options = TemperatureUnit.allCases.map { $0.rawValue }
        } else if title == "Pressure" {
            options = PressureUnit.allCases.map { $0.rawValue }
        } else if title == "Density" {
            options = DensityUnit.allCases.map { $0.rawValue }
        } else if title == "Enthalpy" {
            options = EnthalpyUnit.allCases.map { $0.rawValue }
        } else if title == "Entropy" {
            options = EntropyUnit.allCases.map { $0.rawValue }
        } else if title == "Reference state" {
            options = ReferenceState.allCases.map { $0.rawValue }
        } else if title == "Decimal places" {
            options = DecimalPlaces.allCases.map { $0.rawValue }
        }
    
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                
                if title == "Temperature", let newUnit = TemperatureUnit(rawValue: option) {
                    SettingsManager.shared.temperature = newUnit
                } else if title == "Pressure", let newUnit = PressureUnit(rawValue: option) {
                    SettingsManager.shared.pressure = newUnit
                } else if title == "Density", let newUnit = DensityUnit(rawValue: option) {
                    SettingsManager.shared.density = newUnit
                } else if title == "Enthalpy", let newUnit = EnthalpyUnit(rawValue: option) {
                    SettingsManager.shared.enthalpy = newUnit
                } else if title == "Entropy", let newUnit = EntropyUnit(rawValue: option) {
                    SettingsManager.shared.entropy = newUnit
                } else if title == "Reference state", let newState = ReferenceState(rawValue: option) {
                    SettingsManager.shared.referenceState = newState
                } else if title == "Decimal places", let newDecimals = DecimalPlaces(rawValue: option) {
                    SettingsManager.shared.decimals = newDecimals
                }
            
                DispatchQueue.main.async {
                    self?.setupData()
                }
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            } else {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        present(alert, animated: true)
    }
    
    private func showAutoSaveAlert(isOn: Bool) {
        let message = isOn
            ? "Results will now be saved automatically after calculation"
            : "Automatic saving is disabled. You will need to save results manually using the save buttons"
        
        let alert = UIAlertController(title: "Auto-Save", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func showRedirectAlert(to urlString: String, siteName: String) {
        let alert = UIAlertController(
            title: "Leaving ThermoProp",
            message: "You are about to be redirected to an external website (\(siteName)). Do you wish to continue?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let openAction = UIAlertAction(title: "Continue", style: .default) { _ in
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        present(alert, animated: true)
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == nil ? 5 : 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.font = .sfMono(size: adaptiveSize(phone: 12, pad: 14), weight: .semibold)
        header.textLabel?.textColor = .secondaryLabel
        header.textLabel?.text = sections[section].title?.uppercased()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .cardBackground
        
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        
        if case .toggle = item.accessory {
            cell.onToggle = { [weak self] isOn in
                SettingsManager.shared.autoSaveEnabled = isOn
                self?.showAutoSaveAlert(isOn: isOn)
            }
        }
        
        switch item.accessory {
        case .toggle, .segment, .none:
            cell.selectionStyle = .none
        default:
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        if indexPath.section == 1 {
            if item.title != "Property basis" {
                showUnitPicker(for: item.title, at: indexPath)
            }
        } else if indexPath.section == 2 {
            if item.title == "Appearance" {
                let appearanceVC = AppearanceViewController()
                navigationController?.pushViewController(appearanceVC, animated: true)
            } else if item.title == "Decimal places" {
                showUnitPicker(for: item.title, at: indexPath)
            }
        } else if indexPath.section == 3 {
            if item.title == "Licenses" {
                let licensesVC = LicensesViewController()
                navigationController?.pushViewController(licensesVC, animated: true)
            } else if item.title == "ThermoProp source" {
                let githubURLString = "https://github.com/islom-sher/ThermoProp.git"
                
                showRedirectAlert(to: githubURLString, siteName: "GitHub")
            }
        }
        print("Tapped on \(item.title)")
    }
    
    
}
