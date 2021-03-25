////
////  WalletViewController.swift
////  Buroku3
////
////  Created by J C on 2021-03-21.
////
//
//import UIKit
//import web3swift
//
//enum WalletMenu: String {
//    case address = "Address"
//    case privateKey = "Private Key"
//    case delete = "Delete Wallet"
//}
//
//class WalletViewController: UIViewController {
//    let menu: [Menu] = [
//        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.address.rawValue, comment: "")),
//        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.privateKey.rawValue, comment: "")),
//        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.delete.rawValue, comment: ""))
//    ]
//    
//    var rightBarButtonItem: UIBarButtonItem?
//    var tableView: UITableView!
//    let localDatabase = LocalDatabase()
//    let keyService = KeysService()
//    let alert = Alerts()
//    var wallet: KeyWalletModel?
//    var backgroundView: BackgroundView2!
//    var containerView: UIView!
//    var createWalletButton: UIButton!
//    var importWalletButton: UIButton!
//    var walletLogoImageView: UIImageView!
//    var imageContainerView: UIView!
//    var backgroundAnimator: UIViewPropertyAnimator!
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        
//        wallet = localDatabase.getWallet()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func loadView() {
//        super.loadView()
//        
//        if wallet != nil {
//            configureTableView()
//        } else {
//            configureUI()
//            setConstraints()
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        configureNavigationItem()
//        
//        if wallet == nil {
//            UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, animations: {
//                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
//                    self.containerView.transform = .identity
//                }
//                
//                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
//                    self.backgroundView.transform = .identity
//                }
//            },
//            completion: nil
//            )
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.parent?.navigationItem.setRightBarButton(nil, animated: true)
//        
//        if wallet == nil {
//            UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
//                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
//                    self.backgroundView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
//                }
//                
//                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
//                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
//                }
//            },
//            completion: nil
//            )
//        }
//    }
//}
//
//extension WalletViewController {
//    
//    // MARK: - Configure table view
//    func configureTableView() {
//        tableView = UITableView(frame: .zero, style: .insetGrouped)
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.walletCell)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.fill()
//    }
//    
//    // MARK: - Configure Navigation Item
//    func configureNavigationItem() {
//        rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.stack.badge.plus"), style: .plain, target: self, action: #selector(buttonHandler))
//        rightBarButtonItem?.tag = 1
//        self.parent?.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
//    }
//    
//    // MARK: - ConfigureUI
//    /// If the user doesn't have a wallet
//    func configureUI() {
//        backgroundView = BackgroundView2()
//        view.addSubview(backgroundView)
//        backgroundView.fill()
//        
//        containerView = UIView()
//        containerView.layer.cornerRadius = 20
//        containerView.layer.shadowColor = UIColor.gray.cgColor
//        containerView.layer.shadowOpacity = 0.3
//        containerView.layer.shadowOffset = CGSize.zero
//        containerView.layer.shadowRadius = 6
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(containerView)
//        
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = containerView.bounds
//        blurEffectView.layer.cornerRadius = 20
//        blurEffectView.clipsToBounds = true
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        containerView.addSubview(blurEffectView)
//        
//        imageContainerView = UIView()
//        imageContainerView.backgroundColor = .black
//        imageContainerView.layer.cornerRadius = 15
//        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(imageContainerView)
//        
//        let configuration = UIImage.SymbolConfiguration(pointSize: 10, weight: .light)
//        let image = UIImage(systemName: "wallet.pass", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
//        walletLogoImageView = UIImageView(image: image)
//        walletLogoImageView.backgroundColor = .black
//        walletLogoImageView.layer.cornerRadius = 15
//        walletLogoImageView.translatesAutoresizingMaskIntoConstraints = false
//        imageContainerView.addSubview(walletLogoImageView)
//        
//        createWalletButton = UIButton()
//        createWalletButton.backgroundColor = .black
//        createWalletButton.layer.cornerRadius = 15
//        createWalletButton.setTitle("Create Wallet", for: .normal)
//        createWalletButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
//        createWalletButton.tag = 2
//        createWalletButton.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(createWalletButton)
//        
//        importWalletButton = UIButton()
//        importWalletButton.backgroundColor = .black
//        importWalletButton.layer.cornerRadius = 15
//        importWalletButton.setTitle("Import Wallet", for: .normal)
//        importWalletButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
//        importWalletButton.tag = 3
//        importWalletButton.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(importWalletButton)
//    }
//    
//    func setConstraints() {
//        NSLayoutConstraint.activate([
//            // container view
//            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.2),
//            
//            imageContainerView.widthAnchor.constraint(equalToConstant: 50),
//            imageContainerView.heightAnchor.constraint(equalToConstant: 50),
//            imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
//            imageContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            
//            // wallet logo
//            walletLogoImageView.widthAnchor.constraint(equalToConstant: 25),
//            walletLogoImageView.heightAnchor.constraint(equalToConstant: 25),
//            walletLogoImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
//            walletLogoImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
//            
//            // create wallet button
//            createWalletButton.bottomAnchor.constraint(equalTo: importWalletButton.topAnchor, constant: -50),
//            createWalletButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
//            createWalletButton.heightAnchor.constraint(equalToConstant: 50),
//            createWalletButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            
//            // import wallet button
//            importWalletButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -50),
//            importWalletButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
//            importWalletButton.heightAnchor.constraint(equalToConstant: 50),
//            importWalletButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//        ])
//    }
//    
//    @objc func buttonHandler(_ sender: UIButton!) {
//        switch sender.tag {
//            case 1:
//                let createWalletVC = CreateWalletViewController()
//                self.navigationController?.pushViewController(createWalletVC, animated: true)
//            case 2:
//                let createWalletVC = CreateWalletViewController()
//                createWalletVC.modalPresentationStyle = .fullScreen
//                present(createWalletVC, animated: true)
//            case 3:
//                let createWalletVC = CreateWalletViewController()
//                createWalletVC.modalPresentationStyle = .fullScreen
//                present(createWalletVC, animated: true)
//            default:
//                break
//        }
//        
//    }
//}
//
//// MARK:- Table view datasource
//extension WalletViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return menu.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.walletCell, for: indexPath)
//        cell.accessoryType = .disclosureIndicator
//        cell.selectionStyle = .none
//        
//        let title = menu[indexPath.row].title
//        cell.textLabel?.text = title
//        
//        if title == NSLocalizedString(WalletMenu.delete.rawValue, comment: "") {
//            cell.textLabel?.textColor = .red
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Wallet"
//    }
//}
//
//// MARK: - Table view delegate
//extension WalletViewController: UITableViewDelegate, UITextFieldDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let title = menu[indexPath.row].title
//        let detailVC = DetailViewController()
//        
//        switch title {
//            case NSLocalizedString(WalletMenu.address.rawValue, comment: ""):
//                guard let address = wallet?.address else {
//                    alert.show("No wallet available", with: "Create a new wallet", for: self)
//                    return
//                }
//                detailVC.title = "Address"
//                detailVC.info = address
//                self.navigationController?.pushViewController(detailVC, animated: true)
//            case NSLocalizedString(WalletMenu.privateKey.rawValue, comment: ""):
//                let ac = UIAlertController(title: "Enter the password", message: nil, preferredStyle: .alert)
//                ac.addTextField { (textField: UITextField!) in
//                    textField.delegate = self
//                }
//                
//                let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac, weak self](_) in
//                    guard let textField = ac.textFields?.first, let text = textField.text else { return }
//                    
//                    do {
//                        let privateKey = try self?.keyService.getWalletPrivateKey(password: text)
//                        print("private key", privateKey)
//                    } catch {
//                        self?.alert.show("Wrong password", with: nil, for: self!)
//                    }
//                }
//                
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//                
//                ac.addAction(enterAction)
//                ac.addAction(cancelAction)
//                self.present(ac, animated: true, completion: nil)
//            case NSLocalizedString(WalletMenu.delete.rawValue, comment: ""):
//                let ac = UIAlertController(title: "Delete Wallet", message: "Are you sure you want to delete your wallet?", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self](_) in
//                    self?.localDatabase.deleteWallet { [weak self](error) in
//                        self?.alert.show(error, for: self!)
//                    }
//                }))
//                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                self.present(ac, animated: true, completion: nil)
//            default:
//                break
//        }
//    }
//}
