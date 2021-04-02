//
//  TransDetailTableViewController.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//

import UIKit
import web3swift
import BigInt

class TransDetailTableViewController: UITableViewController {
    let localDatabase = LocalDatabase()
    let alert = Alerts()
    var data = [ParsedData]()
    
    init(style: UITableView.Style, hashString: String) {
        super.init(style: style)
        
        fetchTransactionHash(hashString: hashString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
}

extension TransDetailTableViewController {
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.fileDetailCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: Cell.etherscanButtonCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
}

// MARK: - Table view data source
extension TransDetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if data.count > 0 {
            if indexPath.section == 7 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.etherscanButtonCell, for: indexPath) as! ButtonCell
                cell.set(with: data[indexPath.section].value)
                cell.selectionStyle = .none
                cell.buttonAction = { [weak self] in
                    let webVC = WebViewController()
                    webVC.hashString = self?.data[0].value
                    self?.navigationController?.pushViewController(webVC, animated: true)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.fileDetailCell, for: indexPath)
                cell.textLabel?.text = data[indexPath.section].value
                cell.textLabel?.numberOfLines = 0
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if data.count > 0 {
            return data[section].key
        } else {
            return ""
        }
    }
}

extension TransDetailTableViewController {
    // MARK: - fetchTransactionHash
    func fetchTransactionHash(hashString: String) {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        
        if let txHash = localDatabase.getTransactionHash(fileHash: hashString) {
            DispatchQueue.global().async {
                do {
                    let txDetail = try Web3swiftService.web3instance.eth.getTransactionDetails(txHash.transactionHash)
                    
                    self.data.append(contentsOf: [
                        ParsedData(key: "Transaction Hash", value: txDetail.transaction.hash!.toHexString()),
                        ParsedData(key: "Block Hash", value: txDetail.blockHash!.toHexString()),
                        ParsedData(key: "Block Number", value: String(txDetail.blockNumber!)),
                        ParsedData(key: "Gas Price", value: String(txDetail.transaction.gasPrice)),
                        ParsedData(key: "Gas Limit", value: String(txDetail.transaction.gasLimit)),
                        ParsedData(key: "Inferred Chain ID", value: String(txDetail.transaction.inferedChainID!)),
                        ParsedData(key: "Intrinsic Chain ID", value: String(txDetail.transaction.intrinsicChainID!)),
                        ParsedData(key: "", value: "View on Etherscan")
                    ])
                    
                    DispatchQueue.main.async {
                        self.activityStopAnimating()
                        self.tableView.reloadData()
                    }
                    
                } catch Web3Error.nodeError(let desc) {
                    if let index = desc.firstIndex(of: ":") {
                        let newIndex = desc.index(after: index)
                        let newStr = desc[newIndex...]
                        DispatchQueue.main.async {
                            self.activityStopAnimating()
                            self.alert.show("Alert", with: String(newStr), for: self)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.activityStopAnimating()
                        self.alert.show("Error", with: "Sorry, there was an error fetching the transaction detail.", for: self)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.activityStopAnimating()
                
                let alert = UIAlertController(title: "Error", message: "Sorry, there was an error fetching the transaction detail.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { [weak self]_ in
                    self?.navigationController?.popViewController(animated: true)
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
                //        if let popoverController = alert.popoverPresentationController {
                //            popoverController.sourceView = self.view
                //            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                //            popoverController.permittedArrowDirections = []
                //        }
            }
        }
    }
}
