//
//  HistoryViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/23/26.
//

import UIKit

class HistoryViewController: UIViewController {
    
    private var allRecords: [HistoryRecord] = []
    private var filteredRecords: [HistoryRecord] = []
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Past calculations"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search fluid or value..."
        return sc
    }()
    
    private let categorySegment: CustomSegmentedControl = {
        let sc = CustomSegmentedControl(items: ["All", "State Point", "Saturation", "Iso-Process"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 16
        view.setDynamicBorder(color: .cardBorder, width: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.layer.cornerRadius = 16
        tv.clipsToBounds = true
        
        tv.delegate = self
        tv.dataSource = self
        
        tv.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tv.layoutMargins = .zero
        
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = UITableView.automaticDimension
        tv.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateView = EmptyStateView()

    //MARK: - ViewDidLoad, viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allRecords = SwiftDataManager.shared.fetchAllRecords()
        filterData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "History"
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        
        let edgeAppearance = UINavigationBarAppearance()
        edgeAppearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = edgeAppearance
        
        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        setupLayout()
        categorySegment.addTarget(self, action: #selector(filterData), for: .valueChanged)
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
        headerView.addSubview(categorySegment)
        
        NSLayoutConstraint.activate([
            categorySegment.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            categorySegment.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            categorySegment.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
            categorySegment.heightAnchor.constraint(equalToConstant: adaptiveSize(phone: 30, pad: 40)),
         
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func updateEmptyState() {
        if filteredRecords.isEmpty {
            let isSearching = !(searchController.searchBar.text?.isEmpty ?? true)
            
            if isSearching {
                emptyStateView.title.text = "No Results"
                emptyStateView.configure(icon: "magnifyingglass", message: "No calculations found matching your search.")
            } else if allRecords.isEmpty {
                emptyStateView.title.text = "No History"
                emptyStateView.configure(icon: "clock.badge", message: "Your calculated tables and points will appear here.")
            } else {
                emptyStateView.title.text = "No Records"
                emptyStateView.configure(icon: "tray", message: "No records found for this category.")
            }
                
            tableView.backgroundView = emptyStateView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    
    @objc private func filterData() {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
                
        let selectedCategory: CalculatorCategory
        switch categorySegment.selectedSegmentIndex {
            case 1: selectedCategory = .statePoint
            case 2: selectedCategory = .saturation
            case 3: selectedCategory = .isoProcess
        default: selectedCategory = .all
        }
        
        filteredRecords = allRecords.filter { record in
            let matchesCategory = (selectedCategory == .all) || (record.category == selectedCategory)
            let matchesSearch = searchText.isEmpty ||
                                record.fluidName.lowercased().contains(searchText) ||
                                record.param1.lowercased().contains(searchText) ||
                                record.param2.lowercased().contains(searchText)
            return matchesCategory && matchesSearch
        }
        
        tableView.reloadData()
        updateEmptyState()
    }

}

//MARK: - UITableViewDataSource & UITableViewDelegate

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        cell.configure(with: filteredRecords[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRecord = filteredRecords[indexPath.row]
        let detailVC = HistoryDetailViewController(record: selectedRecord)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recordToDelete = filteredRecords[indexPath.row]
            let alert = UIAlertController(
                title: "Delete Record",
                message: "Are you sure you want to delete this calculation from your history? This action cannot be undone.",
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }

                SwiftDataManager.shared.deleteRecord(recordToDelete)
                self.filteredRecords.remove(at: indexPath.row)
                self.allRecords.removeAll { $0.id == recordToDelete.id }
                tableView.deleteRows(at: [indexPath], with: .left)

                self.updateEmptyState()
                
                CustomAlertView.show(type: .success, title: "Deleted", message: "Record successfully removed from history.")
            }
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            present(alert, animated: true)
        }
    }
    
    
}

//MARK: - UISearchBarDelegate

extension HistoryViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterData()
    }
}
