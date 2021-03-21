//
//  ContainerViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-16.
//

import UIKit

protocol ContainerDelegate: AnyObject {
    func didSelectVC(_ menuType: MenuType)
}

class ContainerViewController: UIViewController {
    var sideBarButton: UIButton!
    let slideInTransitionAnimator = SlideInTransitionAnimator()
    var mainVC: MainViewController!
    var filesVC = FilesViewController()
    var oldPageVC: UIViewController!
    var newPageVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
    }
}

extension ContainerViewController {
    
    // MARK: - Configure UI
    func configureUI() {
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
        
  
//        sideBarButton = UIButton.systemButton(with: image, target: self, action: #selector(buttonHandler))
//        sideBarButton.tintColor = .white
//        sideBarButton.translatesAutoresizingMaskIntoConstraints = false
//        sideBarButton.layer.zPosition = 100
//        view.insertSubview(sideBarButton, aboveSubview: mainVC.view)
    }
    
    // MARK: - Set constraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            // side bar button
//            sideBarButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
//            sideBarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            sideBarButton.widthAnchor.constraint(equalToConstant: 50),
//            sideBarButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc func buttonHandler() {
        let menuTableVC = MenuTableViewController()
        menuTableVC.modalPresentationStyle = .overCurrentContext
        menuTableVC.transitioningDelegate = slideInTransitionAnimator
        menuTableVC.delegate = self
        self.present(menuTableVC, animated: true, completion: nil)
    }
}

extension ContainerViewController: ContainerDelegate {
    // MARK: - didSelectVC
    func didSelectVC(_ menuType: MenuType) {
        let destinationVC = menuType.VCType
        
        newPageVC = destinationVC.init()
        addChild(newPageVC)
        newPageVC.view.alpha = 0
        oldPageVC.willMove(toParent: nil)
        oldPageVC.beginAppearanceTransition(false, animated: true)
        newPageVC.beginAppearanceTransition(true, animated: true)

        UIView.transition(from: oldPageVC.view, to: newPageVC.view, duration: 0.4, options: .transitionCrossDissolve) { (_) in
            self.oldPageVC.endAppearanceTransition()
            self.newPageVC.endAppearanceTransition()
            self.newPageVC.didMove(toParent: self)
            self.oldPageVC.removeFromParent()
            self.oldPageVC = nil
            self.oldPageVC = self.newPageVC
            self.newPageVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.oldPageVC.view.fill()
            self.oldPageVC.view.alpha = 1
            self.newPageVC = nil

        }
        dismiss(animated: true)
    }
}
