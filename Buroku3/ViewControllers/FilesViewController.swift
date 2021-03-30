//
//  FilesTableView.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit

class FilesViewController: UIViewController {
    var tableView: UITableView!
    let transaction = TransactionService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        configureUI()
        configureTableView()
        setConstraints()
    }
}

extension FilesViewController {
    func fetchData() {
        
        transaction.prepareTransactionForFiles(method: "getAllFiles") { (transaction, error) in
            if let error = error {
                print("getAllFiles error", error)
            }
            
            if let transaction = transaction {
                DispatchQueue.global().async {
                    do {
                        let results = try transaction.call()
                        
                        for (_, value) in results {
                            let hash = (value as! [[AnyObject]])[0][0]
                            let date = (value as! [[AnyObject]])[0][1]
                            print("hash", hash)
                            print("date")
                        }
                        
                    } catch {
                        print("call error", error)
                    }
                }
            }
        }
    }
    
    func configureUI() {
        
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
        ])
    }
}

// MARK: - table view delegate and data source
extension FilesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.fill()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filesCell, for: indexPath) as! FilesTableViewCell
        return cell
    }
}
