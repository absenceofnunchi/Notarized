//
//  WalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-21.
//

import UIKit
import web3swift

enum WalletMenu: String {
    case address = "Address"
    case privateKey = "Private Key"
    case delete = "Delete Wallet"
}

class WalletViewController: UIViewController {
    let menu: [Menu] = [
        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.address.rawValue, comment: "")),
        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.privateKey.rawValue, comment: "")),
        Menu(symbol: nil, title: NSLocalizedString(WalletMenu.delete.rawValue, comment: ""))
    ]
    
    var rightBarButtonItem: UIBarButtonItem?
    var tableView: UITableView!
    let localDatabase = LocalDatabase()
    let keyService = KeysService()
    let alert = Alerts()
    var wallet: KeyWalletModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        wallet = localDatabase.getWallet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        if wallet != nil {
            configureTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.navigationItem.setRightBarButton(nil, animated: true)
    }
}

extension WalletViewController {
    
    // MARK: - Configure table view
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.walletCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.fill()
    }

    // MARK: - Configure Navigation Item
    func configureNavigationItem() {
        rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.stack.badge.plus"), style: .plain, target: self, action: #selector(buttonHandler))
        self.parent?.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }

    // MARK: - ConfigureUI
    /// If the user doesn't have a wallet
    func configureUI() {
        
    }
    
    func setConstraints() {
        
    }
    
    @objc func buttonHandler() {
        let createWalletVC = CreateWalletViewController()
        self.navigationController?.pushViewController(createWalletVC, animated: true)
    }
}

// MARK:- Table view datasource
extension WalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.walletCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        let title = menu[indexPath.row].title
        cell.textLabel?.text = title
        
        if title == NSLocalizedString(WalletMenu.delete.rawValue, comment: "") {
            cell.textLabel?.textColor = .red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Wallet"
    }
}

// MARK: - Table view delegate
extension WalletViewController: UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = menu[indexPath.row].title
        let detailVC = DetailViewController()

        switch title {
            case NSLocalizedString(WalletMenu.address.rawValue, comment: ""):
                guard let address = wallet?.address else {
                    alert.show("No wallet available", with: "Create a new wallet", for: self)
                    return
                }
                detailVC.title = "Address"
                detailVC.info = address
                self.navigationController?.pushViewController(detailVC, animated: true)
            case NSLocalizedString(WalletMenu.privateKey.rawValue, comment: ""):
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
            case NSLocalizedString(WalletMenu.delete.rawValue, comment: ""):
                let ac = UIAlertController(title: "Delete Wallet", message: "Are you sure you want to delete your wallet?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self](_) in
                    self?.localDatabase.deleteWallet { [weak self](error) in
                        self?.alert.show(error, for: self!)
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            default:
                break
        }
    }
}
