//
//  ContainerViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-16.
//

import UIKit
import web3swift

protocol ContainerDelegate: AnyObject {
    func didSelectVC(_ menuType: MenuType)
    func didSelectETCMenu(_ tag: Int)
}

class ContainerViewController: UIViewController {
    let slideInTransitionAnimator = SlideInTransitionAnimator()
    var mainVC: MainViewController!
    var filesVC = FilesViewController()
    var oldPageVC: UIViewController!
    var newPageVC: UIViewController!
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
    }
}

extension ContainerViewController {
    
    // MARK: - Configure UI
    func configureUI() {
        
        // configure navigation bar
        let navBar = self.navigationController?.navigationBar
        navBar?.standardAppearance.backgroundColor = UIColor.clear
        navBar?.standardAppearance.backgroundEffect = nil
        navBar?.standardAppearance.shadowImage = UIImage()
        navBar?.standardAppearance.shadowColor = .clear
        navBar?.standardAppearance.backgroundImage = UIImage()
        navBar?.tintColor = .white
        
        // Add main vc as a child vc
        mainVC = MainViewController()
        
        // assign it so that it can be transitioned later
        oldPageVC = mainVC
        addChild(mainVC)
        view.addSubview(mainVC.view)
        mainVC.view.frame = view.bounds
        mainVC.didMove(toParent: self)
        
        // side bar button
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "line.horizontal.3.decrease", withConfiguration: imageConfig)!
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(buttonHandler))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(buttonHandler))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
        
    }
    
    // MARK: - Set constraints
    func setConstraints() {
        NSLayoutConstraint.activate([

        ])
    }

    @objc func buttonHandler() {
        let menuTableVC = MenuTableViewController()
        menuTableVC.modalPresentationStyle = .overCurrentContext
        menuTableVC.transitioningDelegate = slideInTransitionAnimator
        menuTableVC.delegate = self
        self.present(menuTableVC, animated: true, completion: nil)
    }
    
    @objc func gestureHandler() {
        
    }
}

extension ContainerViewController: ContainerDelegate {
    // MARK: - didSelectVC
    func didSelectVC(_ menuType: MenuType) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch menuType {
            case .files:
                let destinationVC = menuType.VCType
                let nav = UINavigationController(rootViewController: destinationVC.init())
                newPageVC = nav
            case .etherscan:
                if let address = Web3swiftService.currentAddressString {
                    let webVC = WebViewController()
                    webVC.urlString = "https://etherscan.io/address/\(address)"
                    newPageVC = webVC
                } else {
                    dismiss(animated: true) { [weak self] in
                        self?.alert.show("No wallet", with: "You need to create/import a wallet first view your account on Etherscan", for: self!)
                    }
                    return
                }
            default:
                let destinationVC = menuType.VCType
                newPageVC = destinationVC.init()
        }
        
//        if destinationVC == FilesViewController.self {
//            let fvc = FilesViewController()
//            let nav = UINavigationController(rootViewController: fvc)
//            newPageVC = nav
//        } else {
//            newPageVC = destinationVC.init()
//        }
        
        addChild(newPageVC)
        oldPageVC.willMove(toParent: nil)
        oldPageVC.beginAppearanceTransition(false, animated: true)
        newPageVC.beginAppearanceTransition(true, animated: true)

        UIView.transition(from: oldPageVC.view, to: newPageVC.view, duration: 0.1, options: .transitionCrossDissolve) { (_) in
            self.oldPageVC.endAppearanceTransition()
            self.newPageVC.endAppearanceTransition()
            self.newPageVC.didMove(toParent: self)
            self.oldPageVC.removeFromParent()
            self.oldPageVC = nil
            self.oldPageVC = self.newPageVC
            self.newPageVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.oldPageVC.view.fill()
            self.newPageVC = nil
        }
        dismiss(animated: true)
    }
    
    // MARK: -
    func didSelectETCMenu(_ tag: Int) {
        print(tag)
    }
}
