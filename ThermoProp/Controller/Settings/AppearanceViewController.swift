//
//  AppearanceViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/16/26.
//

import UIKit

class AppearanceViewController: UIViewController {
    
    private let options = AppAppearance.allCases
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .appBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "AppearanceCell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Appearence"
        view.backgroundColor = .appBackground
        
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AppearanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppearanceCell", for: indexPath)
        let currentOption = options[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = .sfMono(size: adaptiveSize(phone: 14, pad: 16), weight: .regular)
        content.text = currentOption.rawValue
        
        cell.contentConfiguration = content
        
        if currentOption == SettingsManager.shared.appearance {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .label
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTheme = options[indexPath.row]
        SettingsManager.shared.appearance = selectedTheme
        
        tableView.reloadData()
    }
    
    
}
