//
//  OnboardingViewController.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/8/26.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var onCompletion: (() -> Void)?
    
    private var pages: [OnboardingPage] = []
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .label
        pc.pageIndicatorTintColor = .systemGray4
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let primaryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .label
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 14
        btn.layer.cornerCurve = .continuous
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let secondaryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        setupData()
        setupLayout()
        setupButtons()
        updateBottomControls(for: 0, animated: false)
    }

    private func setupData() {
        // Screen 1
        let page1 = OnboardingPage(
            iconName: "icon_app",
            tagText: "Thermodynamic calculator",
            tagTextColor: .dynamic(light: "#1A5C40", dark: "#B2EAC4"),
            tagBgColor: .dynamic(light: "#E8F3EE", dark: "#1A3B2A"),
            title: "Engineering properties,\nat your fingertips",
            subtitle: "Powered by CoolProp — the open-source thermodynamic engine used by engineers and researchers worldwide.",
            customView: FirstPage(),
            primaryButtonTitle: "Get started",
            secondaryButtonTitle: "Skip"
        )
        
        // Screen 2
        let page2 = OnboardingPage(
            iconName: nil,
            tagText: "120+ fluids supported",
            tagTextColor: .dynamic(light: "#4A3A9A", dark: "#B3A6EB"),
            tagBgColor: .dynamic(light: "#E8E4F4", dark: "#2B2250"),
            title: "Everything you need for fluid analysis",
            subtitle: "From simple lookups to full saturation tables — all in one place.",
            customView: FeaturesOverviewView(),
            primaryButtonTitle: "Continue",
            secondaryButtonTitle: "Skip"
        )
        
        // Screen 3
        let page3 = OnboardingPage(
            iconName: nil,
            tagText: "Built for engineers",
            tagTextColor: .dynamic(light: "#1A5C40", dark: "#B2EAC4"),
            tagBgColor: .dynamic(light: "#E8F3EE", dark: "#1A3B2A"),
            title: "Your units, your workflow",
            subtitle: "Customise every unit and export results directly to PDF or CSV — ready for reports and datasheets.",
            customView: CustomiseExportView(),
            primaryButtonTitle: "Start calculating",
            secondaryButtonTitle: "Set up units first"
        )
        
        // We will add Screen 2 and 3 here next!
        pages = [page1, page2, page3]
        pageControl.numberOfPages = pages.count
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(primaryButton)
        view.addSubview(secondaryButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -16),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -24),
            
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor, constant: -8),
            primaryButton.heightAnchor.constraint(equalToConstant: 54),
            
            secondaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            secondaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            secondaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            secondaryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateBottomControls(for index: Int, animated: Bool) {
        let page = pages[index]
        
        if animated {
            UIView.transition(with: primaryButton, duration: 0.3, options: .transitionCrossDissolve) {
                self.primaryButton.setTitle(page.primaryButtonTitle, for: .normal)
            }
            UIView.transition(with: secondaryButton, duration: 0.3, options: .transitionCrossDissolve) {
                self.secondaryButton.setTitle(page.secondaryButtonTitle, for: .normal)
            }
        } else {
            primaryButton.setTitle(page.primaryButtonTitle, for: .normal)
            secondaryButton.setTitle(page.secondaryButtonTitle, for: .normal)
        }
        
        pageControl.currentPage = index
    }
    
    private func setupButtons() {
        primaryButton.addTarget(self, action: #selector(handlePrimaryButton), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryButton), for: .touchUpInside)
    }
    
    @objc private func handlePrimaryButton() {
        if pageControl.currentPage == pages.count - 1 {
            onCompletion?()
        } else {
            let nextPage = pageControl.currentPage + 1
            collectionView.scrollToItem(at: IndexPath(item: nextPage, section: 0), at: .centeredHorizontally, animated: true)
            updateBottomControls(for: nextPage, animated: true)
        }
    }
    
    @objc private func handleSecondaryButton() {
        onCompletion?()
    }
    
    private func scrollToPage(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        updateBottomControls(for: index, animated: true)
    }
}

// MARK: - Collection View Setup
extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.identifier, for: indexPath) as! OnboardingCell
        cell.configure(with: pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    // Update dots and buttons when user finishes swiping
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / width)
        updateBottomControls(for: currentPage, animated: true)
    }
}
