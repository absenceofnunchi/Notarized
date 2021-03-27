//
//  BackgroundView2.swift
//  Buroku3
//
//  Created by J C on 2021-03-17.
//

/*
 Abstract: background for UnregisteredWalletViewController
 */

import UIKit

class BackgroundView2: UIView {
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

extension BackgroundView2 {
    override func draw(_ rect: CGRect) {
        let y: CGFloat = self.bounds.size.height
        let x: CGFloat = self.bounds.size.width
        
        let initialPath = CGMutablePath()
        initialPath.move(to: CGPoint(x: 0, y: y / 3))
        initialPath.addArc(tangent1End: CGPoint(x: x / 3, y: y / 10 * 6), tangent2End: CGPoint(x: x / 3 * 2, y: y / 10 * 4), radius: 100)
        initialPath.addArc(tangent1End: CGPoint(x: x / 3 * 2, y: y / 10 * 4), tangent2End: CGPoint(x: x, y: y / 6 * 4), radius: 100)
        initialPath.addLine(to: CGPoint(x: x, y: y / 6 * 4))
        initialPath.addLine(to: CGPoint(x: x, y: y))
        initialPath.addLine(to: CGPoint(x: 0, y: y))
        initialPath.addLine(to: .zero)
        initialPath.closeSubpath()
        
        let bgShapeLayer = CAShapeLayer()
        bgShapeLayer.path = initialPath
        bgShapeLayer.lineJoin = .round
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: y / 3))

        path.addArc(tangent1End: path.currentPoint, tangent2End: CGPoint(x: x, y: y / 6 * 4), radius: 100)
        path.addArc(tangent1End: CGPoint(x: x, y: y / 6 * 4), tangent2End: CGPoint(x: x, y: y / 6 * 4), radius: 100)
        path.addArc(tangent1End: CGPoint(x: x / 3, y: y / 10 * 3), tangent2End: CGPoint(x: x / 3, y: y / 3 * 2), radius: 100)
        path.addArc(tangent1End: CGPoint(x: x / 3, y: y / 3 * 2), tangent2End: CGPoint(x: x, y: y / 6 * 4) , radius: 100)
        path.addLine(to: CGPoint(x: x, y: y / 6 * 4))
        path.addLine(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: 0, y: y))
        path.addLine(to: .zero)
        path.closeSubpath()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.colors = [finishingColor, startingColor]
        gradientLayer.frame = self.bounds
        gradientLayer.mask = bgShapeLayer
        
        self.layer.addSublayer(gradientLayer)
        
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.fromValue = initialPath
//        animation.toValue = path
//        animation.duration = 1
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        animation.fillMode = CAMediaTimingFillMode.both
//        animation.isRemovedOnCompletion = false
//
//        bgShapeLayer.add(animation, forKey: animation.keyPath)
    }
}
