//
//  TxHistoryCell.swift
//  Buroku3
//
//  Created by J C on 2021-04-05.
//

import UIKit

class TxHistoryCell: UITableViewCell {
    var txHashLabel: UILabel!
    var txTypeLabel: UILabel!
    var dateLabel: UILabel!
    var lineView: LineView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension TxHistoryCell {
    func set(txType: String, txHash: String, date: String) {
        let mas = NSMutableAttributedString(string: " \(txType)", attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
        
        var imageName: String!
        
        switch TransactionType(rawValue: txType) {
            case .imageUploaded:
                imageName = "photo"
            case .docUploaded:
                imageName = "doc"
            case .etherSent:
                imageName = "square.stack"
            default:
                imageName = "photo"
        }
                
        let clockImage = UIImage(systemName: imageName)!.withRenderingMode(.alwaysOriginal).withTintColor(.green)
        let clock = NSTextAttachment(image:clockImage)
        let iconsSize = CGRect(x: CGFloat(0),
                               y: -4,
                               width: mas.size().height,
                               height: mas.size().height)
        clock.bounds = iconsSize
        let clockChar = NSAttributedString(attachment:clock)
        mas.insert(clockChar, at:0)
        
        txTypeLabel.attributedText = mas
        txHashLabel.text = "Transaction Hash: " + txHash
        dateLabel.text = date
    }
    
    func configure() {
        txHashLabel = UILabel()
        txHashLabel.font = UIFont.preferredFont(forTextStyle: .body)
        txHashLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(txHashLabel)
        
        lineView = LineView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineView)
        lineView.setNeedsDisplay()
        
        txTypeLabel = UILabel()
        txTypeLabel.sizeToFit()
        txTypeLabel.textColor = .systemGreen
        txTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(txTypeLabel)
        
        dateLabel = UILabel()
        dateLabel.sizeToFit()
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            txHashLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            txHashLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            txHashLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
//            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            lineView.heightAnchor.constraint(equalToConstant: 1),
//            lineView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            txTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            txTypeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 20),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 20),
        ])
    }
}
