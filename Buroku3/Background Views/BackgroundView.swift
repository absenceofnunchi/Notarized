//
//  File.swift
//  Buroku3
//
//  Created by J C on 2021-03-17.
//

import UIKit

class BackgroundView: UIView {
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

extension BackgroundView {
    override func draw(_ rect: CGRect) {
        let y: CGFloat = self.bounds.size.height
        let x: CGFloat = self.bounds.size.width
        
        let initialPath = UIBezierPath()
        initialPath.move(to: CGPoint(x: x / 2, y: 0)) // 1
        initialPath.addLine(to: CGPoint(x: x / 2, y: y / 2)) // 2
        initialPath.addLine(to: initialPath.currentPoint) // 3
        initialPath.addLine(to: initialPath.currentPoint) // 4
        initialPath.addLine(to: CGPoint(x: x / 2, y: y)) // 5
        initialPath.addLine(to: initialPath.currentPoint) // 6
        initialPath.addLine(to: CGPoint(x: 0, y: y)) // 7
        initialPath.addLine(to: .zero) // 8
        initialPath.close()
        
        let bgShapeLayer = CAShapeLayer()
        bgShapeLayer.path = initialPath.cgPath
        bgShapeLayer.lineJoin = .round
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 100, y: 0)) // 1
        path.addArc(tangent1End: CGPoint(x: 100, y: y / 2), tangent2End: CGPoint(x: x - 50, y: y / 2), radius: 50) // 2, 3
        path.addArc(tangent1End: CGPoint(x: x - 50, y: y / 2), tangent2End: CGPoint(x: x - 50, y: y), radius: 50) // 4, 5
        path.addLine(to: CGPoint(x: x - 50, y: y)) // 6
        path.addLine(to: CGPoint(x: 0, y: y)) // 7
        path.addLine(to: .zero) // 8
        path.closeSubpath()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.colors = [finishingColor, startingColor]
        gradientLayer.frame = self.bounds
        gradientLayer.mask = bgShapeLayer
        
        self.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath.cgPath
        animation.toValue = path
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        
        bgShapeLayer.add(animation, forKey: animation.keyPath)
    }
}


