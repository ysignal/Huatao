//
//  SSPhotoBrowser.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//
import UIKit
import AVKit
import MediaPlayer

fileprivate let PADDING: CGFloat = 10

extension Notification.Name {
    static let SS_PHOTO_LOADING_DID_END_NOTIFICATION = Notification.Name("SS_PHOTO_LOADING_DID_END_NOTIFICATION")
    static let SS_PHOTO_PROGRESS_NOTIFICATION = Notification.Name("SS_PHOTO_PROGRESS_NOTIFICATION")
}

protocol SSPhotoBrowserDelegate: NSObjectProtocol {
    
    //MARK: Require
    
    func numberOfPhotos(in photoBrowser: SSPhotoBrowser) -> Int
    
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, photoAt index: Int) -> SSPhoto?

    //MARK: Option
    
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, thumbPhotoAt index: Int) -> SSPhoto?

    func photoBrowser(_ photoBrowser: SSPhotoBrowser, captionViewForPhotoAt index: Int) -> SSCaptionView?
    
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, titleForPhotoAt index: Int) -> String?

    func photoBrowser(_ photoBrowser: SSPhotoBrowser, didDisplayPhotoAt index: Int)

    func photoBrowser(_ photoBrowser: SSPhotoBrowser, actionButtonPressedForPhotoAt index: Int)

    func photoBrowser(_ photoBrowser: SSPhotoBrowser, isPhotoSelectedAtIndex index: Int) -> Bool?
    
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, photoAt index: Int, selectedChanged selected: Bool)
    
    func photoBrowserDidFinishModalPresentation(_ photoBrowser: SSPhotoBrowser) -> Bool

}

extension SSPhotoBrowserDelegate {
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, thumbPhotoAt index: Int) -> SSPhoto? { return nil }
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, captionViewForPhotoAt index: Int) -> SSCaptionView? { return nil }
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, titleForPhotoAt index: Int) -> String? { return nil }
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, didDisplayPhotoAt index: Int) {}
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, actionButtonPressedForPhotoAt index: Int) {}
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, isPhotoSelectedAtIndex index: Int) -> Bool? { return nil }
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, photoAt index: Int, selectedChanged selected: Bool) {}
    func photoBrowserDidFinishModalPresentation(_ photoBrowser: SSPhotoBrowser) -> Bool { return false }
}

class SSPhotoBrowser: UIViewController {

    weak var delegate: SSPhotoBrowserDelegate?
    
    // Data
    private var photoCount: Int = 0
    private var photos: [SSPhoto?] = []
    private var thumbPhotos: [SSPhoto?] = []
    private var fixedPhotosArray: [SSPhoto]? // Provided via init

    // Views
    lazy var pagingScrollView: UIScrollView = {
        let view = UIScrollView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isPagingEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .black
        return view
    }()

    // Paging & layout
    private var visiblePages = [SSZoomScrollView]()
    private var recycledPages = [SSZoomScrollView]()
    private var currentPageIndex: Int = 0
    private var previousPageIndex: Int = Int.max
    private var previousLayoutBounds: CGRect = .zero
    private var pageIndexBeforeRotation: Int = 0

