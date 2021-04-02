//
//  SearchResultsController.swift
//  Buroku3
//
//  Created by J C on 2021-03-31.
//

import UIKit

class SearchResultsController: UITableViewController {
    var data: [BlockchainData]!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
}

extension SearchResultsController {
    func configureTableView() {
        tableView.register(FilesTableViewCell.self, forCellReuseIdentifier: Cell.filesCell)
        tableView.rowHeight = 200
        tableView.separatorStyle = .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filesCell, for: indexPath) as! FilesTableViewCell
        cell.selectionStyle = .none
        
        let datum = data[indexPath.row]
        cell.set(hash: datum.hash, date: datum.date, size: datum.size, name: datum.name)
        
        return cell
    }
}


extension UISearchController {
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let presentingVC = self.presentingViewController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view.frame = presentingVC.view.frame
            }
        }
    }
}
