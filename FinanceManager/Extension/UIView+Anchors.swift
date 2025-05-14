import UIKit

extension UIView {

    // MARK: - Width
    @discardableResult
    func anchorWidth(
        constant: CGFloat = 0.0,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidth(
        equalTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = widthAnchor.constraint(
                equalTo: equalTo,
                constant: constant
            )
        } else {
            constraint = widthAnchor.constraint(equalTo: equalTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidth(
        greaterThanOrEqualTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = widthAnchor.constraint(
                greaterThanOrEqualTo: greaterThanOrEqualTo,
                constant: constant
            )
        } else {
            constraint = widthAnchor.constraint(greaterThanOrEqualTo: greaterThanOrEqualTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidth(
        greaterThanOrEqualToConstant: CGFloat,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = widthAnchor.constraint(
            greaterThanOrEqualToConstant: greaterThanOrEqualToConstant
        )
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidth(
        lessThanOrEqualTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = widthAnchor.constraint(
                lessThanOrEqualTo: lessThanOrEqualTo,
                constant: constant
            )
        } else {
            constraint = widthAnchor.constraint(lessThanOrEqualTo: lessThanOrEqualTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidth(
        lessThanOrEqualToConstant: CGFloat,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = widthAnchor.constraint(
            lessThanOrEqualToConstant: lessThanOrEqualToConstant
        )
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorWidthToSuperview(
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        guard let anchor = superview?.widthAnchor else {
            return nil
        }

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = widthAnchor.constraint(
                equalTo: anchor,
                constant: constant
            )
        } else {
            constraint = widthAnchor.constraint(equalTo: anchor)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }
    
    @discardableResult
    func anchorTopToSuperview(
        constant: CGFloat = 0.0,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        guard let anchor = superview?.topAnchor else {
            return nil
        }
        let constraint = topAnchor.constraint(equalTo: anchor, constant: constant)
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func anchorBottomToSuperview(
        constant: CGFloat = 0.0,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        guard let anchor = superview?.bottomAnchor else {
            return nil
        }
        let constraint = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: - Bottom
    @discardableResult
    func anchorBottom(
        equalTo: NSLayoutYAxisAnchor,
        constant: CGFloat = 0.0,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: equalTo, constant: -constant)
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true
        return constraint
    }

    // MARK: - Height
    @discardableResult
    func anchorHeight(
        constant: CGFloat = 0.0,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorHeight(
        equalTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = heightAnchor.constraint(
                equalTo: equalTo,
                constant: constant
            )
        } else {
            constraint = heightAnchor.constraint(equalTo: equalTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorHeight(
        greaterThanOrEqualTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = heightAnchor.constraint(
                greaterThanOrEqualTo: greaterThanOrEqualTo,
                constant: constant
            )
        } else {
            constraint = heightAnchor.constraint(greaterThanOrEqualTo: greaterThanOrEqualTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorHeight(
        greaterThanOrEqualToConstant: CGFloat,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = heightAnchor.constraint(
            greaterThanOrEqualToConstant: greaterThanOrEqualToConstant
        )
        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorHeight(
        lessThanOrEqualTo: NSLayoutDimension,
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = heightAnchor.constraint(
                lessThanOrEqualTo: lessThanOrEqualTo,
                constant: constant
            )
        } else {
            constraint = heightAnchor.constraint(lessThanOrEqualTo: lessThanOrEqualTo)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }

    @discardableResult
    func anchorHeightToSuperview(
        constant: CGFloat? = nil,
        priority: Float = 1000.0
    ) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false

        guard let anchor = superview?.heightAnchor else {
            return nil
        }

        let constraint: NSLayoutConstraint

        if let constant {
            constraint = heightAnchor.constraint(
                equalTo: anchor,
                constant: constant
            )
        } else {
            constraint = heightAnchor.constraint(equalTo: anchor)
        }

        constraint.priority = .init(rawValue: priority)
        constraint.isActive = true

        return constraint
    }
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: format,
            options: NSLayoutConstraint.FormatOptions(),
            metrics: nil,
            views: viewsDictionary)
        )
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    func anchor(
        _ top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        width: NSLayoutDimension? = nil,
        height: NSLayoutDimension? = nil,
        topConstant: CGFloat = 0,
        leftConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0,
        rightConstant: CGFloat = 0,
        widthConstant: CGFloat = 0,
        heightConstant: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        _ = anchorWithReturnAnchors(
            top,
            left: left,
            bottom: bottom,
            right: right,
            width: width,
            height: height,
            topConstant: topConstant,
            leftConstant: leftConstant,
            bottomConstant: bottomConstant,
            rightConstant: rightConstant,
            widthConstant: widthConstant,
            heightConstant: heightConstant
        )
    }
    
    func anchorWithReturnAnchors(
        _ top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        width: NSLayoutDimension? = nil,
        height: NSLayoutDimension? = nil,
        topConstant: CGFloat = 0,
        leftConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0,
        rightConstant: CGFloat = 0,
        widthConstant: CGFloat = 0,
        heightConstant: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if let width = width {
            anchors.append(widthAnchor.constraint(equalTo: width, constant: widthConstant))
        } else if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if let height = height {
            anchors.append(heightAnchor.constraint(equalTo: height, constant: heightConstant))
        } else if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }

        anchors.forEach { $0.isActive = true }
        
        return anchors
    }
    
    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    @discardableResult
    func anchorCenterYToSuperview(constant: CGFloat = 0) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            let constraint = centerYAnchor.constraint(equalTo: anchor, constant: constant)
            constraint.isActive = true
            return constraint
        }
        return nil
    }
    
    func anchorCenterX(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func anchorCenterY(to view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    }
    
    func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
    
    func anchorCenter(to view: UIView) {
        anchorCenterX(to: view)
        anchorCenterY(to: view)
    }
}
