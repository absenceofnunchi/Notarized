//
//  FileDetailViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-31.
//

import UIKit
import web3swift
import CoreSpotlight

struct ParsedData {
    let key: String
    let value: String
}

class FileDetailViewController: UITableViewController {
    var data: BlockchainData!
    var parsedData = [ParsedData]()
    let localDatabase = LocalDatabase()
    let alert = Alerts()
    let transactionService = TransactionService()

    init(data: BlockchainData) {
        super.init(style: .insetGrouped)
        
        self.data = data

        let mirror = Mirror(reflecting: data)
        print("mirror", mirror)
        for child in mirror.children {
            print("child", child)
            var pd: ParsedData!
            if child.label == "index" {
                continue
            } else {
                guard let label = child.label,
                        let value = child.value as? String else {
                    return
                }
                pd = ParsedData(key: label, value: value)
            }
            
            parsedData.append(pd)
        }
        print("parsedData", parsedData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureNavigationBar(isVisible: false)
    }
}

extension FileDetailViewController {
    func configureNavigationBar(isVisible: Bool = true) {
        let navItem = rootViewController.children[0].navigationItem
        if isVisible {
            if #available(iOS 14, *) {
                let barButtonMenu = UIMenu(title: "", image: nil, children: [
                    UIAction(title: NSLocalizedString("Share the Hash", comment: ""), image: nil,handler: menuHandler(action:)),
                    UIAction(title: NSLocalizedString("Share IPFS", comment: ""), image: nil, handler: menuHandler(action:))
                ])
                navItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "square.and.arrow.up"), primaryAction: nil, menu: barButtonMenu)
            } else {
                navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
            }
        } else {
            navItem.setRightBarButtonItems(nil, animated: true)
//            if #available(iOS 14, *) {
//                navItem.rightBarButtonItem?.menu = nil
//            } else {
//                navItem.rightBarButtonItem = nil
//            }
        }
    }
    
    func menuHandler(action: UIAction) {
        switch action.title {
            case NSLocalizedString("Share the hash", comment: ""):
                activityVC(activityItem: self.data.hash)
            case NSLocalizedString("Share IPFS", comment: ""):
                activityVC(activityItem: "https://ipfs.io/ipfs/\(self.data.hash)")
            default:
                break
        }
        Swift.debugPrint("Menu handler: \(action.title)")
    }
    
    @objc func sharePressed() {
        activityVC(activityItem: "https://ipfs.io/ipfs/\(self.data.hash)")
    }
    
    func activityVC(activityItem: String) {
        let shareSheetVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        self.present(shareSheetVC, animated: true, completion: nil)
        if let pop = shareSheetVC.popoverPresentationController {
            pop.sourceView = self.view
            //                pop.sourceRect = CGRect(x: self?.view.bounds.midX, y: self?.view.bounds.height, width: 0, height: 0)
            pop.permittedArrowDirections = []
        }
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.fileDetailCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: Cell.buttonCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
}

// MARK: - table view delegate and data source
extension FileDetailViewController: UITextFieldDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            let cell = GroupedButtonsCell()
            
            var previewImage: UIImage!
            let detailImage = UIImage(systemName: "doc.text.magnifyingglass")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            let deleteImage = UIImage(systemName: "trash")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            
            if #available(iOS 14.0, *) {
                previewImage = UIImage(systemName: "display")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            } else {
                previewImage = UIImage(systemName: "tv")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            }
            
            let buttonContentArr = [
                ButtonContent(title: "Preview", image: previewImage),
                ButtonContent(title: "Details", image: detailImage),
                ButtonContent(title: "Delete", image: deleteImage, bgColor: .red)
            ]
            
            cell.set(with: buttonContentArr)
            cell.buttonAction = { [weak self] (tag) in                
                switch tag {
                    case 0:
                        let webVC = WebViewController()
                        webVC.urlString = "https://ipfs.io/ipfs/\(self?.data.hash ?? "")"
                        self?.present(webVC, animated: true, completion: nil)
                    case 1:
                        guard let hash = self?.data.hash else { return }
                        self?.fetchTransactionHash(hashString: hash)
                    case 2:
                        self?.alert.withPassword(title: "Delete File", delegate: self!, controller: self!, completion: { (password) in
                            if let data = self?.data {
                                self?.deleteAction(for: data, password: password)
                            }
                        })
                    default:
                        break
                }
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.fileDetailCell, for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = parsedData[indexPath.section].value
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < 3 {
            return parsedData[section].key
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 70
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension FileDetailViewController {
    // MARK: - fetchTransactionHash
    func fetchTransactionHash(hashString: String) {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        
        if let txHash = localDatabase.getTransactionHash(fileHash: hashString) {
            DispatchQueue.global().async {
                do {
                    let txDetail = try Web3swiftService.web3instance.eth.getTransactionDetails(txHash.transactionHash)
                    self.parsedData.removeAll()
                    self.parsedData.append(contentsOf: [
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
                        
                        let transDetailVC = TransDetailTableViewController(style: .insetGrouped, parsedData: self.parsedData)
                        self.navigationController?.pushViewController(transDetailVC, animated: true)
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
                let webVC = WebViewController()
                webVC.urlString = "https://etherscan.io/tx/0x\(self.data.hash)"
                self.present(webVC, animated: true, completion: nil)
                
                
//                let alert = UIAlertController(title: "Error", message: "Sorry, there was an error fetching the transaction detail.", preferredStyle: .alert)
//                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { [weak self]_ in
//                    self?.navigationController?.popViewController(animated: true)
//                })
//                alert.addAction(cancelAction)
//                self.present(alert, animated: true, completion: nil)
                
                //        if let popoverController = alert.popoverPresentationController {
                //            popoverController.sourceView = self.view
                //            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                //            popoverController.permittedArrowDirections = []
                //        }
            }
        }
    }
}

// MARK: - deleteAction
extension FileDetailViewController {
    func deleteAction(for file: BlockchainData, password: String) {
        transactionService.prepareTransactionForDeletingFiles(method: "deleteFile", parameters: [file.index] as [AnyObject]) { [weak self](transaction, error) in
            if let error = error {
                switch error {
                    case .contractLoadingError:
                        self?.alert.show("Error", with: "There was an error loading a contract. Please try again.", for: self!)
                    case .createTransactionIssue:
                        self?.alert.show("Error", with: "There was an error creating your transaction. Please try again.", for: self!)
                    case .insufficientFund:
                        self?.alert.show("Error", with: "Insufficient fund", for: self!)
                    default:
                        self?.alert.show("Error", with: "Please try again.", for: self!)
                }
            }
            
            if let transaction = transaction {
                DispatchQueue.global().async {
                    do {
                        let _ = try transaction.send(password: password, transactionOptions: nil)
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        
                        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(file.hash)"]) { (error) in
                            if let error = error {
                                print("Deindexing error: \(error.localizedDescription)")
                            } else {
                                print("File successfully deindexed")
                            }
                        }
                    } catch Web3Error.nodeError(let desc) {
                        if let index = desc.firstIndex(of: ":") {
                            let newIndex = desc.index(after: index)
                            let newStr = desc[newIndex...]
                            DispatchQueue.main.async {
                                self?.alert.show("Alert", with: String(newStr), for: self!)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self?.alert.show("Error", with: "Sorry, there was an error deleting your file. Please verify that your password is correct or you have enough Ether in your wallet.", for: self!)
                        }
                    }
                }
            }
        }
    }
}
