//
//  UnregisteredWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//

import UIKit

class UnregisteredWalletViewController: UIViewController {
    var backgroundView = BackgroundView2()
    var containerView: UIView!
    var createWalletButton: UIButton!
    var importWalletButton: UIButton!
    var walletLogoImageView: UIImageView!
    var imageContainerView: UIView!
    var backgroundAnimator: UIViewPropertyAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        configureUI()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.containerView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                self.backgroundView.transform = .identity
            }
        },
        completion: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.backgroundView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            }
        },
        completion: nil
        )
    }
}

extension UnregisteredWalletViewController {
    // MARK: - ConfigureUI
    /// If the user doesn't have a wallet
    func configureUI() {
        view.addSubview(backgroundView)
        backgroundView.fill()
        
        containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = containerView.bounds
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurEffectView)
        
        imageContainerView = UIView()
        imageContainerView.backgroundColor = .black
        imageContainerView.layer.cornerRadius = 15
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageContainerView)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 10, weight: .light)
        let image = UIImage(systemName: "wallet.pass", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        walletLogoImageView = UIImageView(image: image)
        walletLogoImageView.backgroundColor = .black
        walletLogoImageView.layer.cornerRadius = 15
        walletLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.addSubview(walletLogoImageView)
        
        createWalletButton = UIButton()
        createWalletButton.backgroundColor = .black
        createWalletButton.layer.cornerRadius = 15
        createWalletButton.setTitle("Create Wallet", for: .normal)
        createWalletButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        createWalletButton.tag = 2
        createWalletButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(createWalletButton)
        
        importWalletButton = UIButton()
        importWalletButton.backgroundColor = .black
        importWalletButton.layer.cornerRadius = 15
        importWalletButton.setTitle("Import Wallet", for: .normal)
        importWalletButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        importWalletButton.tag = 3
        importWalletButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(importWalletButton)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.2),
            
            imageContainerView.widthAnchor.constraint(equalToConstant: 50),
            imageContainerView.heightAnchor.constraint(equalToConstant: 50),
            imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
            imageContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // wallet logo
            walletLogoImageView.widthAnchor.constraint(equalToConstant: 25),
            walletLogoImageView.heightAnchor.constraint(equalToConstant: 25),
            walletLogoImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            walletLogoImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            
            // create wallet button
            createWalletButton.bottomAnchor.constraint(equalTo: importWalletButton.topAnchor, constant: -50),
            createWalletButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            createWalletButton.heightAnchor.constraint(equalToConstant: 50),
            createWalletButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // import wallet button
            importWalletButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -50),
            importWalletButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            importWalletButton.heightAnchor.constraint(equalToConstant: 50),
            importWalletButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        switch sender.tag {
            case 1:
                let createWalletVC = CreateWalletViewController()
                self.navigationController?.pushViewController(createWalletVC, animated: true)
            case 2:
                let createWalletVC = CreateWalletViewController()
                let delegateVC = self.parent as! WalletViewController
                createWalletVC.delegate = delegateVC
                createWalletVC.modalPresentationStyle = .fullScreen
                present(createWalletVC, animated: true)
            case 3:
                let createWalletVC = CreateWalletViewController()
                createWalletVC.modalPresentationStyle = .fullScreen
                present(createWalletVC, animated: true)
            default:
                break
        }
        
    }
}
