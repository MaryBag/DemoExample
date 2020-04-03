//
//  PageController.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

import UIKit

protocol PageControllerProtocol: AnyObject {
    var controller: UIViewController? { get }
    var isAfterRefresh: Bool { get }
    func updateCollection()
    func showError(_ error: Error)
}

class PageController: ControllerWithNavigationItem, PageControllerProtocol, RefreshControllerProtocol, ControllerWithServiceError {
    
    var controller: UIViewController?
    var isAddedError = false
    var isAfterRefresh = false
    var presenter: PagePresenterProtocol?
    var logoHeader: LogoContainerProtocol?
    
    @IBOutlet weak var logo: UIStackView!
    @IBOutlet weak var invisibleScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerConstraint: NSLayoutConstraint!
    @IBOutlet weak var image: UIButton!
    private lazy var popupView: View = {
        let view = View()
        view.backgroundColor = ThemeManager.currentTheme().mainColor
        return view
    }()
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    private lazy var openTitleLabel: UILabel = {
        let label = BrandedLabelBold()
        label.text = "Settings"
        label.textAlignment = .center
        label.alpha = 0
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    private lazy var logoutButton: UIButton = {
        let button = BrandedButton()
        button.setTitle("Log out", for: .normal)
        button.addTarget(self, action: #selector(logout(_:)), for: .touchDown)
        button.alpha = 0
        return button
    }()
    private lazy var dimmView: UIView = {
        let view = UIView()
        let theme = ThemeManager.currentTheme()
        view.backgroundColor = theme.dimmColor
        view.alpha = 0
        return view
    }()
    
    private enum Constants {
        static let barHeight: CGFloat = 50.0
        static let zero: CGFloat = 0.0
        static let paddingSpace: CGFloat = 25.0
        static let boxHeight: CGFloat = 332.0
        static let footerWidth: CGFloat = 60.0
        static let footerHeight: CGFloat = 60.0
        static let footerTag = -123456
        static let cornerRadiusMenu: CGFloat = 20.0
        static let maxHeightPopUpMenu: CGFloat = 150.0
    }
    private var heightPopUPMenu =  NSLayoutConstraint()
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()
    private var currentStateMenu: State = .closed
    private var maxHeaderOffsetY: CGFloat = 0.0
    private var isLoading = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.controller = self
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.controller = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.viewDidLoad(completion: { [weak self] (check) in
            DispatchQueue.main.async { [weak self] in
                self?.updateCollection()
            }
        })
        layoutLogoContainer()
        setupCollectionView()
        invisibleScrollView.delegate = self
        maxHeaderOffsetY = header.frame.height - (self.navigationController?.navigationBar.frame.height ?? Constants.barHeight)
        
        let tintedimage = self.image.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.image.tintColor = ThemeManager.currentTheme().imageColor
        image.setImage(tintedimage, for: .normal)

        setupDimmView()
        layoutPopUPMenu()
    }
    
    override func loadView() {
       Bundle.main.loadNibNamed("PageController", owner: self, options: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func settings(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.alpha = 1.0
        }
        let state = currentStateMenu.opposite
        guard state == .open else { return }
        self.menuAnimateTransitionIfNeeded(to: state, duration: 0.3)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let state = currentStateMenu.opposite
        guard state == .closed else { return }
        self.menuAnimateTransitionIfNeeded(to: state, duration: 0.3)
    }
    
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        guard self.currentStateMenu.opposite == .closed else { return }
        if recognizer == panRecognizer {
            let translationY = panRecognizer.heightY
            let y = self.heightPopUPMenu.constant - translationY
            let alpha = self.dimmView.alpha - (translationY / Constants.maxHeightPopUpMenu)
            if y >= Constants.maxHeightPopUpMenu / 2 && y < Constants.maxHeightPopUpMenu {
                self.heightPopUPMenu.constant = y
                self.dimmView.alpha = alpha
                self.openTitleLabel.alpha = alpha
                self.logoutButton.alpha = alpha
            } else if y >= Constants.maxHeightPopUpMenu {
                self.heightPopUPMenu.constant = Constants.maxHeightPopUpMenu
                self.dimmView.alpha = 1
                self.openTitleLabel.alpha = 1
                self.logoutButton.alpha = 1
            }
            switch recognizer.state {
            case .ended:
                let yVelocity = recognizer.velocity(in: popupView).y
                let shouldClose = yVelocity > 0
                if !shouldClose {
                    let transitionAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1, animations: {
                        self.openMenu()
                    })
                    transitionAnimator.startAnimation()
                } else {
                    menuAnimateTransitionIfNeeded(to: .closed, duration: 0.3)
                }
            default:
                ()
            }
        }
    }
    
