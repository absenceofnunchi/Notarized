//
//  CustomTabBar.swift
//  Buroku3
//
//  Created by J C on 2021-03-17.
//

import UIKit

import UIKit

class CustomTabBar: UIView {
    enum TabItem: Int {
        case camera, photo, folder
        var name: String {
            switch self {
                case .camera:
                    return "camera"
                case .photo:
                    return "photo"
                case .folder:
                    return "folder"
            }
        }
        
        var selected: String {
            switch self {
                case .camera:
                    return "camera.fill"
                case .photo:
                    return "photo.fill"
                case .folder:
                    return "folder.fill"
            }
        }
        
        var index: Int {
            return rawValue
        }
    }
    
    var tabButton1: UIButton!
    var tabButton2: UIButton!
    var tabButton3: UIButton!
    var stackView: UIStackView!
    var indicatorLayer = CALayer()
    let color = UIColor.white
    weak var delegate: CustomTabBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: -0.50, height: 0.50)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension CustomTabBar {
    func configure() {
        // tab buttons
        tabButton1 = createButton(for: .camera)
//        tabButton1.isSelected = true
        tabButton2 = createButton(for: .photo)
        tabButton3 = createButton(for: .folder)
        
        // stack view
        stackView = UIStackView(arrangedSubviews: [tabButton1, tabButton2, tabButton3])
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        // indicator layer
        stackView.layer.addSublayer(indicatorLayer)
        indicatorLayer.backgroundColor = color.cgColor
        indicatorLayer.frame = CGRect(origin: .zero, size: .init(width: 40, height: 2))
        indicatorLayer.isHidden = true
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func createButton(for tabItem: TabItem) -> UIButton {
        let tabButton = UIButton()
        tabButton.addTarget(self, action: #selector(tabBarButtonHandler(_:)), for: .touchUpInside)
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        let normalImage = UIImage(systemName: tabItem.name)?.withConfiguration(config)
        tabButton.setImage(normalImage, for: .normal)
        
        let selectedImage = UIImage(systemName: tabItem.selected)?.withConfiguration(config)
        tabButton.setImage(selectedImage, for: .selected)
        
        tabButton.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        tabButton.tag = tabItem.index
        tabButton.tintColor = color
        tabButton.translatesAutoresizingMaskIntoConstraints = false
        return tabButton
    }
}

extension CustomTabBar {
    @objc func tabBarButtonHandler(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        indicatorLayer.isHidden = false
        indicatorLayer.position = CGPoint(x: sender.frame.midX, y: sender.frame.minY)
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        for case let button in self.stackView.arrangedSubviews where button is UIButton && button != sender {
            (button as! UIButton).isSelected = false
        }
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                sender.transform = .identity
            }
        }, completion: nil)
        
        delegate?.tabBarDidSelect(with: sender.tag)
    }
}
