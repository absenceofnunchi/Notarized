//
//  FilesTableView.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import BigInt
import web3swift
import Combine
import CoreSpotlight

struct BlockchainData {
    let hash: String
    let size: String
    let date: String
    let index: Int
}

class FilesViewController: UIViewController {
    var tableView: UITableView!
    let transactionService = TransactionService()
    var data = [BlockchainData]()
    let alert = Alerts()
    var pullControl: UIRefreshControl!
    var searchController: UISearchController!
    var searchResultsController: SearchResultsController!
    var anyCancellable = Set<AnyCancellable>()
    
    override func loadView() {
        super.loadView()
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    // MARK: - vidDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureSearchBar()
        configureUI()
        configureTableView()
        setConstraints()
        fetchData()
    }
}

extension FilesViewController {
    // MARK: - fetchData
    func fetchData() {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        
        Deferred {
            Future<ReadTransaction, PostingError> { [weak self] promise in
                self?.transactionService.prepareTransactionForGetFiles(method: .getAllFiles, promise: promise)
            }
            .eraseToAnyPublisher()
        }
        .flatMap({ [weak self] (transaction) -> AnyPublisher<[BlockchainData], PostingError> in
            var dataArr = [BlockchainData]()
            return Future<[BlockchainData], PostingError> { promise in
                DispatchQueue.global().async {
                    do {
                        let results: [String: Any] = try transaction.call()
                        
                        for (_, value) in results {
                            let valueObject = (value as! [[Any]])
                            self?.data.removeAll()
                            
                            for vo in valueObject {
                                if let hash = vo[0] as? String,
                                   let date = vo[1] as? String,
                                   let indexBigInt = vo[3] as? BigUInt,
                                   let _ = vo[2] as? String,
                                   let size = vo[4] as? BigUInt {
                                    let sizeString = String(size)
                                    let index = Int(indexBigInt)
                                    let blockchainData = BlockchainData(hash: hash, size: sizeString, date: date, index: index)
                                    dataArr.append(blockchainData)
                                }
                            }
                        }
                        
                        promise(.success(dataArr))
                    } catch {
                        if let err = error as? Web3Error {
                            promise(.failure(.generalError(reason: err.errorDescription)))
                        } else {
                            promise(.failure(.generalError(reason: "Unable to parse the fetch result.")))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        })
        .sink(receiveCompletion: { [weak self] (completion) in
            self?.activityStopAnimating()
            switch completion {
                case .failure(let error):
                    switch error {
                        case .generalError(reason: let msg):
                            self?.alert.showDetail("Error", with: msg, for: self)
                            break
                        default:
                            self?.alert.showDetail("Error", with: "There was an error fetching data from the blockchain.", for: self)
                    }
                    break
                case .finished:
                    break
            }
        }, receiveValue: { [weak self] (blockchainDataArr) in
            DispatchQueue.main.async {
                self?.data.append(contentsOf: blockchainDataArr)
                self?.tableView.reloadData()
            }
        })
        .store(in: &anyCancellable)
    }
    
    // MARK: - configureUI
    func configureUI() {
//        edgesForExtendedLayout = .all
        edgesForExtendedLayout = .top
        extendedLayoutIncludesOpaqueBars = true
        
        // navigation controller
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            
        } else {
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        // -----------------------------------------------------------
        // NAVIGATION BAR SHADOW
        // -----------------------------------------------------------
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.gray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.navigationController?.navigationBar.layer.shadowRadius = 5
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.7
        
        // title
        title = "Uploaded List"
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - table view delegate and data source
extension FilesViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilesTableViewCell.self, forCellReuseIdentifier: Cell.filesCell)
        tableView.rowHeight = 150
        tableView.separatorStyle = .none
        
        // refresh
        pullControl = UIRefreshControl()
        pullControl.tintColor = .clear
        pullControl.addTarget(self, action: #selector(refreshFetch), for: .valueChanged)
        tableView.refreshControl = pullControl
        tableView.addSubview(pullControl)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filesCell, for: indexPath) as? FilesTableViewCell else {
            fatalError()
        }
        cell.selectionStyle = .none
        
        let datum = data[indexPath.row]
        cell.set(hash: datum.hash, date: datum.date, size: datum.size, name: " ")
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datum = data[indexPath.row]
        let fdvc = FileDetailViewController(data: datum)
        self.navigationController?.pushViewController(fdvc, animated: true)
    }
    
    @objc func refreshFetch() {
        
        fetchData()
        
        delay(1.0) {
            DispatchQueue.main.async {
                self.pullControl.endRefreshing()
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

extension FilesViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    // configure search controller
    func configureSearchController() {
        searchResultsController = SearchResultsController()
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.isActive = true
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func configureSearchBar() {
        // search bar attributes
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.sizeToFit()
        searchBar.tintColor = .black
        searchBar.searchBarStyle = .minimal
        
        // search text field attributes
        let searchTextField = searchBar.searchTextField
        searchTextField.borderStyle = .roundedRect
        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
        searchTextField.textColor = .white
        searchTextField.attributedPlaceholder =  NSAttributedString(string: "Enter IPFS Hash Here", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}

// MARK: - Trailing action
extension FilesViewController: UITextFieldDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextualAction, view, boolValue) in
            self?.alert.withPassword(title: "Delete File", delegate: self!, controller: self!, completion: { (password) in
                if let file = self?.data[indexPath.row] {
                    self?.deleteAction(for: file, password: password)
                }
            })
        }
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
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
                            let detailVC = DetailViewController(height: 200)
                            detailVC.titleString = "Success!"
                            detailVC.message = "Your file has been successfully deleted. It will take about 15 seconds to be reflected."
                            detailVC.buttonAction = { _ in
                                self?.dismiss(animated: true) {
                                    self?.tableView.reloadData()
                                }
                            }
                            self?.present(detailVC, animated: true, completion: nil)
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

extension FilesViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView,contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let datum = data[indexPath.row]
        
        func getPreviewVC(indexPath: IndexPath) -> UIViewController? {
            let webVC = WebViewController()
            webVC.urlString = "https://ipfs.io/ipfs/\(datum.hash)"
            return webVC
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            self?.alert.withPassword(title: "Delete File", delegate: self!, controller: self!, completion: { (password) in
                if let file = self?.data[indexPath.row] {
                    self?.deleteAction(for: file, password: password)
                }
            })
        }
        
        return UIContextMenuConfiguration(identifier: "DetailPreview" as NSString, previewProvider: { getPreviewVC(indexPath: indexPath) }) { _ in
            UIMenu(title: "", children: [delete])
        }
    }
}
