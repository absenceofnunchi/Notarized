//
//  MenuTableVC.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit

class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var customTableView: UITableView!
    var docImage: UIImage {
        var imageName: String!
        if #available(iOS 14, *) {
            imageName = "doc.badge.gearshape"
        } else {
            imageName = "doc.plaintext"
        }
        return UIImage(systemName: imageName)!
    }
    
    lazy var allMenu: [Menu] = [
        Menu(symbol: UIImage(systemName: "paperplane")!.withRenderingMode(.alwaysOriginal), title: "Upload Files"),
        Menu(symbol: UIImage(systemName: "square.stack.3d.up")!.withRenderingMode(.alwaysOriginal), title: "Files on Blockchain"),
        Menu(symbol: UIImage(systemName: "creditcard")!.withRenderingMode(.alwaysOriginal), title: "Wallet"),
        Menu(symbol: UIImage(systemName: "eye")!.withRenderingMode(.alwaysOriginal), title: "View on Etherscan"),
//        Menu(symbol: UIImage(systemName: "list.bullet")!.withRenderingMode(.alwaysOriginal), title: "Transaction History"),
        Menu(symbol: self.docImage.withRenderingMode(.alwaysOriginal), title: "Terms of Service")
    ]
    var didTapMenuType: ((MenuType) -> Void)?
    weak var delegate: ContainerDelegate?
    
    override func loadView() {
        customTableView = UITableView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)), style: .plain)
        customTableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        customTableView.backgroundColor = .systemBackground
        customTableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        view = customTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        customTableView.separatorStyle = .none
        customTableView.isScrollEnabled = false
        
        customTableView.delegate = self
        customTableView.dataSource = self

    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let menu = allMenu[indexPath.row]
        cell.imageView!.image = menu.symbol
        cell.textLabel!.text = menu.title
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        delegate?.didSelectVC(menuType)
        
//        if indexPath.row >= 0 && indexPath.row < 5 {
//
//        } else {
//            delegate?.didSelectETCMenu(indexPath.row)
//        }
    }
}
