//
//  SSPhotoOptions.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit
import Photos

struct SSPhotoOptions {
    
    private struct KeepValue {
        var maxSelectCount = 9
        var allowTakePhotoInLibrary = true
        var allowTakePhoto = true
        var allowRecordVideo = true
        var minRecordDuration: Int = 0
        var maxRecordDuration: Int = 20
    }
    
    private var keepValue = KeepValue()

    static let `default` = SSPhotoOptions()
    
    var sortAscending: Bool = true
    
    /// 最大可选数量，设置数量大于1会自动开启多选模式。默认为9
    var maxSelectCount: Int {
        get {
            return keepValue.maxSelectCount
        }
        set {
            keepValue.maxSelectCount = max(newValue, 1)
        }
    }
    
    /// 是否可以同时选择照片和视频。默认值为true
    /// 如果值为false，则只能选择一个视频。默认值为true
    var allowMixSelect = true
    
    /// 预览选择最大预览次数，如果值为零，只显示 `Camera`，`Album`，`Cancel` 按钮。默认为20
    var maxPreviewCount = 20
    
    /// 弹窗cell的圆角大小
    var cellCornerRadio: CGFloat = 0
    
    /// 允许选择图片，默认为true
    /// 如果值为false, `gif`和`livephoto`也不能选择。默认值为true
    var allowSelectImage = true
    
    /// 允许选择视频，默认为true
    var allowSelectVideo = true
    
    /// 允许选择Gif，它只控制是否以Gif形式显示
    /// 如果值为false，则不显示Gif logo。默认值为true
    var allowSelectGif = true
    
    /// 允许选择LivePhoto，它只控制是否以LivePhoto形式显示
    /// 如果值为false，则不显示LivePhoto logo。默认值为false
    var allowSelectLivePhoto = false
    
    /// 允许在相册中拍照，默认值为true
    /// - warning: 如果`allowtakphoto`和`allowRecordVideo`都为false，则不显示
    var allowTakePhotoInLibrary: Bool {
        get {
            return keepValue.allowTakePhotoInLibrary && (allowTakePhoto || allowRecordVideo)
        }
        set {
            keepValue.allowTakePhotoInLibrary = newValue
        }
    }
    
    /// 允许编辑图片，默认为true
    var allowEditImage: Bool = true
    
    /// - warning: 只有在没有选择照片或只选择一个视频的情况下，视频才能被编辑，编辑完成后立即执行选择回调
    var allowEditVideo: Bool = false
    
    /// 控制在选择时是否显示选择按钮动画，默认值为true
    var animateSelectBtnWhenSelect = true
    
    /// 选择按钮的动画持续时间
    var selectBtnAnimationDuration: CFTimeInterval = 0.4
    
    /// 在缩略图界面中选择图像/视频后，直接进入编辑界面，默认值为false
    /// - discussion: 只有当allowEditImage为true且maxSelectCount为1时，编辑图像才有效
    /// 编辑视频只在allowEditVideo为true且maxSelectCount为1时有效
    var editAfterSelectThumbnailImage = false
    
    /// Only valid when allowMixSelect is false and allowEditVideo is true. Defaults to true.
    /// Just like the Wechat-Timeline selection style. If you want to crop the video after select thumbnail under allowMixSelect = true, please use **editAfterSelectThumbnailImage**.
    var cropVideoAfterSelectThumbnail = true
    
    /// If image edit tools only has clip and this property is true. When you click edit, the cropping interface (i.e. ZLClipImageViewController) will be displayed. Defaults to false.
    var showClipDirectlyIfOnlyHasClipTool = false
    
    /// Save the edited image to the album after editing. Defaults to true.
    var saveNewImageAfterEdit = true
    
    /// If true, you can slide select photos in album. Defaults to true.
    var allowSlideSelect = true
    
    /// When slide select is active, will auto scroll to top or bottom when your finger at the top or bottom. Defaults to true.
    var autoScrollWhenSlideSelectIsActive = true
    
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    var autoScrollMaxSpeed: CGFloat = 600
    
    /// If true, you can drag select photo when preview selection style. Defaults to false.
    var allowDragSelect = false
    
    /// Allow select full image. Defaults to true.
    var allowSelectOriginal = true
    
    /// Always return the original photo.
    /// - warning: Only valid when `allowSelectOriginal = false`, Defaults to false.
    var alwaysRequestOriginal = false
    
    /// Allow access to the preview large image interface (That is, whether to allow access to the large image interface after clicking the thumbnail image). Defaults to true.
    var allowPreviewPhotos = true
    
