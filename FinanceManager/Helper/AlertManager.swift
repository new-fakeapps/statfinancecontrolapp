import UIKit
import SwiftEntryKit
import FloatingPanel
import UserNotifications

struct AlertManager {
    
    enum Alert: String, CaseIterable {
        case fastBetMessage
        case topMessage
    }
    
    static var isCurrentlyDisplaying: Bool {
        if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: Alert.fastBetMessage.rawValue)
            || SwiftEntryKit.isCurrentlyDisplaying(entryNamed: Alert.topMessage.rawValue) {
            return false
        } else {
            return SwiftEntryKit.isCurrentlyDisplaying
        }
    }
    
    static func layoutIfNeeded() {
        SwiftEntryKit.layoutIfNeeded()
    }
    
    private static var currentAlert: UIView?
    private static var currentAlertController: UIViewController?
    
    static func closeCurrentAlert(completion: (() -> Void)? = nil) {
        SwiftEntryKit.dismiss {
            delay(0.1) {
                completion?()
            }
        }
    }
}

// MARK: - Attributes
extension AlertManager {
    
    private static func bottomAlertAttributes(backgroundColor: UIColor, isScrollEnabled: Bool = true) -> EKAttributes {
        var attributes: EKAttributes = EKAttributes()
        attributes = .bottomFloat
        attributes.position = .bottom
        attributes.windowLevel = .normal
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = isScrollEnabled ? .enabled(swipeable: true, pullbackAnimation: .init(duration: 0.4, damping: 1, initialSpringVelocity: 0.0)) : .disabled
        attributes.roundCorners = .top(radius: 10)
        attributes.screenBackground = .color(color: .black.with(alpha: 0.3))
        attributes.entryBackground = .color(color: .init(backgroundColor))
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.4, spring: .init(damping: 0.75, initialVelocity: 0.0)),
            fade: nil
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.4, spring: .init(damping: 1.0, initialVelocity: 0.0)),
            fade: nil
        )
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size = .init(width: .fill, height: .intrinsic)
        attributes.border = .none
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 7, offset: CGSize(width: 0.0, height: 1.0)))
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 0, screenEdgeResistance: -200))
        attributes.positionConstraints.safeArea = .overridden
        return attributes
    }
    
    private static func defaultAttributes(canBeClosed: Bool = true) -> EKAttributes {
        var attributes: EKAttributes
        attributes = .centerFloat
        attributes.windowLevel = .normal
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction =  canBeClosed ? .dismiss : .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.roundCorners = .all(radius: 15)
        attributes.scroll = .enabled(swipeable: canBeClosed ? true : false, pullbackAnimation: .jolt)
        attributes.screenBackground = .color(color: .init(UIColor(white: 0, alpha: 0.7)))
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)),
            fade: .init(from: 0, to: 1, duration: 0.3)
        )
        attributes.exitAnimation = .init(
            scale: .init(from: 1, to: 0.9, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)),
            fade: .init(from: 1, to: 0, duration: 0.3)
        )
        attributes.displayDuration = .infinity
        attributes.border = .value(color: .black, width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5, offset: .zero))
        attributes.positionConstraints.maxSize = .init(width: .offset(value: CGFloat(16.0)), height: .intrinsic)
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 10, screenEdgeResistance: -200))
        return attributes
    }

    private static func noteAttributes(backgroundColor: UIColor) -> EKAttributes {
        var attributes: EKAttributes = .statusBar
        attributes.hapticFeedbackType = .error
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .init(backgroundColor))
        attributes.positionConstraints.size = .init(width: .fill, height: .constant(value: 44))
        attributes.displayDuration = 2
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        return attributes
    }
}

// MARK: - FloatingPanel
extension UIViewController {
    
    
    var floatingPanel: FloatingPanelController? {
        var viewController: UIViewController? = self
        while viewController is FloatingPanelController == false && viewController != nil {
            viewController = viewController?.parent
        }
        return viewController as? FloatingPanelController
    }
    
    func changeModalPresentationStyle() {
        if floatingPanel == nil {
            modalPresentationStyle = .fullScreen
        }
    }
}
