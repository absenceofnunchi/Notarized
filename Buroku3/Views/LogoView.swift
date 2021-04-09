//
//  LogoView.swift
//  Buroku3
//
//  Created by J C on 2021-04-07.
//

import UIKit

class LogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let context4 = UIGraphicsGetCurrentContext()
        UIColor.white.set()
        context4?.addRect(CGRect(x: 35, y: 40, width: 8, height: 8))
        context4?.fillPath()
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        UIColor.white.set()
        context?.addRect( CGRect(x: 30, y: 10, width: 45, height: 45))
        context?.strokePath()
        
        let context2 = UIGraphicsGetCurrentContext()
        context2?.setLineWidth(2.0)
        UIColor.white.set()
        context2?.addRect( CGRect(x: 25, y: 15, width: 45, height: 45))
        context2?.strokePath()
        
        let context3 = UIGraphicsGetCurrentContext()
        context3?.setLineWidth(2.0)
        UIColor.white.set()
        context3?.addRect(CGRect(x: 20, y: 20, width: 45, height: 45))
        context3?.strokePath()
    }
}