    // Navigation & controls
    lazy var toolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.tintColor = .white
        tb.barTintColor = nil
        tb.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        tb.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .compact)
        tb.barStyle = .blackTranslucent
        tb.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        return tb
    }()
    
    private var controlVisibilityTimer: Timer!
    private var previousButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!
    private var actionButton: UIBarButtonItem!
    private var doneButton: UIBarButtonItem!

    // Grid
    private var gridController: SSGridViewController?
    private var gridPreviousLeftNavItem: UIBarButtonItem!
    private var gridPreviousRightNavItem: UIBarButtonItem?
    
    // Appearance
    private var previousNavBarHidden: Bool = false
    private var previousNavBarTranslucent: Bool = false
    private var previousNavBarStyle: UIBarStyle = .default
    private var previousNavBarTintColor: UIColor = .white
    private var previousNavBarBarTintColor: UIColor = .white
    private var previousViewControllerBackButton: UIBarButtonItem!
    private var previousNavigationBarBackgroundImageDefault: UIImage?
    private var previousNavigationBarBackgroundImageLandscapePhone: UIImage?
    
    // Video
    private var currentVideoPlayerViewController: AVPlayerViewController!
    private var currentVideoIndex: Int = 0
    private var currentVideoLoadingIndicator: UIActivityIndicatorView!
    
    // Misc
    private var hasBelongedToViewController = false
    private var statusBarShouldBeHidden = false
    private var leaveStatusBarAlone = false
    private var performingLayout = false
    private var rotating = false
    private var viewIsActive = false
    private var didSavePreviousStateOfNavBar = false
    private var skipNextPagingScrollViewPositioning = false
    private var viewHasAppearedInitially = false
    private var currentGridContentOffset: CGPoint = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
    
    var zoomPhotosToFill = false
    
    var displayNavArrows = false
    
    var displayActionButton = false
    
    var displaySelectionButtons = false

    var alwaysShowControls = false
    
    var enableGrid = false
    
    var enableSwipeToDismiss = false

    var startOnGrid = false
    
    var autoPlayOnAppear = false
    
    var delayToHideElements: TimeInterval = 0
    
    var currentIndex: Int {
        return currentPageIndex
    }
    
    var activityViewController: UIActivityViewController?

    // Customise image selection icons as they are the only icons with a colour tint
    // Icon should be located in the app's main bundle
    var customImageSelectedIconName: String = ""
    var customImageSelectedSmallIconName: String = ""
    
    init() {
        super.init(nibName: nil, bundle: nil)
        initialisation()
    }

    init(delegate: SSPhotoBrowserDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        initialisation()
    }

    init(photos: [SSPhoto]) {
        super.init(nibName: nil, bundle: nil)
        fixedPhotosArray = photos
        initialisation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialisation()
    }

    func initialisation() {
        hidesBottomBarWhenPushed = true
        hasBelongedToViewController = false
        photoCount = 0
        previousLayoutBounds = .zero
        currentPageIndex = 0
        previousPageIndex = .max
        displayActionButton = true
        displayNavArrows = false
        zoomPhotosToFill = true
        performingLayout = false
        rotating = false
        viewIsActive = false
        enableGrid = true
        startOnGrid = false
        enableSwipeToDismiss = true
        delayToHideElements = 5
        didSavePreviousStateOfNavBar = false
        
        if #available(iOS 11.0, *) {
            pagingScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleMWPhotoLoadingDidEndNotification(_:)), name: .SS_PHOTO_LOADING_DID_END_NOTIFICATION, object: nil)
    }
    
    deinit {
        clearCurrentVideo()
        pagingScrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
        releaseAllUnderlyingPhotos(false)
    }

    func releaseAllUnderlyingPhotos(_ preserveCurrent: Bool) {
        // Create a copy in case this array is modified while we are looping through
        // Release photos
        for photo in photos {
            if let p = photo {
                if preserveCurrent && p == self.photo(at: currentIndex) {
                    // skip current
                    continue
                }
                p.unloadUnderlyingImage()
            }
        }
        // Release thumbs
        for photo in thumbPhotos {
            if let p = photo {
                p.unloadUnderlyingImage()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        releaseAllUnderlyingPhotos(true)
        recycledPages.removeAll()
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
    }
    

    // MARK: - View Loading
    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Validate grid settings
        if startOnGrid { enableGrid = true }
        if enableGrid {
            enableGrid = delegate?.photoBrowser(self, thumbPhotoAt: 0) != nil
        }
        if !enableGrid { startOnGrid = false }
        
        // View
        view.backgroundColor = .black
        view.clipsToBounds = true
        
        // Setup paging scrolling view
        let pagingScrollViewFrame = frameForPagingScrollView()
        pagingScrollView.frame = pagingScrollViewFrame
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        // Toolbar
        toolbar.frame = frameForToolbar(at: UIDevice.current.orientation)
        // Toolbar Items
        if displayNavArrows {
            let previousButtonImage = UIImage(named: "UIBarButtonItemArrowLeft")
            let nextButtonImage = UIImage(named: "UIBarButtonItemArrowRight")
            previousButton = UIBarButtonItem(image: previousButtonImage, style: .plain, target: self, action: #selector(gotoPreviousPage))
            nextButton = UIBarButtonItem(image: nextButtonImage, style: .plain, target: self, action: #selector(gotoNextPage))
        }
        if displayActionButton {
            actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonPressed(_:)))
        }
        // Update
        reloadData()
        
        // Swipe to dismiss
        if enableSwipeToDismiss {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(doneButtonPressed(_:)))
            swipeGesture.direction = [.down, .up]
            view.addGestureRecognizer(swipeGesture)
        }
    }

    func performLayout() {
        // Setup
        performingLayout = true
        let number = numberOfPhotos()
        // Setup pages
        visiblePages.removeAll()
        recycledPages.removeAll()
        
        // Navigation buttons
        if let nav = navigationController {
            if nav.viewControllers.first == self {
                // We're first on stack so show done button
                doneButton = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(doneButtonPressed(_:)))
                // Set appearance
                doneButton?.setBackgroundImage(nil, for: .normal, barMetrics: .default)
                doneButton?.setBackgroundImage(nil, for: .normal, barMetrics: .compact)
                doneButton?.setBackgroundImage(nil, for: .highlighted, barMetrics: .default)
                doneButton?.setBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
                doneButton?.setTitleTextAttributes([:], for: .normal)
                doneButton?.setTitleTextAttributes([:], for: .highlighted)
                navigationItem.rightBarButtonItem = doneButton
            } else if nav.viewControllers.count > 1 {
                // We're not first so show back button
                let previousViewController = nav.viewControllers[nav.viewControllers.count - 2]
                let backButtonTitle = previousViewController.navigationItem.backBarButtonItem?.title ?? previousViewController.title
                let newBackButton = UIBarButtonItem(title: backButtonTitle ?? "返回", style: .plain, target: nil, action: nil)
                // Appearance
                newBackButton.setBackgroundImage(nil, for: .normal, barMetrics: .default)
                newBackButton.setBackgroundImage(nil, for: .normal, barMetrics: .compact)
                newBackButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .default)
                newBackButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
                newBackButton.setTitleTextAttributes([:], for: .normal)
                newBackButton.setTitleTextAttributes([:], for: .highlighted)
                previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem
                previousViewController.navigationItem.backBarButtonItem = newBackButton
            }
        }
        
        // Toolbar items
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixedSpace.width = 32 // To balance action button
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        
        var hasItems: Bool = false
        // Left button - Grid
        if enableGrid {
            hasItems = true
            items.append(UIBarButtonItem(image: UIImage(named: "UIBarButtonItemGrid"), style: .plain, target: self, action: #selector(showGridAnimated)))
        } else {
            items.append(fixedSpace)
        }
        // Middle - Nav
        if let previous = previousButton, let next = nextButton, number > 1 {
            hasItems = true
            items.append(flexSpace)
            items.append(previous)
            items.append(flexSpace)
            items.append(next)
            items.append(flexSpace)
        } else {
            items.append(flexSpace)
        }
        
        // Right - Action
        if let action = actionButton, !(!hasItems && navigationItem.rightBarButtonItem == nil) {
            items.append(action)
        } else {
            // We're not showing the toolbar so try and show in top right
            if let action = actionButton {
                navigationItem.rightBarButtonItem = action
            }
            items.append(fixedSpace)
        }
        
        // Toolbar visibility
        toolbar.setItems(items, animated: true)
        var hideToolbar = true
        for item in items {
            if item != fixedSpace && item != flexSpace {
                hideToolbar = false
                break
            }
        }
        if hideToolbar {
            toolbar.removeFromSuperview()
        } else {
            view.addSubview(toolbar)
        }
        // Update nav
        updateNavigation()
        
        // Content offset
        pagingScrollView.contentOffset = contentOffsetForPage(at: currentPageIndex)
        tilePages()
        performingLayout = false
    }

    func presentingViewControllerPrefersStatusBarHidden() -> Bool {
        if let presenting = self.presentingViewController {
            if let nav = presenting as? UINavigationController {
                return nav.topViewController?.prefersStatusBarHidden == true
            }
        } else {
            // We're in a navigation controller so get previous one!
            if let nav = navigationController, nav.viewControllers.count > 1 {
                let vc = nav.viewControllers[nav.viewControllers.count - 2]
                return vc.prefersStatusBarHidden
            }
        }
        return false
    }

    //MARK: - Appearance
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Status bar
        if !viewHasAppearedInitially {
            leaveStatusBarAlone = presentingViewControllerPrefersStatusBarHidden()
            // Check if status bar is hidden on first appear, and if so then ignore it
            if #available(iOS 13.0, *) {
                if let scenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
                    for scene in scenes {
                        if scene.activationState == .foregroundActive, let manager = scene.statusBarManager {
                            if manager.statusBarFrame.equalTo(.zero) {
                                leaveStatusBarAlone = true
                            }
                        }
                    }
                }
            } else {
                leaveStatusBarAlone = UIApplication.shared.statusBarFrame.equalTo(.zero)
            }
        }
        // Set style
        if !leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == .phone {
            // update to lightContent
            setNeedsStatusBarAppearanceUpdate()
        }
        // Navigation bar appearance
        if !viewIsActive && navigationController?.viewControllers.first != self {
            storePreviousNavBarAppearance()
        }
        setNavBarAppearance(animated)
        // Update UI
        hideControlsAfterDelay()
        // Initial appearance
        if !viewHasAppearedInitially {
            if startOnGrid {
                showGrid(false)
            }
        }
        // If rotation occured while we're presenting a modal
        // and the index changed, make sure we show the right one now
        if currentPageIndex != pageIndexBeforeRotation {
            jumpToPage(at: pageIndexBeforeRotation, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsActive = true
        // Autoplay if first is video
        if !viewHasAppearedInitially, autoPlayOnAppear {
            if let photo = photo(at: currentPageIndex), photo.isVideo {
                playVideo(at: currentPageIndex)
            }
        }
        
        viewHasAppearedInitially = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Detect if rotation occurs while we're presenting a modal
        pageIndexBeforeRotation = currentPageIndex
        // Check that we're being popped for good
        if navigationController?.viewControllers.first != self && navigationController?.viewControllers.contains(self) == false {
            // State
            viewIsActive = false
            // Bar state / appearance
            restorePreviousNavBarAppearance(animated)
        }
        
        // Controls
        // Stop all animations on nav bar
        navigationController?.navigationBar.layer.removeAllAnimations()
        // Cancel any pending toggles from taps
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        setControls(hidden: false, animated: false, permanent: true)
        
        // Status bar
        if !leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == .phone {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        assert(parent != nil && hasBelongedToViewController, "SSPhotoBrowser instances cannot be reused.")
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil { hasBelongedToViewController = true }
    }
    
    //MARK: - Nav Bar Appearance
    
    func setNavBarAppearance(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = .white
            navBar.barTintColor = nil
            navBar.shadowImage = nil
            navBar.isTranslucent = true
            navBar.barStyle = .blackTranslucent
            navBar.setBackgroundImage(nil, for: .default)
        }
    }
    
    func storePreviousNavBarAppearance() {
        didSavePreviousStateOfNavBar = true
        previousNavBarBarTintColor = navigationController?.navigationBar.barTintColor ?? .white
        previousNavBarTranslucent = navigationController?.navigationBar.isTranslucent == true
        previousNavBarTintColor = navigationController?.navigationBar.tintColor ?? .white
        previousNavBarHidden = navigationController?.navigationBar.isHidden ?? false
        previousNavBarStyle = navigationController?.navigationBar.barStyle ?? .default
        previousNavigationBarBackgroundImageDefault = navigationController?.navigationBar.backgroundImage(for: .default)
        previousNavigationBarBackgroundImageLandscapePhone = navigationController?.navigationBar.backgroundImage(for: .compact)
    }
    
    func restorePreviousNavBarAppearance(_ animated: Bool) {
        if didSavePreviousStateOfNavBar {
            navigationController?.setNavigationBarHidden(previousNavBarHidden, animated: animated)
            if let navBar = navigationController?.navigationBar {
                navBar.tintColor = previousNavBarTintColor
                navBar.barTintColor = previousNavBarBarTintColor
                navBar.isTranslucent = previousNavBarTranslucent
                navBar.barStyle = previousNavBarStyle
                navBar.setBackgroundImage(previousNavigationBarBackgroundImageDefault, for: .default)
                navBar.setBackgroundImage(previousNavigationBarBackgroundImageLandscapePhone, for: .compact)
                // Restore back button if we need to
                if let backBtn = previousViewControllerBackButton {
                    navigationController?.topViewController?.navigationItem.backBarButtonItem = backBtn
                    previousViewControllerBackButton = nil
                }
            }
        }
    }
    
    //MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutVisiblePages()
    }

    func layoutVisiblePages() {
        // Flag
        performingLayout = true
        // Toolbar
        toolbar.frame = frameForToolbar(at: UIDevice.current.orientation)
        // Remember index
        let indexPriorToLayout = currentPageIndex
        // Get paging scroll view frame to determine if anything needs changing
        let pagingScrollViewFrame = frameForPagingScrollView()
        // Frame needs changing
        if !skipNextPagingScrollViewPositioning {
            pagingScrollView.frame = pagingScrollViewFrame
        }
        skipNextPagingScrollViewPositioning = false
        // Recalculate contentSize based on current orientation
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        // Adjust frames and configuration of each visible page
        for page in visiblePages {
            let index = page.index
            page.frame = frameForPage(at: index)
            if let v = page.captionView {
                v.frame = frameForCaptionView(v, at: index)
            }
            if let v = page.selectedButton {
                v.frame = frameForSelectedButton(v, at: index)
            }
            if let v = page.playButton {
                v.frame = frameForPlayButton(v, at: index)
            }
            // Adjust scales if bounds has changed since last time
            if !previousLayoutBounds.equalTo(view.bounds) {
                // Update zooms for new bounds
                page.setMaxMinZoomScalesForCurrentBounds()
                previousLayoutBounds = view.bounds
            }
        }
        // Adjust video loading indicator if it's visible
        positionVideoLoadingIndicator()
        
        // Adjust contentOffset to preserve page location based on values collected prior to location
        pagingScrollView.contentOffset = contentOffsetForPage(at: indexPriorToLayout)
        didStartViewingPage(at: currentPageIndex)
        
        // Reset
        currentPageIndex = indexPriorToLayout
        performingLayout = false
    }
    
    //MARK: - Rotation

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Remember page index before rotation
        pageIndexBeforeRotation = currentPageIndex
        rotating = true
        
        // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
        if areControlsHidden() {
            // Force hidden
            navigationController?.isNavigationBarHidden = true
        }
    }

    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Perform layout
        currentPageIndex = pageIndexBeforeRotation
        // Delay control holding
        hideControlsAfterDelay()
        // Layout
        layoutVisiblePages()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        rotating = false
        // Ensure nav bar isn't re-displayed
        if areControlsHidden() {
            navigationController?.isNavigationBarHidden = false
            navigationController?.navigationBar.alpha = 0
        }
    }
    
    //MARK: - Data
    
    func reloadData() {
        // Reset
        photoCount = 0
        // Get data
        let number = numberOfPhotos()
        releaseAllUnderlyingPhotos(true)
        photos.removeAll()
        thumbPhotos.removeAll()
        for _ in 0..<number {
            photos.append(nil)
            thumbPhotos.append(nil)
        }
        // Update current page index
        currentPageIndex = number > 0 ? max(min(currentPageIndex, number - 1), 0) : 0
        
        // Update layout
        if isViewLoaded {
            while !pagingScrollView.subviews.isEmpty {
                pagingScrollView.subviews.last?.removeFromSuperview()
            }
            performLayout()
            view.setNeedsLayout()
        }
    }

    func numberOfPhotos() -> Int {
        if let count = delegate?.numberOfPhotos(in: self) {
            return count
        } else if let array = fixedPhotosArray {
            return array.count
        }
        return photoCount
    }
    
    func photo(at index: Int) -> SSPhoto? {
        if index < photos.count {
            if let photo = photos[index] {
                return photo
            } else {
                if let photo = delegate?.photoBrowser(self, photoAt: index) {
                    photos[index] = photo
                    return photo
                } else if let array = fixedPhotosArray, index < array.count {
                    photos[index] = array[index]
                    return array[index]
                }
            }
        }
        return nil
    }
    
    func thumbPhoto(at index: Int) -> SSPhoto? {
        if index < thumbPhotos.count {
            if let photo = thumbPhotos[index] {
                return photo
            } else {
                if let photo = delegate?.photoBrowser(self, thumbPhotoAt: index) {
                    thumbPhotos[index] = photo
                    return photo
                }
            }
        }
        return nil
    }

    func captionViewForPhoto(at index: Int) -> SSCaptionView? {
        if let view = delegate?.photoBrowser(self, captionViewForPhotoAt: index) {
            view.alpha = areControlsHidden() ? 0 : 1
            return view
        } else if let photo = photo(at: index), !photo.caption.isEmpty {
            let view = SSCaptionView(photo: photo)
            view.alpha = areControlsHidden() ? 0 : 1
            return view
        }
        return nil
    }

    func photoIsSelected(at index: Int) -> Bool {
        if displaySelectionButtons, let result = delegate?.photoBrowser(self, isPhotoSelectedAtIndex: index) {
            return result
        }
        return false
    }
    
    func photoSelected(_ selected: Bool, at index: Int) {
        if displaySelectionButtons {
            delegate?.photoBrowser(self, photoAt: index, selectedChanged: selected)
        }
    }

    func image(for photo: SSPhoto?) -> UIImage? {
        if let p = photo {
            if let image = p.underlyingImage {
                return image
            } else {
                p.loadUnderlyingImageAndNotify()
            }
        }
        return nil
    }

    func loadAdjacentPhotosIfNecessary(photo: SSPhoto) {
        if let page = pageDisplayingPhoto(photo) {
            // If page is current page then initiate loading of previous and next pages
            let pageIndex = page.index
            if currentPageIndex == pageIndex {
                if pageIndex > 0 {
                    // Preload index - 1
                    if let photo = self.photo(at: pageIndex - 1) {
                        if photo.underlyingImage == nil {
                            photo.loadUnderlyingImageAndNotify()
                            print("Pre-loading image at index \(pageIndex - 1)")
                        }
                    }
                }
                if pageIndex < numberOfPhotos() - 1 {
                    // Preload index + 1
                    if let photo = self.photo(at: pageIndex + 1) {
                        if photo.underlyingImage == nil {
                            photo.loadUnderlyingImageAndNotify()
                            print("Pre-loading image at index \(pageIndex + 1)")
                        }
                    }
                }
            }
        }
    }

    //MARK: - SSPhoto Loading Notification
    
    @objc func handleMWPhotoLoadingDidEndNotification(_ notification: Notification) {
        if let photo = notification.object as? SSPhoto,
           let page = pageDisplayingPhoto(photo) {
            if let _ = photo.underlyingImage {
                // Successful load
                page.displayImage()
                loadAdjacentPhotosIfNecessary(photo: photo)
            } else {
                // Failed to load
                page.displayImageFailure()
            }
            // Update nav
            updateNavigation()
        }
    }

    //MARK: - Paging
    func tilePages() {
        // Calculate which pages should be visible
        // Ignore padding as paging bounces encroach on that
        // and lead to false page loads
        let visibleBounds = pagingScrollView.bounds
        var iFirstIndex = Int(floor((visibleBounds.minX + PADDING*2)/visibleBounds.width))
        var iLastIndex = Int(floor((visibleBounds.minX - PADDING*2 - 1)/visibleBounds.width))
        if iFirstIndex < 0 { iFirstIndex = 0 }
        if iFirstIndex > numberOfPhotos() - 1 { iFirstIndex = numberOfPhotos() - 1 }
        if iLastIndex < 0 { iLastIndex = 0 }
        if iLastIndex > numberOfPhotos() - 1 { iLastIndex = numberOfPhotos() - 1 }
        
        // Recycle no longer needed pages
        var pageIndex: Int = 0
        for page in visiblePages {
            pageIndex = page.index
            if pageIndex < iFirstIndex || pageIndex > iLastIndex {
                recycledPages.append(page)
                page.captionView?.removeFromSuperview()
                page.selectedButton?.removeFromSuperview()
                page.playButton?.removeFromSuperview()
                page.prepareForReuse()
                print("Removed page at index \(pageIndex)")
            }
        }
        visiblePages.removeAll(where: { page in
            recycledPages.contains(where: { $0 == page })
        })
        while recycledPages.count > 2 {
            recycledPages.removeFirst()
        }
        // Add missing pages
        for i in iFirstIndex...iLastIndex {
            if !isDisplayingPage(for: i) {
                // Add new page
                let page = dequeueRecycledPage() ?? SSZoomScrollView(browser: self)
                visiblePages.append(page)
                configurePage(page, for: i)
                
                pagingScrollView.addSubview(page)
                print("Added page at index \(i)")
                
                // Add caption
                if let captionView = captionViewForPhoto(at: i) {
                    captionView.frame = frameForCaptionView(captionView, at: i)
                    pagingScrollView.addSubview(captionView)
                    page.captionView = captionView
                }
                
                // Add play button if needed
                if page.displayingVideo() {
                    let playButton = UIButton(type: .custom)
                    playButton.setImage(UIImage(named: "PlayButtonOverlayLarge"), for: .normal)
                    playButton.setImage(UIImage(named: "PlayButtonOverlayLargeTap"), for: .highlighted)
                    playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
                    playButton.sizeToFit()
                    playButton.frame = frameForPlayButton(playButton, at: i)
                    pagingScrollView.addSubview(playButton)
                    page.playButton = playButton
                }
                
                // Add selected button
                if displaySelectionButtons {
                    let selectedButton = UIButton(type: .custom)
                    selectedButton.setImage(UIImage(named: "ImageSelectedOff")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    let selectedOnImage = UIImage(named: customImageSelectedIconName) ?? UIImage(named: "ImageSelectedOn")
                    selectedButton.setImage(selectedOnImage?.withRenderingMode(.alwaysOriginal), for: .selected)
                    selectedButton.sizeToFit()
                    selectedButton.addTarget(self, action: #selector(selectedButtonTapped(_:)), for: .touchUpInside)
                    selectedButton.frame = frameForSelectedButton(selectedButton, at: i)
                    pagingScrollView.addSubview(selectedButton)
                    page.selectedButton = selectedButton
                    selectedButton.isSelected = photoIsSelected(at: i)
                }
            }
        }
    }
    
    func updateVisiblePageStates() {
        visiblePages.forEach { page in
            page.selectedButton.isSelected = self.photoIsSelected(at: page.index)
        }
    }
    
    func isDisplayingPage(for index: Int) -> Bool {
        return visiblePages.contains(where: { $0.index == index })
    }
    
    func pageDisplayed(at index: Int) -> SSZoomScrollView? {
        return visiblePages.first(where: { $0.index == index })
    }

    func pageDisplayingPhoto(_ photo: SSPhoto) -> SSZoomScrollView? {
        return visiblePages.first(where: { $0.photo == photo })
    }
    
    func configurePage(_ page: SSZoomScrollView, for index: Int) {
        page.frame = frameForPage(at: index)
        page.index = index
        page.photo = photo(at: index)
    }

    func dequeueRecycledPage() -> SSZoomScrollView? {
        if let page = recycledPages.randomElement() {
            return page
        }
        return nil
    }

    // Handle page changes
    func didStartViewingPage(at index: Int) {
        // Handle 0 photos
        if numberOfPhotos() == 0 {
            // Show controls
            setControls(hidden: false, animated: true, permanent: true)
            return
        }
        // Handle video on page change
        if !rotating || index != currentVideoIndex {
            clearCurrentVideo()
        }
        
        // Release images further away than +/-1
        if index > 0 {
            // Release anything < index - 1
            for i in 0..<index-1 {
                if let photo = photos[i] {
                    photo.unloadUnderlyingImage()
                    photos[i] = nil
                    print("Released underlying image at index \(i)")
                }
            }
        }
        if index < numberOfPhotos() - 1 {
            // Release anything > index + 1
            for i in index+2..<photos.count {
                if let photo = photos[i] {
                    photo.unloadUnderlyingImage()
                    photos[i] = nil
                    print("Released underlying image at index \(i)")
                }
            }
        }
        // Load adjacent images if needed and the photo is already
        // loaded. Also called after photo has been loaded in background
        if let currentPhoto = photo(at: index), currentPhoto.underlyingImage != nil {
            // photo loaded so load ajacent now
            loadAdjacentPhotosIfNecessary(photo: currentPhoto)
        }
        // Notify delegate
        if index != previousPageIndex {
            delegate?.photoBrowser(self, didDisplayPhotoAt: index)
            previousPageIndex = index
        }
        // Update nav
        updateNavigation()
    }

    //MARK: - Frame Calculations
    
    func frameForPagingScrollView() -> CGRect {
        // UIScreen.main.bounds
        var frame = self.view.bounds
        frame.origin.x -= PADDING
        frame.size.width += (2 * PADDING)
        return CGRectIntegral(frame)
    }

    func frameForPage(at index: Int) -> CGRect {
        // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
        // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
        // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
        // because it has a rotation transform applied.
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * PADDING)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + PADDING
        return CGRectIntegral(pageFrame)
    }
    
    func contentSizeForPagingScrollView() -> CGSize {
        let bounds = pagingScrollView.bounds
        return CGSize(width: bounds.size.width * CGFloat(numberOfPhotos()), height: bounds.size.height)
    }

    func contentOffsetForPage(at index: Int) -> CGPoint {
        let pageWidth = pagingScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPoint(x: newOffset, y: 0)
    }

    func frameForToolbar(at orientation: UIDeviceOrientation) -> CGRect {
        let height: CGFloat = (UI_USER_INTERFACE_IDIOM() == .phone && orientation.isLandscape) ? 32 : 44
        return CGRectIntegral(CGRect(x: 0, y: view.bounds.size.height - height, width: view.bounds.size.width, height: height))
    }

    func frameForCaptionView(_ captionView: SSCaptionView, at index: Int) -> CGRect {
        let pageFrame = frameForPage(at: index)
        let captionSize = captionView.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0))
        let toolbarHeight: CGFloat = toolbar.superview != nil ? toolbar.frame.size.height : 0
        let captionFrame = CGRect(x: pageFrame.origin.x,
                                  y: pageFrame.size.height - captionSize.height - toolbarHeight,
                                  width: pageFrame.size.width,
                                  height: captionSize.height)
        return CGRectIntegral(captionFrame)
    }

    func frameForSelectedButton(_ selectedButton: UIButton, at index: Int) -> CGRect {
        let pageFrame = frameForPage(at: index)
        let padding: CGFloat = 20
        var yOffset: CGFloat = 0
        if !areControlsHidden(), let navBar = navigationController?.navigationBar {
            yOffset = navBar.frame.origin.y + navBar.frame.size.height
        }
        let selectedButtonFrame = CGRect(x: pageFrame.origin.x + pageFrame.width - selectedButton.frame.width - padding,
                                         y: padding + yOffset,
                                         width: selectedButton.frame.width,
                                         height: selectedButton.frame.height)
        return CGRectIntegral(selectedButtonFrame)
    }
    
    func frameForPlayButton(_ playButton: UIButton, at index: Int) -> CGRect {
        let pageFrame = frameForPage(at: index)
        return CGRect(x: pageFrame.midX - playButton.frame.width/2,
                      y: pageFrame.midY - playButton.frame.height/2,
                      width: playButton.frame.width,
                      height: playButton.frame.height)
    }

    //MARK: - Navigation
    func updateNavigation() {
        // Title
        let number = numberOfPhotos()
        if let gird = gridController {
            if gird.selectionMode {
                title = "Select Photos"
            } else {
                if number == 1 {
                    title = NSLocalizedString("photo", comment: "Used in the context: '1 photo'")
                } else {
                    title = NSLocalizedString("photos", comment: "Used in the context: '3 photos'")
                }
            }
        } else if number > 1 {
            if let t = delegate?.photoBrowser(self, titleForPhotoAt: currentPageIndex) {
                title = t
            } else {
                title = "\(currentPageIndex) \(NSLocalizedString("of", comment: "Used in the context: 'Showing 1 of 3 items'")) \(number)"
            }
        } else {
            title = ""
        }
        
        // Buttons
        previousButton?.isEnabled = currentPageIndex > 0
        nextButton?.isEnabled = currentPageIndex < number - 1

        // Disable action button if there is no image or it's a video
        if let photo = photo(at: currentPageIndex), let _ = photo.underlyingImage, photo.isVideo {
            actionButton?.isEnabled = false
            // Tint to hide button
            actionButton?.tintColor = .clear
        } else {
            actionButton?.isEnabled = true
            // Tint to hide button
            actionButton?.tintColor = nil
        }
    }

    func jumpToPage(at index: Int, animated: Bool) {
        // Change page
        if index < numberOfPhotos() {
            let pageFrame = frameForPage(at: index)
            pagingScrollView.setContentOffset(CGPoint(x: pageFrame.origin.x - PADDING, y: 0), animated: animated)
            updateNavigation()
        }
        // Update timer to give more time
        hideControlsAfterDelay()
    }
    
    @objc func gotoPreviousPage() {
        showPreviousPhotoAnimated(false)
    }
    
    @objc func gotoNextPage() {
        showNextPhotoAnimated(false)
    }
    
    func showPreviousPhotoAnimated(_ animated: Bool) {
        jumpToPage(at: currentPageIndex-1, animated: animated)
    }
    
    func showNextPhotoAnimated(_ animated: Bool) {
        jumpToPage(at: currentPageIndex+1, animated: animated)
    }
    
    //MARK: - Interactions
    
    @objc func selectedButtonTapped(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.isSelected.toggle()
            var index: Int = .max
            for page in visiblePages {
                if page.selectedButton == btn {
                    index = page.index
                    break
                }
            }
            if index != .max {
                photoSelected(btn.isSelected, at: index)
            }
        }
    }
    
    @objc func playButtonTapped(_ sender: Any) {
        if let btn = sender as? UIButton {
            var index: Int = .max
            for page in visiblePages {
                if page.playButton == btn {
                    index = page.index
                    break
                }
            }
            if index != .max && currentVideoPlayerViewController != nil {
                playVideo(at: index)
            }
        }
    }

    //MARK: - Video
    
    func playVideo(at index: Int) {
        if let photo = photo(at: index) {
            // Valid for playing
            clearCurrentVideo()
            setVideoLoadingIndicatorVisible(true, at: index)
            // Get video and play
            photo.getVideoURL { [weak self] videoUrl in
                DispatchQueue.main.async {
                    if let url = videoUrl {
                        self?.playVideo(with: url, at: index)
                    } else {
                        self?.setVideoLoadingIndicatorVisible(false, at: index)
                    }
                }
            }
        }
    }
    
    func playVideo(with url: URL, at index: Int) {
        // Setup player
        let playItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playItem)
        let vc = AVPlayerViewController()
        currentVideoPlayerViewController = vc
        vc.player = player
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        // Remove the movie player view controller from the "playback did finish" notification observers
        // Observe ourselves so we can get it to use the crossfade transition
        NotificationCenter.default.removeObserver(vc, name: .AVPlayerItemDidPlayToEndTime, object: player)
        NotificationCenter.default.removeObserver(vc, name: .AVPlayerItemFailedToPlayToEndTime, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(videoFinishedCallback(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(videoFailedCallback(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player)
        // Show
        present(vc, animated: true) {
            player.play()
        }
    }

    @objc func videoFinishedCallback(_ notification: Notification) {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentVideoPlayerViewController?.player)
        // Clear up
        clearCurrentVideo()
        // Dismiss
        dismiss(animated: true)
    }
    
    @objc func videoFailedCallback(_ notification: Notification) {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentVideoPlayerViewController?.player)
        // Clear up
        clearCurrentVideo()
        // Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    func clearCurrentVideo() {
        currentVideoLoadingIndicator?.removeFromSuperview()
        currentVideoPlayerViewController = nil
        currentVideoLoadingIndicator = nil
        currentVideoIndex = .max
    }
    
    func setVideoLoadingIndicatorVisible(_ visible: Bool, at pageIndex: Int) {
        if visible {
            let indicator = UIActivityIndicatorView(frame: .zero)
            indicator.sizeToFit()
            indicator.startAnimating()
            pagingScrollView.addSubview(indicator)
            currentVideoLoadingIndicator = indicator

            positionVideoLoadingIndicator()
        } else {
            currentVideoLoadingIndicator?.removeFromSuperview()
            currentVideoLoadingIndicator = nil
        }
    }
    
    func positionVideoLoadingIndicator() {
        if currentVideoLoadingIndicator != nil && currentVideoIndex != .max {
            let frame = frameForPage(at: currentVideoIndex)
            currentVideoLoadingIndicator?.center = CGPoint(x: frame.midX, y: frame.midY)
        }
    }
    
    //MARK: - Grid
    
    @objc func showGridAnimated() {
        showGrid(true)
    }
    
    func showGrid(_ animated: Bool) {
        if gridController != nil { return }
        // Init grid controller
        let grid = SSGridViewController()
        self.gridController = grid
        grid.browser = self
        grid.initialContentOffset = currentGridContentOffset
        grid.selectionMode = displaySelectionButtons
        grid.view.frame = view.bounds
        grid.view.frame = CGRectOffset(view.bounds, 0, (startOnGrid ? -1 : 1) * view.bounds.height)
        // Stop specific layout being triggered
        skipNextPagingScrollViewPositioning = true
        // Add as a child view controller
        addChild(grid)
        view.addSubview(grid.view)
        // Perform any adjustments
        if navigationItem.rightBarButtonItem == actionButton {
            gridPreviousRightNavItem = actionButton
            navigationItem.setRightBarButton(nil, animated: true)
        } else {
            gridPreviousRightNavItem = nil
        }
        // Update
        updateNavigation()
        setControls(hidden: false, animated: true, permanent: true)
        // Animate grid in and photo scroller out
        grid.willMove(toParent: self)
        var newPagingFrame = frameForPagingScrollView()
        newPagingFrame = CGRectOffset(newPagingFrame, 0, (startOnGrid ? -1 : 1) * newPagingFrame.height)
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            grid.view.frame = self.view.bounds
            self.pagingScrollView.frame = newPagingFrame
        } completion: { finished in
            grid.didMove(toParent: self)
        }
    }
    
    func hideGrid() {
        guard let grid = gridController else { return }
        // Remember previous content offset
        currentGridContentOffset = grid.collectionView.contentOffset
        // Restore action button if it was removed
        if gridPreviousRightNavItem == actionButton {
            navigationItem.setRightBarButton(actionButton, animated: true)
        }
        // Position prior to hide animation
        let newPagingFrame = frameForPagingScrollView()
        pagingScrollView.frame = CGRectOffset(newPagingFrame, 0, (startOnGrid ? -1 : 1) * newPagingFrame.height)
        
        // Remember and remove controller now so things can detect a nil grid controller
        gridController = nil
        // Update
        updateNavigation()
        updateVisiblePageStates()
        // Animate, hide grid and show paging scroll view
        let newGridFrame = CGRectOffset(view.bounds, 0, (startOnGrid ? -1 : 1) * view.bounds.height)
        UIView.animate(withDuration: 0.3) {
            grid.view.frame = newGridFrame
            self.pagingScrollView.frame = self.frameForPagingScrollView()
        } completion: { finished in
            grid.willMove(toParent: nil)
            grid.view.removeFromSuperview()
            grid.removeFromParent()
            self.setControls(hidden: false, animated: true, permanent: false)
        }
    }
    
    //MARK: - Control Hiding / Showing
    
    // If permanent then we don't set timers to hide again
    // Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
    func setControls(hidden: Bool, animated: Bool, permanent: Bool) {
        // Force visible
        var isHidden = hidden
        if numberOfPhotos() == 0 || gridController != nil || alwaysShowControls {
            isHidden = false
        }
        // Cancel any timers
        cancelControlHiding()
        // Animations & positions
        let animatonOffset: CGFloat = 20
        let animationDuration: TimeInterval = animated ? 0.35 : 0
        // Status bar
        if !leaveStatusBarAlone {
            // Hide status bar
            if #available(iOS 9.0, *) {
                statusBarShouldBeHidden = isHidden
                UIView.animate(withDuration: animationDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            } else {
                UIApplication.shared.setStatusBarHidden(isHidden, with: animated ? .slide : .none)
            }
        }
        // Toolbar, nav bar and captions
        // Pre-appear animation positions for sliding
        if areControlsHidden() && !isHidden && animated {
            // Toolbar
            toolbar.frame = CGRectOffset(frameForToolbar(at: UIDevice.current.orientation), 0, animatonOffset)
            // Captions
            for page in visiblePages {
                if let v = page.captionView {
                    // Pass any index, all we're interested in is the Y
                    var captionFrame = frameForCaptionView(v, at: 0)
                    captionFrame.origin.x = v.frame.origin.x
                    v.frame = CGRectOffset(captionFrame, 0, animatonOffset)
                }
            }
        }
        
        UIView.animate(withDuration: animationDuration) {
            let alpha: CGFloat = isHidden ? 0 : 1
            // Nav bar slides up on it's own on iOS 7+
            self.navigationController?.navigationBar.alpha = alpha
            // Toolbar
            self.toolbar.frame = self.frameForToolbar(at: UIDevice.current.orientation)
            if isHidden {
                self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0, animatonOffset)
            }
            self.toolbar.alpha = alpha
        
            for page in self.visiblePages {
                // Captions
                if let v = page.captionView {
                    // Pass any index, all we're interested in is the Y
                    var captionFrame = self.frameForCaptionView(v, at: 0)
                    captionFrame.origin.x = v.frame.origin.x
                    if isHidden {
                        captionFrame = CGRectOffset(captionFrame, 0, animatonOffset)
                    }
                    v.frame = captionFrame
                    v.alpha = alpha
                }
                // Selected buttons
                if let v = page.selectedButton {
                    var newFrame = self.frameForSelectedButton(v, at: 0)
                    newFrame.origin.x = v.frame.origin.x
                    v.frame = newFrame
                }
            }
        }
        // Control hiding timer
        // Will cancel existing timer but only begin hiding if
        // they are visible
        if !permanent {
            hideControlsAfterDelay()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if !leaveStatusBarAlone {
            return statusBarShouldBeHidden
        }
        return presentingViewControllerPrefersStatusBarHidden()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func cancelControlHiding() {
        // If a timer exists then cancel and release
        controlVisibilityTimer?.invalidate()
        controlVisibilityTimer = nil
    }

    // Enable/disable control visiblity timer
    func hideControlsAfterDelay() {
        if !areControlsHidden() {
            cancelControlHiding()
            controlVisibilityTimer = Timer.scheduledTimer(timeInterval: delayToHideElements, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
        }
    }

    func areControlsHidden() -> Bool { return toolbar.alpha == 0 }
    @objc func hideControls() { setControls(hidden: true, animated: true, permanent: false) }
    @objc func showControls() { setControls(hidden: false, animated: true, permanent: false) }
    @objc func toggleControls() { setControls(hidden: !areControlsHidden(), animated: true, permanent: false) }

    func setCurrentPhotoIndex(_ index: Int) {
        // Validate
        let photoCount = numberOfPhotos()
        if photoCount == 0 {
            currentPageIndex = 0
        } else {
            if index >= photoCount {
                currentPageIndex = photoCount - 1
            }
        }
        if isViewLoaded {
            jumpToPage(at: currentPageIndex, animated: false)
            if !viewIsActive {
                // Force tiling if view is not visible
                tilePages()
            }
        }
    }

    //MARK: - Misc
    @objc func doneButtonPressed(_ sender: Any) {
        // Only if we're modal and there's a done button
        if let _ = doneButton {
            // See if we actually just want to show/hide grid
            if enableGrid {
                if startOnGrid && gridController == nil {
                    showGrid(true)
                    return
                } else if !startOnGrid && gridController != nil {
                    hideGrid()
                    return
                }
            }
            // Dismiss view controller
            if delegate?.photoBrowserDidFinishModalPresentation(self) == false {
                dismiss(animated: true)

            }
        }
    }

    // MARK: - Actions
    @objc func actionButtonPressed(_ sender: Any) {
        // Only react when image has loaded
        if let photo = self.photo(at: currentPageIndex) {
            if numberOfPhotos() > 0, let image = photo.underlyingImage {
                if let d = delegate {
                    // Let delegate handle things
                    d.photoBrowser(self, actionButtonPressedForPhotoAt: currentPageIndex)
                } else {
                    // Show activity view controller
                    var items: [Any] = [image]
                    if !photo.caption.isEmpty {
                        items.append(photo.caption)
                    }
                    let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    activityViewController = vc
                    // Show loading spinner after a couple of seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if self.activityViewController != nil {
                            self.showProgressHUD(with: "")
                        }
                    }
                    // Show
                    vc.completionWithItemsHandler = { [weak self] activityType, completed, items, error in
                        guard let weakSelf = self else { return }
                        weakSelf.activityViewController = nil
                        DispatchQueue.main.async {
                            weakSelf.hideControlsAfterDelay()
                            weakSelf.hideProgressHUD(true)
                        }
                    }
                    // iOS 8 - Set the Anchor Point for the popover
                    vc.popoverPresentationController?.barButtonItem = actionButton
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                // Keep controls hidden
                setControls(hidden: false, animated: true, permanent: true)
            }
        }
    }

    //MARK: - Action Progress
    
    func showProgressHUD(with message: String?) {
        SS.keyWindow?.ss.showHUDLoading(text: message)
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }

    func hideProgressHUD(_ animated: Bool) {
        SS.keyWindow?.ss.hideHUD()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func showProgressHUDCompleteMessage(_ message: String?) {
        if let msg = message {
            if SS.keyWindow?.ss.isShowHUDBar != true {
                SS.keyWindow?.ss.showHUDLoading(text: msg)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SS.keyWindow?.ss.hideHUD()
            }
        } else {
            SS.keyWindow?.ss.hideHUD()
        }
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}

//MARK: - UIScrollView Delegate

extension SSPhotoBrowser: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Checks
        if !viewIsActive || performingLayout || rotating { return }
        // Tile pages
        tilePages()
        // Calculate current page
        let visibleBounds = pagingScrollView.bounds
        var index = Int(visibleBounds.midX / visibleBounds.width)
        if index > numberOfPhotos() - 1 {
            index = numberOfPhotos() - 1
        }

        if currentPageIndex != index {
            currentPageIndex = index
            didStartViewingPage(at: index)
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Hide controls when dragging begins
        setControls(hidden: true, animated: true, permanent: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update nav when page changes
        updateNavigation()
    }
}
