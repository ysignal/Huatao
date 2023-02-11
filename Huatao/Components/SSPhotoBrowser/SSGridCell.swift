//
//  SSGridCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class SSGridCell: UICollectionViewCell {

    var gridController: SSGridViewController? {
        didSet {
            // Set custom selection image if required
            if let gird = gridController, gird.browser.customImageSelectedSmallIconName.isEmpty {
                selectedButton.setImage(UIImage(named: gird.browser.customImageSelectedSmallIconName), for: .selected)
            }
        }
    }
    
    var index: Int = 0
    
    var photo: SSPhoto? {
        didSet {
            videoIndicator.isHidden = photo?.isVideo != true
            
            if let p = photo {
                if p.underlyingImage == nil {
                    showLoadingIndicator()
                } else {
                    hideLoadingIndicator()
                }
            } else {
                showImageFailure()
            }
        }
    }
    
    var selectionMode: Bool = false
    
    // Image
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = bounds
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        return iv
    }()
    
    lazy var videoIndicator: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = false
        return iv
    }()
    
    var loadingError: UIImageView?
    
    lazy var loadingIndicator: SSCircularProgressView = {
        let view = SSCircularProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.isUserInteractionEnabled = false
        view.thicknessRatio = 0.1
        view.roundedCorners = false
        return view
    }()

    lazy var selectedButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentMode = .topRight
//        [_selectedButton setImage:[UIImage imageForResourcePath:@"ImageSelectedSmallOff" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
//        [_selectedButton setImage:[UIImage imageForResourcePath:@"ImageSelectedSmallOn" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateSelected];
        btn.addTarget(self, action: #selector(selectionButtonPressed), for: .touchDown)
        btn.isHidden = true
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return btn
    }()
    
    override var isSelected: Bool {
        didSet {
            selectedButton.isSelected = isSelected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Grey background
        backgroundColor = .init(white: 0.12, alpha: 1)
        // Image
        addSubview(imageView)
        // Video Image
        addSubview(videoIndicator)
        if let indicatorImage = UIImage(named: "VideoOverlay") {
            videoIndicator.frame = CGRect(x: bounds.width - indicatorImage.size.width - 10, y: bounds.height - indicatorImage.size.height - 10, width: indicatorImage.size.width, height: indicatorImage.size.height)
            videoIndicator.image = indicatorImage
//            videoIndicator.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        }
        // Selection button
        addSubview(selectedButton)
        // Loading indicator
        addSubview(loadingIndicator)
        // Listen for photo loading notifications
        NotificationCenter.default.addObserver(self, selector: #selector(setProgressFromNotification(_:)), name: .SS_PHOTO_PROGRESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMWPhotoLoadingDidEndNotification(_:)), name: .SS_PHOTO_LOADING_DID_END_NOTIFICATION, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - View
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        loadingIndicator.frame = CGRect(x: (bounds.width - loadingIndicator.frame.width)/2,
                                        y: (bounds.height - loadingIndicator.frame.height)/2,
                                        width: loadingIndicator.frame.width,
                                        height: loadingIndicator.frame.height)
        selectedButton.frame = CGRect(x: bounds.width - selectedButton.frame.width - 0,
                                      y: 0,
                                      width: selectedButton.frame.width,
                                      height: selectedButton.frame.height)
    }

    //MARK: - Cell
    override func prepareForReuse() {
        photo = nil
        gridController = nil
        imageView.image = nil
        loadingIndicator.progress = 0
        selectedButton.isHidden = true
        hideImageFailure()
        super.prepareForReuse()
    }

    //MARK: - Image Handling

    func displayImage() {
        imageView.image = photo?.underlyingImage
        selectedButton.isHidden = !selectionMode
        hideImageFailure()
    }

    //MARK: - Selection

    @objc func selectionButtonPressed() {
        selectedButton.isSelected.toggle()
        gridController?.browser?.photoSelected(selectedButton.isSelected, at: index)
    }

    //MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageView.alpha = 0.6
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageView.alpha = 1
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageView.alpha = 1
        super.touchesCancelled(touches, with: event)
    }

    //MARK: - Indicator
    
    func hideLoadingIndicator() {
        loadingIndicator.isHidden = true
    }
    
    func showLoadingIndicator() {
        loadingIndicator.progress = 0
        loadingIndicator.isHidden = false
        hideImageFailure()
    }

    private func showImageFailure() {
        // Only show if image is not empty
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
        hideLoadingIndicator()
        imageView.image = nil
    }

    private func hideImageFailure() {
        if loadingError != nil {
            loadingError?.removeFromSuperview()
            loadingError = nil
        }
    }

    //MARK: - Notifications
    @objc func setProgressFromNotification(_ notification: Notification) {
        if let dict = notification.object as? [String: Any],
           let photoWithProgress = dict["photo"] as? SSPhoto {
            if photoWithProgress == photo {
                if let progress = dict["progress"] as? CGFloat {
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingIndicator.progress = max(min(1, progress), 0)
                    }
                }
            }
        }
    }

    @objc func handleMWPhotoLoadingDidEndNotification(_ notification: Notification) {
        if let model = notification.object as? SSPhoto {
            if model == photo {
                if model.underlyingImage != nil {
                    // Successful load
                    displayImage()
                } else {
                    // Failed to load
                    showImageFailure()
                }
                hideLoadingIndicator()
            }
        }
    }

}
