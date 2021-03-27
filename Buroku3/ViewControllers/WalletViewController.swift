//
//  WalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-21.
//

import UIKit

class WalletViewController: UIViewController {
    var rightBarButtonItem: UIBarButtonItem?
    let localDatabase = LocalDatabase()
    var newPageVC: UIViewController!
    var oldPageVC: UIViewController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let _ = localDatabase.getWallet() {
            let vc = RegisteredWalletViewController()
            newPageVC = vc
            oldPageVC = vc
        } else {
            let vc = UnregisteredWalletViewController()
            newPageVC = vc
            oldPageVC = vc
        }
        addChild(newPageVC)
        view.addSubview(newPageVC.view)
        newPageVC.view.frame = view.bounds
        newPageVC.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.navigationItem.setRightBarButton(nil, animated: true)
    }
}

extension WalletViewController {

    // MARK: - Configure Navigation Item
    func configureNavigationItem() {
        // nav bar attributes
        let navBar = self.navigationController?.navigationBar
        navBar?.standardAppearance.backgroundColor = UIColor.clear
        navBar?.standardAppearance.backgroundEffect = nil
        navBar?.standardAppearance.shadowImage = UIImage()
        navBar?.standardAppearance.shadowColor = .clear
        navBar?.standardAppearance.backgroundImage = UIImage()
        navBar?.tintColor = .white
        
        rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.stack.badge.plus"), style: .plain, target: self, action: #selector(buttonHandler))
        rightBarButtonItem?.tag = 1
        self.parent?.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    

    func configureChildVC() {
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
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        
    }
}

extension WalletViewController: WalletDelegate {
    func didProcessWallet() {
        if let _ = localDatabase.getWallet() {
            if !(self.children[0].isKind(of: RegisteredWalletViewController.self)) {
                newPageVC = RegisteredWalletViewController()
                configureChildVC()
            }
        } else {
            if !(self.children[0].isKind(of: UnregisteredWalletViewController.self)) {
                newPageVC = UnregisteredWalletViewController()
                configureChildVC()
            }
        }
    }
}
