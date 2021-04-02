//
//  SinglePageViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//

import UIKit

enum WalletMenu: String {
    case address = "Address"
    case privateKey = "Private Key"
    case delete = "Delete Wallet"
}

class SinglePageViewController: UIViewController {
    var gallery: String!
    var containerView: UIView!
    var constraints = [NSLayoutConstraint]()
    var addressButton: UIButton!
    var privateKeyButton: UIButton!
    var deleteButton: UIButton!
    var stackView: UIStackView!
    let alert = Alerts()
    var wallet: KeyWalletModel!
    let localDatabase = LocalDatabase()
    let keyService = KeysService()
    var delegate: WalletDelegate?
    var tableView: UITableView!
    var data: [TxModel]!
    
    init(gallery: String) {
        self.gallery = gallery
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - loadView
    override func loadView() {
        super.loadView()
        
        if gallery == "2" {
            tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if gallery == "1" {
            configureSettings()
            setSettingsContraints()
        } else {
            configureActivity()
            setActivityConstriants()
        }
    }
}

extension SinglePageViewController: UITextFieldDelegate {
    func configureSettings() {
        wallet = localDatabase.getWallet()
        
        // container view
        containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = containerView.bounds
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurEffectView)
        
        // buttons
        addressButton = createButton(title: NSLocalizedString(WalletMenu.address.rawValue, comment: ""), tag: 1)
        privateKeyButton = createButton(title: NSLocalizedString(WalletMenu.privateKey.rawValue, comment: ""), tag: 2)
        deleteButton = createButton(title: NSLocalizedString(WalletMenu.delete.rawValue, comment: ""), tag: 3)
        
        // stack view
        stackView = UIStackView(arrangedSubviews: [addressButton, privateKeyButton, deleteButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
    }
    
    func setSettingsContraints() {
        NSLayoutConstraint.deactivate(constraints)
        
        constraints.append(contentsOf: [
            // container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            // stack view
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8)
        ])
        NSLayoutConstraint.activate(constraints)
    }
    
    func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton()

//        button.backgroundColor = UIColor(red: 167/255, green: 197/255, blue: 235/255, alpha: 1)
        button.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)

        if title == NSLocalizedString(WalletMenu.delete.rawValue, comment: "") {
//            button.backgroundColor = UIColor(red: 255/255, green: 85/255, blue: 73/255, alpha: 1)
//            button.titleLabel?.textColor = UIColor(red: 255/255, green: 85/255, blue: 73/255, alpha: 1)
            button.setTitleColor(UIColor(red: 255/255, green: 85/255, blue: 73/255, alpha: 1), for: .normal)
            
        } else {
//            button.backgroundColor = UIColor(red: 74/255, green: 71/255, blue: 163/255, alpha: 1)
//            button.backgroundColor = UIColor(red: 167/255, green: 197/255, blue: 235/255, alpha: 1)
        }
        
        button.layer.cornerRadius = 8
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        button.tag = tag
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch sender.tag {
            case 1:
                guard let address = wallet?.address else {
                    alert.show("No wallet available", with: "Create a new wallet", for: self)
                    return
                }
                let detailVC = DetailViewController()
                detailVC.title = "Address"
                detailVC.info = address
                self.present(detailVC, animated: true)
            case 2:
                let ac = UIAlertController(title: "Enter the password", message: nil, preferredStyle: .alert)
                ac.addTextField { (textField: UITextField!) in
                    textField.delegate = self
                }

                let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac, weak self](_) in
                    guard let textField = ac.textFields?.first, let text = textField.text else { return }

                    do {
                        let privateKey = try self?.keyService.getWalletPrivateKey(password: text)
                        print("private key", privateKey)
                    } catch {
                        self?.alert.show("Wrong password", with: nil, for: self!)
                    }
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

                ac.addAction(enterAction)
                ac.addAction(cancelAction)
                self.present(ac, animated: true, completion: nil)
            case 3:
                let ac = UIAlertController(title: "Delete Wallet", message: "Are you sure you want to delete your wallet?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self](_) in
                    
                    self?.localDatabase.deleteWallet { [weak self](error) in
                        self?.delegate?.didProcessWallet()
                    }
                    
//                    let rootVC = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
//                    let childVC = rootVC.viewControllers[0]
//                    for case let vc as WalletViewController in childVC.children {
//                    }

                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            default:
                break
        }
    }
}

extension SinglePageViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - configureActivity
    func configureActivity() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.activityCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        if let transations = localDatabase.getAllTransactionHashes() {
            data = transations
        }
    }
    
    // MARK: - setActivityConstraints
    func setActivityConstriants() {
        NSLayoutConstraint.deactivate(constraints)
        constraints.append(contentsOf: [
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        NSLayoutConstraint.activate(constraints)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.activityCell, for: indexPath)
//        let transaction = data[indexPath.row]
        
        return cell
    }
    
}
