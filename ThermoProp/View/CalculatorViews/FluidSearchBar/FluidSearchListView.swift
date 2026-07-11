//
//  FluidSearchListView.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/14/26.
//

import UIKit

class FluidSearchListView: UIView {
    
    var onFluidSelected: ((FluidItem) -> Void)?
    
    var recentFluids: [FluidItem] = []
    var categorizedSections: [FluidSection] = []
    var searchResults: [FluidItem] = []
    private var currentQuery: String = ""
    
    var allFluids: [FluidItem] {
        return categorizedSections.flatMap { $0.fluids }
    }
    
    var isSearching: Bool {
        return !currentQuery.isEmpty
    }
    
    private(set) lazy var tableView: DynamicHeightTableView = {
        let tv = DynamicHeightTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .cardBackground
        tv.layer.cornerRadius = 16
        tv.layer.cornerCurve = .continuous
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.clipsToBounds = true
        
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .onDrag
        tv.delegate = self
        tv.dataSource = self
        tv.register(FluidSearchCell.self, forCellReuseIdentifier: FluidSearchCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadData()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        addSubview(tableView)
        self.backgroundColor = .clear
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: FluidSearchListView, previousTraitCollection) in
                self.tableView.layer.borderColor = UIColor.cardBorder.cgColor
            }
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func loadData() {
        categorizedSections = FluidDataFactory.fetchAndCategorizeLibrary()
        tableView.reloadData()
    }
    
    func filter(with query: String) {
        self.currentQuery = query
        
        guard !query.isEmpty else {
            searchResults.removeAll()
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
            return
        }
        
        searchResults = allFluids.filter { fluid in
            fluid.name.lowercased().contains(query.lowercased()) ||
            fluid.subtitle.lowercased().contains(query.lowercased())
        }
        
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }
}

extension FluidSearchListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching { return 1 }
        return 1 + categorizedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching { return searchResults.count }
        if section == 0 { return recentFluids.count }
        return categorizedSections[section - 1].fluids.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If a section is empty (like Recents on first launch), don't show a header
        if !isSearching && section == 0 && recentFluids.isEmpty { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .cardBackground
        
        let titleLabel = UILabel()
        titleLabel.font = .sfMono(size: 12, weight: .bold)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if isSearching {
            titleLabel.text = "RESULTS"
        } else if section == 0 {
            titleLabel.text = "RECENT"
        } else {
            titleLabel.text = categorizedSections[section - 1].title.uppercased()
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        // Add a thin gray separator line above every section EXCEPT the very first one
        if section > 0 {
            let separator = UIView()
            separator.backgroundColor = UIColor.systemGray5
            separator.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: headerView.topAnchor),
                separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isSearching && section == 0 && recentFluids.isEmpty { return 0 }
        return 34
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FluidSearchCell.identifier, for: indexPath) as! FluidSearchCell
                
        let fluid = isSearching ? searchResults[indexPath.row] : (indexPath.section == 0 ? recentFluids[indexPath.row] : categorizedSections[indexPath.section - 1].fluids[indexPath.row])
        cell.configure(with: fluid)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedFluid = isSearching ? searchResults[indexPath.row] : (indexPath.section == 0 ? recentFluids[indexPath.row] : categorizedSections[indexPath.section - 1].fluids[indexPath.row])
                
        // Handle selection state
        for i in 0..<recentFluids.count { recentFluids[i].isSelected = false }
        for s in 0..<categorizedSections.count {
            for f in 0..<categorizedSections[s].fluids.count {
                categorizedSections[s].fluids[f].isSelected = false
            }
        }
        
        selectedFluid.isSelected = true
                
        // Manage Recents
        recentFluids.removeAll { $0 == selectedFluid }
        recentFluids.insert(selectedFluid, at: 0)
        if recentFluids.count > 3 { recentFluids.removeLast() }
        
        tableView.reloadData()
        
        onFluidSelected?(selectedFluid)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = .sfMono(size: 12, weight: .bold)
            header.textLabel?.textColor = .systemGray
        }
    }
}

// MARK: - Dynamic Height Helper
class DynamicHeightTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
}
