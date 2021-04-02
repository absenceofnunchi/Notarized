//
//  FileDetailViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-31.
//

import UIKit

struct ParsedData {
    let key: String
    let value: String
}

class FileDetailViewController: UITableViewController {
    var data: BlockchainData!
    var parsedData = [ParsedData]()
    
    init(data: BlockchainData) {
        super.init(style: .insetGrouped)
        
        self.data = data

        let mirror = Mirror(reflecting: data)
        for child in mirror.children {
            
            let pd = ParsedData(key: child.label!, value: child.value as! String)
            parsedData.append(pd)
        }
        
        let buttonCell = ParsedData(key: "", value: "View Transaction Details")
        parsedData.append(buttonCell)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
}

extension FileDetailViewController {
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.fileDetailCell)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: Cell.buttonCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
}

// MARK: - table view delegate and data source
extension FileDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.buttonCell, for: indexPath) as! ButtonCell
            cell.set(with: parsedData[indexPath.section].value)
            cell.buttonAction = { [weak self] in
                guard let hash = self?.data.hash else { return }
                let transDetailVC = TransDetailTableViewController(style: .insetGrouped, hashString: hash)
                self?.navigationController?.pushViewController(transDetailVC, animated: true)
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
        return parsedData[section].key
    }
}