    /// Whether to show the preview button (i.e. the preview button in the lower left corner of the thumbnail interface). Defaults to true.
    var showPreviewButtonInAlbum = true
    
    /// Whether to display the selected count on the button. Defaults to true.
    var showSelectCountOnDoneBtn = true
    
    private var pri_columnCount: Int = 4
    /// The column count when iPhone is in portait mode. Minimum is 2, maximum is 6. Defaults to 4.
    /// ```
    /// iPhone landscape mode: columnCount += 2.
    /// iPad portait mode: columnCount += 2.
    /// iPad landscape mode: columnCount += 4.
    /// ```
    var columnCount: Int {
        get {
            return pri_columnCount
        }
        set {
            pri_columnCount = min(6, max(newValue, 2))
        }
    }
    
    /// Maximum cropping time when editing video, unit: second. Defaults to 10.
    var maxEditVideoTime: Int = 10
    
    /// Allow to choose the maximum duration of the video. Defaults to 120.
    var maxSelectVideoDuration: Int = 120
    
    /// Allow to choose the minimum duration of the video. Defaults to 0.
    var minSelectVideoDuration: Int = 0
    
    /// Image editor configuration.
    var editImageConfiguration = SSEditImageOptions()
    
    /// Show the image captured by the camera is displayed on the camera button inside the album. Defaults to false.
    var showCaptureImageOnTakePhotoBtn = false
    
    /// In single selection mode, whether to display the selection button. Defaults to false.
    var showSelectBtnWhenSingleSelect = false
    
    /// Overlay a mask layer on top of the selected photos. Defaults to true.
    var showSelectedMask = true
    
    /// Display a border on the selected photos cell. Defaults to false.
    var showSelectedBorder = false
    
    /// Overlay a mask layer above the cells that cannot be selected. Defaults to true.
    var showInvalidMask = true
    
    /// Display the index of the selected photos. Defaults to true.
    var showSelectedIndex = true
    
    /// Display the selected photos at the bottom of the preview large photos interface. Defaults to true.
    var showSelectedPhotoPreview = true
    
    /// Timeout for image parsing. Defaults to 20.
    var timeout: TimeInterval = 20
    
    /// Whether to use custom camera. Defaults to true.
    var useCustomCamera = true
    
    /// Allow taking photos in the camera (Need allowSelectImage to be true). Defaults to true.
    var allowTakePhoto: Bool {
        get {
            return keepValue.allowTakePhoto && allowSelectImage
        }
        set {
            keepValue.allowTakePhoto = newValue
        }
    }
    
    /// Allow recording in the camera (Need allowSelectVideo to be true). Defaults to true.
    var allowRecordVideo: Bool {
        get {
            return keepValue.allowRecordVideo && allowSelectVideo
        }
        set {
            keepValue.allowRecordVideo = newValue
        }
    }
    
    /// Minimum recording duration. Defaults to 0.
    var minRecordDuration: Int {
        get {
            return keepValue.minRecordDuration
        }
        set {
            keepValue.minRecordDuration = max(0, newValue)
        }
    }
    
    /// Maximum recording duration. Defaults to 10, minimum is 1.
    var maxRecordDuration: Int {
        get {
            return keepValue.maxRecordDuration
        }
        set {
            keepValue.maxRecordDuration = max(1, newValue)
        }
    }
    
    /// The configuration for camera.
    var cameraConfiguration = SSCameraOptions()
    
    /// This block will be called before selecting an image, the developer can first determine whether the asset is allowed to be selected.
    /// Only control whether it is allowed to be selected, and will not affect the selection logic in the framework.
    /// - Tips: If the choice is not allowed, the developer can toast prompt the user for relevant information.
    var canSelectAsset: ((PHAsset) -> Bool)?
    
    /// If user choose limited Photo mode, a button with '+' will be added to the ZLThumbnailViewController. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo. Defaults to true.
    /// E.g., Sina Weibo's ImagePicker
    var showAddPhotoButton: Bool = true
    
    /// iOS14 limited Photo mode, will show collection footer view in ZLThumbnailViewController.
    /// Will go to system setting if clicked. Defaults to true.
    var showEnterSettingTips = true
    
    /// Callback after the no authority alert dismiss.
    var noAuthorityCallback: ((SSNoAuthorityType) -> Void)?
    
    /// Allow user to do something before select photo result callback.
    /// And you must call the second parameter of this block to continue the photos selection.
    /// The first parameter is the current controller.
    /// The second parameter is the block that needs to be called after the user completes the operation.
    var operateBeforeDoneAction: ((UIViewController, @escaping () -> Void) -> Void)?
}
