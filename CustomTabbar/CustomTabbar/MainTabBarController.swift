//
//  MainTabBarController.swift
//  CustomTabbar
//
//  Created by Nexios Technologies on 16/06/25.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    let createButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Apply global tab bar tint styles
        tabBar.tintColor = .systemGreen // ✅ Selected icon + text color
        tabBar.unselectedItemTintColor = .gray // Optional: unselected color
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false
        
        setupViewControllers()
        setupCreateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTopLineToSelectedTab(index: selectedIndex)
    }

    private func setupViewControllers() {
        let homeVC = UINavigationController(rootViewController: ViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let dialerVC = UINavigationController(rootViewController: ViewController())
        dialerVC.tabBarItem = UITabBarItem(title: "Dialer/Meet", image: UIImage(systemName: "phone"), tag: 1)
        
        let groupsVC = UINavigationController(rootViewController: ViewController())
        groupsVC.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(systemName: "person.3.fill"), tag: 3)
        
        let menuVC = UINavigationController(rootViewController: ViewController())
        menuVC.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "person.crop.circle"), tag: 4)
        
        self.viewControllers = [homeVC, dialerVC, UIViewController(), groupsVC, menuVC]
    }

    private func setupCreateButton() {
        createButton.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        createButton.layer.cornerRadius = 24
        createButton.backgroundColor = .systemRed
        createButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        createButton.tintColor = .white
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowOpacity = 0.3
        createButton.layer.shadowOffset = .zero
        createButton.layer.shadowRadius = 6

        let tabBarHeight = tabBar.frame.height
        createButton.center = CGPoint(x: tabBar.center.x, y: view.bounds.height - tabBarHeight / 2 - 10)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        view.addSubview(createButton)
    }
    
    private var tabBarSelectionIndicator: UIView?

    private func addTopLineToSelectedTab(index: Int) {
        // Remove old indicator if exists
        tabBarSelectionIndicator?.removeFromSuperview()

        // Get frame of tab bar item
        let tabBarItems = tabBar.items?.count ?? 0
        guard tabBarItems > 0, index < tabBarItems else { return }

        let tabBarItemWidth = tabBar.bounds.width / CGFloat(tabBarItems)
        let xPosition = CGFloat(index) * tabBarItemWidth

        let indicatorHeight: CGFloat = 3
        let indicatorFrame = CGRect(x: xPosition, y: 0, width: tabBarItemWidth, height: indicatorHeight)

        let indicator = UIView(frame: indicatorFrame)
        indicator.backgroundColor = .systemGreen

        tabBar.addSubview(indicator)
        tabBar.bringSubviewToFront(indicator)

        self.tabBarSelectionIndicator = indicator
    }

    @objc func createTapped() {
//        let createVC = CreateOptionsViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let createVC = storyboard.instantiateViewController(withIdentifier: "CreateOptionsViewController") as? CreateOptionsViewController else {
            return
        }
        createVC.modalPresentationStyle = .pageSheet
        createVC.modalTransitionStyle = .crossDissolve // Optional: smooth transition
        if let sheet = createVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    //.custom { _ in return 485 }, // custom height
                    .custom { context in
                        return createVC.preferredContentSize.height
                    }
                    //.large()
                ]
            } else {
                sheet.detents = [.medium(), .large()] // fallback for iOS 15
            }
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }
        self.present(createVC, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createButton.center = CGPoint(x: tabBar.center.x, y: view.bounds.height - tabBar.frame.height / 2 - 10)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        addTopLineToSelectedTab(index: selectedIndex)
    }
    
}

//class CreateOptionsViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        let label = UILabel()
//        label.text = "Which type of channel would you like to create?"
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//    }
//}
