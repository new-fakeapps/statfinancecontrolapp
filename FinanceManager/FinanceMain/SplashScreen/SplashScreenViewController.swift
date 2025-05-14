import UIKit

class SplashScreenViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: SplashScreenPresenterInterface?
    
    private let backgroundImage = UIImageView()
    private let splashIcon = UIImageView()
    private let activityIndicator = UIActivityIndicatorView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle -
	override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureUI()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }
}

// MARK: - Configure UI
extension SplashScreenViewController {
    
    private func configureUI() {
        backgroundImage.backgroundColor = UIColor(hex: "0A162C")
        splashIcon.image = UIImage(named: "icon")
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupLayout() {
        view.addSubview(backgroundImage)
        backgroundImage.fillSuperview()
        
        backgroundImage.addSubview(splashIcon)
        
        splashIcon.anchorCenterYToSuperview()
        splashIcon.anchorCenterXToSuperview()
        splashIcon.anchorHeight(constant: 150)
        splashIcon.anchorWidth(constant: 150)
        
        backgroundImage.addSubview(activityIndicator)
        
        activityIndicator.anchorCenterXToSuperview()
        activityIndicator.anchorHeight(constant: 100)
        activityIndicator.anchorWidth(constant: 100)
        activityIndicator.anchor(
            bottom: backgroundImage.bottomAnchor,
            bottomConstant: 32
        )
    }
}

// MARK: - SplashScreenView
extension SplashScreenViewController: SplashScreenView {

    func displayPromotionBanner(data: Data) { }
}
