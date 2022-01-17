//
//  PaginatedAlertViewController.swift
//  Buroku3
//
//  Created by J C on 2022-01-14.
//

/*
 Abstract:
 Container paginated alert view controller with StandarAlertViewController as the single page
 */

import UIKit

protocol DataFetchDelegate: AnyObject {
    func didGetData(_ data: [String: String])
}

class AlertViewController: UIPageViewController {
    private var contentArray = [StandardAlertContent]()
    private var indexArray: [Int]!
    private var pvc: UIPageViewController!
    private var height: CGFloat!
    private lazy var customTransitioningDelegate = TransitioningDelegate(height: height)
    var dataDict = [String: String]()
    // AlerVC is the parent container vc for the individual page. The Standard vc is the first of the single page vc's
    // Only the buttons in the Standard vc is currently connected with AlertVC for now.
    var action: ((AlertViewController, StandardAlertViewController)->Void)? {
        didSet {
            guard let action = action,
                  let mainVC = mainStandardAlertVC else { return }
            action(self, mainVC)
        }
    }
    private var mainStandardAlertVC: StandardAlertViewController!
    
    init(height: CGFloat = 250, standardAlertContent: [StandardAlertContent]) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        contentArray.append(contentsOf: standardAlertContent)
        
        self.height = height
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = customTransitioningDelegate
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("fatal error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

extension AlertViewController: DataFetchDelegate {
    private func configure() {
        self.hideKeyboardWhenTappedAround()
        
        // used for indexing page vc's
        indexArray = contentArray.map { $0.index }
        
        // main vc is the only one connected to the presenting VC
        // this is to be able to dismiss the modal while validating the user inputs
        guard let firstContent = contentArray.first else { return }
        mainStandardAlertVC = StandardAlertViewController(content: firstContent)
        mainStandardAlertVC.delegate = self
        
        setViewControllers([mainStandardAlertVC], direction: .forward, animated: false, completion: nil)
        dataSource = self
        delegate = self
        
        if contentArray.count > 1 {
            let pageControl = UIPageControl.appearance()
            pageControl.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.6)
            pageControl.currentPageIndicatorTintColor = .gray
            pageControl.backgroundColor = .clear
        }
    }
    
    final func didGetData(_ data: [String : String]) {
        data.forEach { dataDict.updateValue($0.value, forKey: $0.key) }
    }
}

extension AlertViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as! StandardAlertViewController).index,
              var i = indexArray.firstIndex(of: index) else { return nil }
        
        i -= 1
        if i < 0 {
            return nil
        }
        
        let sac = StandardAlertViewController(content: contentArray[i])
        sac.delegate = self
        return sac
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? StandardAlertViewController,
              let i = vc.index,
              var newIndex = indexArray.firstIndex(of: i) else { return nil }
        
        newIndex += 1
        if newIndex >= contentArray.count {
            return nil
        }
        
        let sac = StandardAlertViewController(content: contentArray[newIndex])
        sac.delegate = self
        return sac
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vcs = pageViewController.viewControllers,
              let page = vcs[0] as? StandardAlertViewController else { return 0 }
        
        
        guard let i = page.index,
              let newIndex = self.indexArray.firstIndex(of: i) else {
                  return 0
              }
        
        return newIndex
    }
}

// MARK: - TransitioningDelegate
class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var height: CGFloat!
    
    init(height: CGFloat = 300) {
        self.height = height
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting, height: height)
    }
}

// MARK: - PresentationController
class PresentationController: UIPresentationController {
    var height: CGFloat!
    
    let dimmingView: UIView = {
        let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        let tap = UIGestureRecognizer(target: self,  action: #selector(tapped))
        dimmingView.addGestureRecognizer(tap)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = presentingViewController.view.bounds
        let size = CGSize(width: bounds.size.width * 0.8, height: height)
        let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
        return CGRect(origin: origin, size: size)
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.height = height
        presentedView?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin
        ]
        
        presentedView?.translatesAutoresizingMaskIntoConstraints = true
        let tap = UIGestureRecognizer(target: self,  action: #selector(tapped))
        presentedView?.addGestureRecognizer(tap)
    }
    
    @objc func tapped() {
        presentedView?.endEditing(true)
    }
}

extension PresentationController {
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        let superview = presentingViewController.view!
        superview.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            dimmingView.topAnchor.constraint(equalTo: superview.topAnchor)
        ])
        
        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.9
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
