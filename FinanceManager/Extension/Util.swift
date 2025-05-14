import UIKit

extension Array {
    func get(_ index: Int) -> Element? {
        if (0..<count).contains(index) {
            return self[index]
        }
        return nil
    }
}

extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}

extension CGFloat {
    func clamp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return self < minValue ? minValue : (self > maxValue ? maxValue : self)
    }
}

extension Int {
    func clamp(_ minValue: Int, _ maxValue: Int) -> Int {
        return self < minValue ? minValue : (self > maxValue ? maxValue : self)
    }
    
    var stringValue: String? {
        String(self)
    }
}

extension Int64 {
    
    var stringValue: String {
        String(self)
    }
}

extension CGPoint {
    func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x+dx, y: self.y+dy)
    }
    
    func transform(_ trans: CGAffineTransform) -> CGPoint {
        return self.applying(trans)
    }
    
    func distance(_ point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - point.x, 2)+pow(self.y - point.y, 2))
    }
    
    var transposed: CGPoint {
        return CGPoint(x: y, y: x)
    }
}

extension CGSize {
    func insets(by insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
    var transposed: CGSize {
        return CGSize(width: height, height: width)
    }
}

func abs(_ left: CGPoint) -> CGPoint {
    return CGPoint(x: abs(left.x), y: abs(left.y))
}
func min(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: min(left.x, right.x), y: min(left.y, right.y))
}
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}
func + (left: CGRect, right: CGPoint) -> CGRect {
    return CGRect(origin: left.origin + right, size: left.size)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func - (left: CGRect, right: CGPoint) -> CGRect {
    return CGRect(origin: left.origin - right, size: left.size)
}
func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x/right, y: left.y/right)
}
func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x*right, y: left.y*right)
}
func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return right * left
}
func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x*right.x, y: left.y*right.y)
}
prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint.zero - point
}
func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width/right, height: left.height/right)
}
func - (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    var bounds: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size / 2, size: size)
    }
    var transposed: CGRect {
        return CGRect(origin: origin.transposed, size: size.transposed)
    }
}

func delay(_ delay: Double, closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
func delay(_ delay: Double, workItem: DispatchWorkItem) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: workItem)
}

func printCodeExecutionTime(closure: (()->Void)?) {
    let start = DispatchTime.now()
    closure?()
    let end = DispatchTime.now()
    
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("[The execution of \(type(of: closure)) is \(timeInterval)]")
}

func uniq<S: Sequence, T: Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

func combinationsWithoutRepetitionFrom<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count > 0 && taking > 0 else { return [[]] }
    
    if taking == 1 {
        return elements.map {[$0]}
    }
    
    var combinations = [[T]]()
    for (index, element) in elements.enumerated() {
        var reducedElements = elements
        reducedElements.removeFirst(index + 1)
        combinations += combinationsWithoutRepetitionFrom(reducedElements, taking: taking - 1).map {[element] + $0}
    }
    
    return combinations
}
