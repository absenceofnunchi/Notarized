//
//  CreateWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import UIKit

class SettingsViewController: UIViewController {
    let menu: [Menu] = [
        Menu(symbol: nil, title: "Wallet"),
        Menu(symbol: nil, title: "Settings")
    ]
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func loadView() {
        let v = UIView()
        v.backgroundColor = UIColor.secondarySystemGroupedBackground
        v.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
}

extension SettingsViewController {
    func setConstraints() {
        
    }
}

// MARK: - Configure table view
extension SettingsViewController {
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.walletCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.fill()
    }
}

// MARK:- Table view datasource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.walletCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = menu[indexPath.section].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
}

// MARK: - Table view delegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = menu[indexPath.row].title
        
        switch title {
            case "Wallet":
                let createWalletVC = SettingsViewController()
                present(createWalletVC, animated: true, completion: nil)
            default:
                break
        }
    }
}
