//
//  LicensesViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/7/26.
//

import UIKit

class LicensesViewController: UIViewController {
    
    private var expandedRows: Set<Int> = [0]
    
    private let licenses: [OpenSourceLicense] = [
        OpenSourceLicense(
            name: "CoolProp",
            version: "v\(String(cString: get_coolprop_version())) · MIT License",
            text: """
            CoolProp — MIT License
            Copyright (c) 2010–2026 Ian H. Bell and the CoolProp Team.
                
            Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
                
            The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
            """,
            iconSymbol: "curlybraces"
        )
    ]
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        
        tv.register(ExpandableLicenseCell.self, forCellReuseIdentifier: ExpandableLicenseCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground
        
        setupTableViewHeader()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        
        let titleLabel = UILabel()
        titleLabel.text = "Licenses"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Open source acknowledgements"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        tableView.tableHeaderView = headerView
    }

}

// MARK: - TableView Delegate & DataSource
extension LicensesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableLicenseCell.identifier, for: indexPath) as! ExpandableLicenseCell
        
        let isExpanded = expandedRows.contains(indexPath.row)
        cell.configure(with: licenses[indexPath.row], isExpanded: isExpanded)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCurrentlyExpanded = expandedRows.contains(indexPath.row)
        
        if isCurrentlyExpanded {
            expandedRows.remove(indexPath.row)
        } else {
            expandedRows.insert(indexPath.row)
        }

        tableView.performBatchUpdates({
            if let cell = tableView.cellForRow(at: indexPath) as? ExpandableLicenseCell {
                cell.toggleExpansion(isExpanded: !isCurrentlyExpanded)
                cell.layoutIfNeeded()
            }
        }, completion: nil)
    }
}