    @objc func logout(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.alpha = 1.0
        }
        presenter?.logout()
    }
    
    func refresh() {
        presenter?.refresh(completion: { [weak self] (check) in
            if check {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.reloadData()
                    UICollectionView.animate(withDuration: 0.3) {
                        self.collectionView.contentOffset.y = self.invisibleScrollView.contentOffset.y
                        self.isAfterRefresh = false
                    }
                }
            }
        })
    }
    
    func showError(_ error: Error) {
        if !isAddedError {
            dimmView.alpha = 1
            guard let controller = presenter?.getErrorController(controller: self, error: error).controller else { return }
            self.addChild(controller)
            let width = self.view.frame.width - 40 * 2
            let y = (self.view.frame.height - 400) / 2
            controller.view.frame = CGRect(x: 40, y: y, width: width, height: 400)
            self.view.addSubview(controller.view)
            controller.didMove(toParent: self)
            isAddedError = true
        }
    }
    
    func deleteDimmView() {
         dimmView.alpha = 0
    }
    
    func updateCollection() {
        self.collectionView.performBatchUpdates({
            let indexPaths = Array((presenter?.prevCount ?? 0)..<(presenter?.getCount() ?? 0)).map { IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: indexPaths)
        }) { (check) in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.collectionViewLayout.prepare()
            self.setContentSize()
        }
    }

}

private extension PageController {
    func layoutPopUPMenu() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        heightPopUPMenu = popupView.heightAnchor.constraint(equalToConstant: 0)
        heightPopUPMenu.isActive = true
        popupView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30).isActive = true
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(logoutButton)
        logoutButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: openTitleLabel.bottomAnchor, constant: 15).isActive = true
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    func layoutLogoContainer() {
        logoHeader = presenter?.getLogo()
        logoHeader?.setupView()
        guard let view = logoHeader?.view else { return }
        view.bounds = self.logo.bounds
        self.logo.addArrangedSubview(view)
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let nib = UINib(nibName: String(describing: CategoryBox.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: String(describing: CategoryBox.self))
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        contentView.addGestureRecognizer(invisibleScrollView.panGestureRecognizer)
    }
    
    func setupDimmView() {
        self.view.insertSubview(dimmView, at: self.view.subviews.count)
        dimmView.frame = self.view.frame
        dimmView.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.dimmView.addGestureRecognizer(tap)
    }
    
    func menuAnimateTransitionIfNeeded(to state: State, duration: Double) {
        guard runningAnimators.isEmpty || state == currentStateMenu else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
                case .open:
                    self.openMenu()
                case .closed:
                    self.closeMenu()
                }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
                case .start:
                    self.currentStateMenu = state.opposite
                case .end:
                    self.currentStateMenu = state
                case .current:
                    ()
                @unknown default:
                    ()
            }
            switch self.currentStateMenu {
                case .open:
                    self.openMenu()
                case .closed:
                    self.closeMenu()
            }
            self.runningAnimators.removeAll()
        }
        transitionAnimator.startAnimation()
        
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(transitionAnimator)

    }
    
    func openMenu() {
        self.heightPopUPMenu.constant = Constants.maxHeightPopUpMenu
        self.popupView.layer.cornerRadius = Constants.cornerRadiusMenu
        self.popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.dimmView.alpha = 1
        self.openTitleLabel.alpha = 1
        self.logoutButton.alpha = 1
    }
    
    func closeMenu() {
        self.heightPopUPMenu.constant = 0
        self.popupView.layer.cornerRadius = 0
        self.popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.logoutButton.alpha = 0
        self.openTitleLabel.alpha = 0
        deleteDimmView()
    }
    
    func setContentSize() {
        if self.collectionView.contentSize.height > self.collectionView.frame.height {
            self.invisibleScrollView.contentSize.height = self.header.frame.height + self.collectionView.contentSize.height
        } else {
            self.invisibleScrollView.contentSize.height = self.contentView.frame.height + 1
        }
    }
    
    func reloadData() {
        self.collectionView.reloadData()
        setContentSize()
        self.view.layoutIfNeeded()
    }
}
