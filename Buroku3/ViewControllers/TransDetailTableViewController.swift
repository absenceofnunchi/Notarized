//
//  TransDetailTableViewController.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//

/*
 Abstract: View controller for FileViewController and FileDetailViewController's detail
 */

import UIKit
import BigInt

class TransDetailTableViewController: UITableViewController {
    var data: [ParsedData]!
    
    init(style: UITableView.Style, parsedData: [ParsedData]) {
        super.init(style: style)
        
        self.data = parsedData
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
                let cell = ButtonCell()
                cell.set(with: data[indexPath.section].value)
                cell.selectionStyle = .none
                cell.buttonAction = { [weak self] in
                    let webVC = WebViewController(navBarTintColor: UIColor.white)
                    webVC.navBarTintColor = .white
                    webVC.navBgColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
                    webVC.urlString = "https://etherscan.io/tx/0x\(self?.data[0].value ?? "")"
                    self?.navigationController?.pushViewController(webVC, animated: true)
                }
                return cell
            } else {
                let cell = ButtonCell()
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 7 {
            return 40
        } else {
            return UITableView.automaticDimension
        }
    }
}
