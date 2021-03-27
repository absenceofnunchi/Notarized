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
        
        let destinationVC = menuType.VCType
        
        newPageVC = destinationVC.init()
        addChild(newPageVC)
        newPageVC.view.alpha = 0
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
            self.oldPageVC.view.alpha = 1
            self.newPageVC = nil
        }
        dismiss(animated: true)
    }
}
