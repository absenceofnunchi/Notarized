//
//  BackgroundView7.swift
//  Buroku3
//
//  Created by J C on 2021-03-27.
//

/*
 Abstract: background for MainViewController
 */

import UIKit

class BackgroundView7: UIView {
    let startingColor = UIColor(red: 163/255, green: 196/255, blue: 204/255, alpha: 1).cgColor
    let finishingColor = UIColor(red: 75/255, green: 120/255, blue: 136/255, alpha: 1).cgColor
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BackgroundView7 {
    override func draw(_ rect: CGRect) {
        let y: CGFloat = self.bounds.size.height
        let x: CGFloat = self.bounds.size.width
  
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: x / 2, y: 0), radius: y / 2, startAngle: 0, endAngle: .pi, clockwise: true)
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = circlePath.cgPath
 
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = [finishingColor, startingColor]
        gradientLayer.frame = self.bounds
        gradientLayer.mask = circleShapeLayer

        self.layer.addSublayer(gradientLayer)
    }
}
