//
//  TransactionHistoryViewController.swift
//  Buroku3
//
//  Created by J C on 2021-04-04.
//
/*
 Abstract: transaction history on the menu table view
 */

import UIKit

class TransactionHistoryViewController: UITableViewController {
    var data = [TxModel]()
    let localDabase = LocalDatabase()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        fetchData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationBar(color: UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1), bgColor: .white)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        configureNavigationBar(color: .white, bgColor: .clear)
    }
}

extension TransactionHistoryViewController {
    func configureNavigationBar(color: UIColor, bgColor: UIColor) {
        let navigationBar = self.parent!.navigationController?.navigationBar
        navigationBar?.tintColor = color
        navigationBar?.standardAppearance.backgroundColor = bgColor
    }
    
    func fetchData() {
        if let address = Web3swiftService.currentAddressString, let results = localDabase.getAllTransactionHashes(walletAddress: address) {
            data.append(contentsOf: results)
        }
    }
    
    // MARK: - configureTableView
    func configureTableView() {
        tableView.register(TxHistoryCell.self, forCellReuseIdentifier: Cell.txHistoryCell)
        tableView.rowHeight = 100
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.txHistoryCell, for: indexPath) as! TxHistoryCell
        cell.accessoryType = .disclosureIndicator
        let datum = data[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateString = dateFormatter.string(from: datum.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        let timeString = timeFormatter.string(from: datum.date)
        let combined = dateString + " " + timeString
        
        cell.set(txType: datum.transactionType, txHash: datum.transactionHash, date: combined)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datum = data[indexPath.row]
        
        let webVC = WebViewController(navBarTintColor: UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1))
//        webVC.navBarTintColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        webVC.urlString = "https://etherscan.io/tx/" + datum.transactionHash
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}

