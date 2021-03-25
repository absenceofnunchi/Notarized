//
//  BackgroundView4.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//


/*
 Abstract: background for WalletViewController
 */

import UIKit

class BackgroundView4: UIView {
    let startingColor = UIColor(red: 167/255, green: 197/255, blue: 235/255, alpha: 1).cgColor
    let finishingColor = UIColor(red: 102/255, green: 98/255, blue: 135/255, alpha: 1).cgColor
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BackgroundView4 {
    override func draw(_ rect: CGRect) {
        let y: CGFloat = self.bounds.size.height
        let x: CGFloat = self.bounds.size.width
        
        let initialPath = CGMutablePath()
        initialPath.move(to: CGPoint(x: 0, y: y / 10 * 7))
        initialPath.addArc(tangent1End: CGPoint(x: x / 11, y: y / 10 * 8.5), tangent2End: CGPoint(x: x / 8 * 8.5, y: y / 10 * 8.5), radius: 80)
        initialPath.addArc(tangent1End: CGPoint(x: x / 8 * 8.5, y: y / 10 * 8.5), tangent2End: CGPoint(x: x, y: y), radius: 50)
        initialPath.addLine(to: CGPoint(x: x, y: y))
        initialPath.addLine(to: CGPoint(x: x, y: 0))
        initialPath.addLine(to: .zero)
        initialPath.closeSubpath()
        
        let bgShapeLayer = CAShapeLayer()
        bgShapeLayer.path = initialPath
        bgShapeLayer.lineJoin = .round
        
        let secondPath = CGMutablePath()
        secondPath.move(to: CGPoint(x: 0, y: y / 10 * 7))
        secondPath.addArc(tangent1End: CGPoint(x: x / 11, y: y / 10 * 8.5), tangent2End: CGPoint(x: x / 8 * 8.5, y: y / 10 * 8.5), radius: 80)
        secondPath.addArc(tangent1End: CGPoint(x: x / 8 * 8.5, y: y / 10 * 8.5), tangent2End: CGPoint(x: x, y: y), radius: 50)
        secondPath.addLine(to: CGPoint(x: x, y: y))
        secondPath.addLine(to: CGPoint(x: x, y: 0))
        secondPath.addLine(to: .zero)
        secondPath.closeSubpath()
        
        let bgShapeLayer2 = CAShapeLayer()
        bgShapeLayer2.path = secondPath
        bgShapeLayer2.lineJoin = .round
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.colors = [startingColor , UIColor.white.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.mask = bgShapeLayer
        
        self.layer.addSublayer(gradientLayer)
        
//        let gradientLayer2 = CAGradientLayer()
//        gradientLayer2.startPoint = CGPoint(x: 1, y: 0)
//        gradientLayer2.endPoint = CGPoint(x: 0, y: 1)
//        gradientLayer2.colors = [finishingColor, startingColor]
//        gradientLayer2.frame = self.bounds
//        gradientLayer2.mask = bgShapeLayer2
//
//        self.layer.addSublayer(gradientLayer2)
    }
}

