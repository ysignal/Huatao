//
//  SSZoomScrollView.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class SSZoomScrollView: UIScrollView {

    var index: Int = .max
    
    var photo: SSPhoto? {
        willSet {
            photo?.cancelAnyLoading()
        }
        didSet {
            if let _ = photoBrowser.image(for: photo) {
                displayImage()
            } else {
                // Will be loading so show loading
                showLoadingIndicator()
            }
        }
    }
    
    var captionView: SSCaptionView!
    var selectedButton: UIButton!
    var playButton: UIButton!
    
    var photoBrowser: SSPhotoBrowser
    
    lazy var tapView: SSTapDetectingView = {
        let view = SSTapDetectingView()
        view.tapDelegate = self
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .black
        return view
    }()
    
    lazy var photoImageView: SSTapDetectingImageView = {
        let view = SSTapDetectingImageView()
        view.tapDelegate = self
        view.contentMode = .center
        view.backgroundColor = .black
        return view
    }()
    
    lazy var loadingIndicator: SSCircularProgressView = {
        let cp = SSCircularProgressView(frame: CGRect(x: 140, y: 30, width: 40, height: 40))
        cp.isUserInteractionEnabled = false
        cp.thicknessRatio = 0.1
        cp.roundedCorners = false
        cp.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        return cp
    }()
    
    var loadingError: UIImageView!

    init(browser: SSPhotoBrowser) {
        photoBrowser = browser
        super.init(frame: .zero)
        addSubview(tapView)
        // Image view
        addSubview(photoImageView)
        // Loading indicator
        addSubview(loadingIndicator)
        // Listen progress notifications
        NotificationCenter.default.addObserver(self, selector: #selector(setProgressFromNotification), name: .SS_PHOTO_PROGRESS_NOTIFICATION, object: nil)
        
        // Setup
        backgroundColor = .black
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareForReuse() {
        hideImageFailure()
        self.photo = nil
        self.captionView = nil
        self.selectedButton = nil
        self.playButton = nil
        photoImageView.isHidden = false
        photoImageView.image = nil
        index = .max
    }

    func displayingVideo() -> Bool {
        return photo?.isVideo == true
    }

    var isImageHidden: Bool = false {
        didSet {
            photoImageView.isHidden = isImageHidden
        }
    }

    // Get and display image
    func displayImage() {
        if let p = photo, photoImageView.image == nil {
            // Reset
            self.maximumZoomScale = 1
            self.minimumZoomScale = 1
            self.zoomScale = 1
            self.contentSize = .zero
            // Get image from browser as it handles ordering of fetching
            if let image = photoBrowser.image(for: p) {
                // Hide indicator
                hideLoadingIndicator()
                // Set image
                photoImageView.image = image
                photoImageView.isHidden = false
                // Setup photo frame
                let photoImageViewFrame = CGRect(origin: .zero, size: image.size)
                photoImageView.frame = photoImageViewFrame
                self.contentSize = photoImageViewFrame.size
                
                // Set zoom to minimum zoom
                setMaxMinZoomScalesForCurrentBounds()
            } else {
                displayImageFailure()
            }
            setNeedsLayout()
        }
    }
    
    // Image failed so just show black!
    func displayImageFailure() {
        hideLoadingIndicator()
        photoImageView.image = nil
        
        // Show if image is not empty
        if photo?.emptyImage != true {
            if loadingError == nil {
                let iv = UIImageView()
                loadingError = iv
                loadingError?.image = UIImage(named: "ImageError")
//                _loadingError.image = [UIImage imageForResourcePath:@"ImageError" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
                loadingError?.isUserInteractionEnabled = false
                loadingError?.sizeToFit()
                addSubview(iv)
                iv.frame = CGRect(x: (bounds.width - iv.frame.width)/2, y: (bounds.height - iv.frame.height)/2, width: iv.frame.width, height: iv.frame.height)
            }
        }
    }

    func hideImageFailure() {
        loadingError?.removeFromSuperview()
        loadingError = nil
    }

    //MARK: - Loading Progress
    @objc func setProgressFromNotification(_ notification: Notification) {
        if let dict = notification.object as? [String: Any] {
            if let model = dict["photo"] as? SSPhoto {
                if model == model {
                    if let progress = dict["progress"] as? CGFloat {
                        loadingIndicator.progress = max(min(1, progress), 0)
                    }
                }
            }
        }
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.isHidden = true
    }

    func showLoadingIndicator() {
        zoomScale = 0
        minimumZoomScale = 0
        maximumZoomScale = 0
        loadingIndicator.progress = 0
        loadingIndicator.isHidden = false
        hideImageFailure()
    }
    
    //MARK: - Setup
    
    func initialZoomScaleWithMinScale() -> CGFloat {
        var zoomScale = minimumZoomScale
        if photoBrowser.zoomPhotosToFill {
            // Zoom image to fill if the aspect ratios are fairly similar
            let boundsSize = bounds.size
            let imageSize = photoImageView.image?.size ?? .zero
            let boundsAR = boundsSize.width / boundsSize.height
            let imageAR = imageSize.width / imageSize.height
            // the scale needed to perfectly fit the image width-wise
            let xScale = boundsSize.width / imageSize.width
            // the scale needed to perfectly fit the image height-wise
            let yScale = boundsSize.height / imageSize.height
            // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
            if abs(boundsAR - imageAR) < 0.17 {
                zoomScale = max(xScale, yScale)
                // Ensure we don't zoom in or out too far, just in case
                zoomScale = min(max(minimumZoomScale, zoomScale), maximumZoomScale)
            }
        }
        return zoomScale
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        // Reset
        self.maximumZoomScale = 1
        self.minimumZoomScale = 1
        self.zoomScale = 1
        
        // Bail if no image
        if photoImageView.image == nil { return }
        // Reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.width)
        // Sizes
        let boundsSize = bounds.size
        let imageSize = photoImageView.image?.size ?? .zero
        // Calculate Min
        // the scale needed to perfectly fit the image width-wise
        let xScale = boundsSize.width / imageSize.width
        // the scale needed to perfectly fit the image height-wise
        let yScale = boundsSize.height / imageSize.height
        // use minimum of these to allow the image to become fully visible
        let minScale = min(xScale, yScale)
        // Calculate Max
        var maxScale: CGFloat = 3
        if UI_USER_INTERFACE_IDIOM() == .pad {
            // Let them go a bit bigger on a bigger screen!
            maxScale = 4
        }
        // Image is smaller than screen so no zooming!
        // Set min/max zoom
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
        // Initial zoom
        self.zoomScale = initialZoomScaleWithMinScale()
        
        // If we're zooming to fill then centralise
        if self.zoomScale != minScale {
            // Centralise
            self.contentOffset = CGPoint(x: (imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         y: (imageSize.height * self.zoomScale - boundsSize.height) / 2.0)
        }
        
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.isScrollEnabled = false
        
        // If it's a video then disable zooming
        if displayingVideo() {
            self.maximumZoomScale = self.zoomScale
            self.minimumZoomScale = self.zoomScale
        }
        // Layout
        setNeedsLayout()
    }
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update tap view frame
        tapView.frame = self.bounds
        // Position indicators (centre does not seem to work!)
        if !loadingIndicator.isHidden {
            loadingIndicator.frame = CGRect(x: (self.bounds.width - loadingIndicator.frame.width) / 2,
                                            y: (self.bounds.height - loadingIndicator.frame.height) / 2,
                                            width: loadingIndicator.frame.width,
                                            height: loadingIndicator.frame.height)
        }
        if let le = loadingError {
            le.frame = CGRect(x: (self.bounds.width - le.frame.width) / 2,
                              y: (self.bounds.height - le.frame.height) / 2,
                              width: le.frame.width,
                              height: le.frame.height)
        }
        // Super
        super.layoutSubviews()
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = photoImageView.frame
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        if !photoImageView.frame.equalTo(frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
}

//MARK: - UIScrollViewDelegate
extension SSZoomScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        photoBrowser.cancelControlHiding()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        // reset
        isScrollEnabled = true
        photoBrowser.cancelControlHiding()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        photoBrowser.hideControlsAfterDelay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
 
//MARK: - Tap Detection

extension SSZoomScrollView {
    func handleSingleTap(_ touchPoint: CGPoint) {
        photoBrowser.perform(#selector(SSPhotoBrowser.toggleControls), with: nil, afterDelay: 0.2)
    }

    func handleDoubleTap(_ touchPoint: CGPoint) {
        // Dont double tap to zoom if showing a video
        if displayingVideo() {
            return
        }
        
        // Cancel any single tap handling
        NSObject.cancelPreviousPerformRequests(withTarget: photoBrowser)
        
        // Zoom
        if self.zoomScale != self.minimumZoomScale && self.zoomScale != initialZoomScaleWithMinScale() {
            
            // Zoom out
            setZoomScale(self.minimumZoomScale, animated: true)
            
        } else {
            
            // Zoom in to twice the size
            let newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2)
            let xsize = self.bounds.size.width / newZoomScale
            let ysize = self.bounds.size.height / newZoomScale
            zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)

        }
        
        // Delay controls
        photoBrowser.hideControlsAfterDelay()
    }
}

extension SSZoomScrollView: SSTapDetectingImageViewDelegate {
    
    // Image View
    func imageView(_ imageView: UIImageView, singleTapDetected touch: UITouch) {
        handleSingleTap(touch.location(in: imageView))
    }
    
    func imageView(_ imageView: UIImageView, doubleTapDetected touch: UITouch) {
        handleDoubleTap(touch.location(in: imageView))
    }
    
    func imageView(_ imageView: UIImageView, tripleTapDetected touch: UITouch) {}
}

extension SSZoomScrollView: SSTapDetectingViewDelegate {
    func view(_ view: UIView, singleTapDetected touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.location(in: view).x
        var touchY = touch.location(in: view).y
        touchX *= 1/self.zoomScale
        touchY *= 1/self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y

        handleSingleTap(CGPoint(x: touchX, y: touchY))
    }
    
    func view(_ view: UIView, doubleTapDetected touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.location(in: view).x
        var touchY = touch.location(in: view).y
        touchX *= 1/self.zoomScale
        touchY *= 1/self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y
        
        handleDoubleTap(CGPoint(x: touchX, y: touchY))
    }
    
    func view(_ view: UIView, tripleTapDetected touch: UITouch) {}
}
