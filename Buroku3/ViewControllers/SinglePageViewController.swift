//
//  SinglePageViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//

import UIKit

enum WalletMenu: String {
    case resetPassword = "Reset Password"
    case privateKey = "Private Key"
    case logout = "Logout"
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
    var popup: UIView!
    
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
        addressButton = createButton(title: NSLocalizedString(WalletMenu.resetPassword.rawValue, comment: ""), tag: 1)
        privateKeyButton = createButton(title: NSLocalizedString(WalletMenu.privateKey.rawValue, comment: ""), tag: 2)
        deleteButton = createButton(title: NSLocalizedString(WalletMenu.logout.rawValue, comment: ""), tag: 3)
        
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

        button.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        if title == NSLocalizedString(WalletMenu.logout.rawValue, comment: "") {
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
                // reset password
                let ac = UIAlertController(title: "Reset Password", message: "The password allows you to send Ether or upload files to the blockchain. Please store the new password safely since it cannot be recovered once it's lost", preferredStyle: .alert)
                
                ac.addTextField { (textField: UITextField!) in
                    textField.delegate = self
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Current password"
                }
                
                ac.addTextField { (textField: UITextField!) in
                    textField.delegate = self
                    textField.isSecureTextEntry = true
                    textField.placeholder = "New password"
                }
                
                let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac, weak self](_) in
                    guard let textField = ac.textFields?.first, let oldPassword = textField.text else { return }
                    guard let textField2 = ac.textFields?[1], let newPassword = textField2.text else { return }

                    self?.keyService.resetPassword(oldPassword: oldPassword, newPassword: newPassword) { [weak self](wallet, error) in
                        if let error = error {
                            switch error {
                                case .failureToFetchOldPassword:
                                    self?.alert.show("Error", with: "Sorry, the old password couldn't be fetched", for: self!)
                                case .failureToRegeneratePassword:
                                    self?.alert.show("Error", with: "Sorry, a new password couldn't be generated", for: self!)
                            }
                        }
                        
                        if let wallet = wallet {
                            self?.localDatabase.saveWallet(isRegistered: false, wallet: wallet) { (error) in
                                if let _ = error {
                                    self?.alert.show("Error", with: "Sorry, there was an error generating a new password. Check to see if you're using the correct password.", for: self!)
                                }
                                
                                self?.alert.show("Success", with: "A new password has been generated!", for: self!)
                            }
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                ac.addAction(enterAction)
                ac.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                }

            case 2:
                // show private key
                let ac = UIAlertController(title: "Enter the password", message: nil, preferredStyle: .alert)
                ac.addTextField { (textField: UITextField!) in
                    textField.delegate = self
                }

                let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac, weak self](_) in
                    guard let textField = ac.textFields?.first, let text = textField.text else { return }

                    do {
                        let privateKey = try self?.keyService.getWalletPrivateKey(password: text)
                        let detailVC = DetailViewController(height: 250)
                        detailVC.titleString = "Private Key"
                        detailVC.message = privateKey
                        detailVC.buttonAction = { vc in
                            self?.alert.fading(controller: vc, toBePasted: privateKey ?? "")
                        }
                        self?.present(detailVC, animated: true, completion: nil)
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
                        if let error = error {
                            switch error {
                                case .couldNotDeleteTheWallet:
                                    self?.alert.show("Error", with: "Could not delete the wallet.", for: self!)
                                default:
                                    break
                            }
                        }
                        
                        self?.delegate?.didProcessWallet()
                    }
                    
                    let window = UIApplication.shared.windows.first
                    let walletVC = WalletViewController()
                    window?.rootViewController = walletVC
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            default:
                break
        }
    }
    
    @objc func dismissAlert(){
        if popup != nil {
            popup.removeFromSuperview()
        }
    }
}

extension SinglePageViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - configureActivity
    func configureActivity() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.activityCell)
        tableView.delegate = self
        tableView.dataSource = self
                
        if let transations = localDatabase.getAllTransactionHashes(walletAddress: Web3swiftService.currentAddressString!, predicateName: "transactionType", predicate: TransactionType.etherSent.rawValue) {
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
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Cell.activityCell, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: Cell.activityCell)
        }
        cell.selectionStyle = .none
        
        let transaction = data[indexPath.row]
        cell.textLabel?.text = transaction.transactionHash
        
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .short
        
        cell.detailTextLabel?.text = formatter1.string(from: transaction.date) + " " + formatter2.string(from: transaction.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datum = data[indexPath.row]
        
        let detailVC = DetailViewController(height: 250)
        detailVC.titleString = "Transaction Hash"
        detailVC.message = "\(datum.transactionHash) \n\n * Only displays sent transactions"
        detailVC.buttonAction = { [weak self] vc in
            self?.alert.fading(controller: vc, toBePasted: datum.transactionHash)
        }
        present(detailVC, animated: true, completion: nil)
    }
}
