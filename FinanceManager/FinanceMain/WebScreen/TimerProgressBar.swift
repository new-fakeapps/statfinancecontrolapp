import UIKit

class TimerProgressBar: UIProgressView {
    private var theBool = false
    private var timer: Timer? = Timer()
    private var frequency: TimeInterval = 0.01667

    init() {
        super.init(frame: .zero)
        configureUI()
        self.alpha = 0
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }

    private func configureUI() {
        tintColor = UIColor.hexStringToUIColor(hex: "FCC341")
    }

    public func startLoading(frequency: TimeInterval = 0.01667) {
        guard timer?.isValid != true else { return }

        self.frequency = frequency
        progress = 0
        theBool = false
        UIView.animate(withDuration: 0.1) {[weak self] in
            guard let `self` = self else { return }
            self.alpha = 1
        }
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: frequency,
                                     target: self,
                                     selector: #selector(timerCallback),
                                     userInfo: nil,
                                     repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    public func stopLoading() {
        timer?.invalidate()
        setProgress(1, animated: true)
        delay(0.3) {[weak self] in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.1) {[weak self] in
                guard let `self` = self else { return }
                self.alpha = 0
            }
        }
        theBool = true
    }

    @objc private func timerCallback(){
        print(Date().description + "     " + self.progress.description)
            if self.theBool {
                if self.progress >= 1 {
                    UIView.animate(withDuration: 0.1) {[weak self] in
                        guard let `self` = self else { return }
                        self.alpha = 0
                    }
                    self.timer?.invalidate()
                } else {
                    setProgress(self.progress + 0.1, animated: true)
                }
            } else {
                if self.progress >= 0.95 {
                    self.progress = 0.95
                } else {
                    setProgress(self.progress + 0.05, animated: true)
                }
            }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        timer?.invalidate()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = self.superview {
            anchor(superview.safeAreaLayoutGuide.topAnchor, left: superview.leftAnchor, right: superview.rightAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, heightConstant: 8)
        }
    }
}
