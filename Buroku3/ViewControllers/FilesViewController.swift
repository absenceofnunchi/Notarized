//
//  FilesTableView.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import BigInt

struct BlockchainData {
    let hash: String
    let date: String
    let size: String
    let name: String
}

class FilesViewController: UIViewController {
    var tableView: UITableView!
    let transaction = TransactionService()
    var data = [BlockchainData]()
    let alert = Alerts()
    var pullControl: UIRefreshControl!
    var searchController: UISearchController!
    var searchResultsController: SearchResultsController!

    // MARK: - init
    init() {
        super.init(nibName: nil, bundle: nil)
//        tableView = UITableView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//        tableView.fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.fill()
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
        transaction.prepareTransactionForFiles(method: "getAllFiles") { [weak self] (transaction, error) in
            if let error = error {
                print("getAllFiles error", error)
            }

            if let transaction = transaction {
                DispatchQueue.global().async {
                    do {
                        let results = try transaction.call()
                                                
                        for (_, value) in results {
                            let valueObject = (value as! [[Any]])
                            
                            for vo in valueObject {
                                if let hash = vo[0] as? String,
                                   let date = vo[1] as? String,
                                   let name = vo[5] as? String,
                                   let size = vo[4] as? BigUInt {
                                    let sizeString = String(size)
                                    let bd = BlockchainData(hash: hash, date: date, size: sizeString, name: name)
                                    print("bd", bd)
                                    self?.data.append(bd)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    } catch {
                        self?.alert.show("Error", with: "There was an error retrieving data from the blockchain.", for: self!)
                    }
                }
            }
        }
    }
    
    // MARK: - configureUI
    func configureUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
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
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
//            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - table view delegate and data source
extension FilesViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilesTableViewCell.self, forCellReuseIdentifier: Cell.filesCell)
        tableView.rowHeight = 200
        tableView.separatorStyle = .none
        
        // refresh
        pullControl = UIRefreshControl()
        pullControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filesCell, for: indexPath) as! FilesTableViewCell
        cell.selectionStyle = .none
        
        let datum = data[indexPath.row]
        cell.set(hash: datum.hash, date: datum.date, size: datum.size, name: datum.name)
            
        return cell
    }
    
    @objc func refreshFetch() {
        
        data.removeAll()
        fetchData()
        
        delay(1.0) {
            self.pullControl.endRefreshing()
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
        searchTextField.attributedPlaceholder =  NSAttributedString(string: "Enter Search Here", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}
