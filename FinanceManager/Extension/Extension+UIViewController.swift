import UIKit

extension UIViewController {
    
    var navigationBarHeight: CGFloat {
        let height = navigationController?.navigationBar.frame.height ?? 0.0
        return navigationController?.isNavigationBarHidden == false ? height : 0
    }
    
    func getHalfHeight() -> CGFloat {
        var halfHeight = view?.systemLayoutSizeFitting(
            CGSize(width: view?.frame.width ?? 0.0, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height ?? .zero
        halfHeight -= view.safeAreaInsets.top
        halfHeight -= view.safeAreaInsets.bottom
        halfHeight += navigationBarHeight
        return halfHeight
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(
            forKeyPath: "statusBarWindow.statusBar"
        ) as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func animatableUpdateStatusBarAppearance() {
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension UIViewController {
    
    var isRootVC: Bool {
        navigationController?.viewControllers.count == 1
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}


extension UIViewController {
    
    @objc
    func scrollToTop(animated: Bool) {
        for subview in view.subviews where subview is UIScrollView {
            guard let scrollView = subview as? UIScrollView else { return }
            scrollView.setContentOffset(
                CGPoint(x: 0.0, y: -scrollView.contentInset.top),
                animated: animated
            )
        }
    }
}

extension UIViewController {

    @IBAction public func dismiss() {
        dismiss(animated: true)
    }
}
