//
//  FilesTableViewCell.swift
//  Buroku3
//
//  Created by J C on 2021-03-30.
//

import UIKit

class FilesTableViewCell: UITableViewCell {
    var containerView: UIView!
    var hashLabel: UILabel!
    var dateLabel: UILabel!
    var sizeLabel: UILabel!
    var nameLabel: UILabel!
    var lineView: LineView!
    var mas: NSMutableAttributedString!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
//        for subview in subviews where (subview != contentView && abs(subview.frame.width - frame.width) <= 0.1 && subview.frame.height < 2) {
//            subview.removeFromSuperview()                           //option #1 -- remove the line completely
//            //subview.frame = subview.frame.insetBy(dx: 16, dy: 0)  //option #2 -- modify the length
//        }
    }
}

extension FilesTableViewCell {
    func configure() {
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.dropShadow()
        containerView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        contentView.addSubview(containerView)
        
        nameLabel = createlabel(in: containerView, with: .black)
        hashLabel = createlabel(in: containerView)
        sizeLabel = createlabel(in: containerView)
        
        lineView = LineView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(lineView)
        lineView.setNeedsDisplay()

        dateLabel = createlabel(in: containerView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            // name label
            nameLabel.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/5),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),

            // hash label
            hashLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor, constant: 3),
            hashLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            hashLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/5),
            hashLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),

            // size label
            sizeLabel.topAnchor.constraint(equalTo: hashLabel.layoutMarginsGuide.bottomAnchor, constant: 3),
            sizeLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            sizeLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/5),
            sizeLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),

            // line view
            lineView.bottomAnchor.constraint(equalTo: dateLabel.layoutMarginsGuide.topAnchor, constant: -10),
            lineView.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            // date label
            dateLabel.bottomAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor, constant: -5),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            dateLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/5),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    func set(hash: String, date: String, size: String, name: String) {
        hashLabel.text = "Hash: \(hash)"
        sizeLabel.text = "Size: \(size)"
        nameLabel.text = name
        
        let mas = NSMutableAttributedString(string: " \(date)", attributes: [.font: UIFont.systemFont(ofSize: 10)])
        
        let clockImage = UIImage(systemName:"clock")!.withRenderingMode(.alwaysOriginal)
        let clock = NSTextAttachment(image:clockImage)
        let clockChar = NSAttributedString(attachment:clock)
        mas.insert(clockChar, at:0)
        dateLabel.attributedText = mas
    }
    
    func createlabel(in v: UIView, with color: UIColor = UIColor.gray) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 15)
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        return label
    }
}

class LineView: UIView {
    override func draw(_ rect: CGRect) {
        let aPath = UIBezierPath()
        
        aPath.move(to: .zero)
        aPath.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        
        // Keep using the method addLine until you get to the one where about to close the path
//        aPath.close()
        
        UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1).set()
        aPath.lineWidth = 1
        aPath.stroke()
    }
}
