//
//  RegisteredWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//

import UIKit
import web3swift

class RegisteredWalletViewController: UIViewController {
    var pvc: UIPageViewController!
    let galleries: [String] = ["1", "2"]
    var topBackgroundView: BackgroundView4!
    var ethLabel: UILabel!
    var sendButton: WalletButtonView!
    var receiveButton: WalletButtonView!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureTopView()
        setTopViewConstraints()
        
        configurePageVC()
        setSinglePageConstraints()
    }
}

extension RegisteredWalletViewController {
    func configureTopView() {
        // container view
        topBackgroundView = BackgroundView4()
        topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBackgroundView)
        
        // eth label
        ethLabel = UILabel()
        ethLabel.text = "0 ETH"
        ethLabel.textColor = UIColor(red: 74/255, green: 71/255, blue: 163/255, alpha: 1)
        ethLabel.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        ethLabel.sizeToFit()
        ethLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ethLabel)
        
        // send button
        sendButton = WalletButtonView(imageName: "arrow.up.to.line", labelName: "Send")
        sendButton.buttonAction = { [weak self] in
            print("button tapped")
        }
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        // receive button
        receiveButton = WalletButtonView(imageName: "arrow.down.to.line", labelName: "Receive")
        receiveButton.buttonAction = { [weak self] in
            let receiveVC = ReceiveViewController()
            receiveVC.modalPresentationStyle = .fullScreen
            self?.present(receiveVC, animated: true, completion: nil)
        }
        receiveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(receiveButton)
    }
    
    // MARK: - setTopViewConstraints
    func setTopViewConstraints() {
        NSLayoutConstraint.activate([
            // container for top view
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            // eth label
            ethLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ethLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            
            // send button
            sendButton.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -90),
            sendButton.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor, constant: -80),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            sendButton.heightAnchor.constraint(equalToConstant: 100),
            
            // receive button
            receiveButton.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -90),
            receiveButton.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor, constant: 80),
            receiveButton.widthAnchor.constraint(equalToConstant: 100),
            receiveButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: - configurePageVC
    func configurePageVC() {
        let singlePageVC = SinglePageViewController(gallery: "1")
        guard let walletVC = self.parent as? WalletViewController else { return }
        singlePageVC.delegate =  walletVC // wallet view controller for a protocol
        pvc = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.setViewControllers([singlePageVC], direction: .forward, animated: false, completion: nil)
        pvc.dataSource = self
        addChild(pvc)
        view.addSubview(pvc.view)
        pvc.didMove(toParent: self)
        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.6)
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.backgroundColor = .clear
    }
    
    // MARK: - setSinglePageConstraints
    func setSinglePageConstraints() {
        guard let pv = pvc.view else { return }
        NSLayoutConstraint.activate([
            pv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pv.widthAnchor.constraint(equalTo: view.widthAnchor),
            pv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pv.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        
    }
}

extension RegisteredWalletViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let gallery = (viewController as! SinglePageViewController).gallery, var index = galleries.firstIndex(of: gallery) else { return nil }
        index -= 1
        if index < 0 {
            return nil
        }
        return SinglePageViewController(gallery: galleries[index])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let gallery = (viewController as! SinglePageViewController).gallery, var index = galleries.firstIndex(of: gallery) else { return nil }
        index += 1
        if index >= galleries.count {
            return nil
        }
        return SinglePageViewController(gallery: galleries[index])
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.galleries.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let page = pageViewController.viewControllers![0] as! SinglePageViewController
        let gallery = page.gallery!
        return self.galleries.firstIndex(of: gallery)!
    }
}
