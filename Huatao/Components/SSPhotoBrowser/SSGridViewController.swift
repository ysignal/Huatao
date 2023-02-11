//
//  SSGridViewController.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class SSGridViewController: UICollectionViewController {

    var browser: SSPhotoBrowser!
    
    var selectionMode: Bool = false
    
    var initialContentOffset: CGPoint = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
    
    var columns: CGFloat = 3
    var columnsL: CGFloat = 4
    var margin: CGFloat = 0
    var marginL: CGFloat = 0
    var gutter: CGFloat = 1
    var gutterL: CGFloat = 1
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        if UI_USER_INTERFACE_IDIOM() == .pad {
            // iPad
            columns = 6
            columnsL = 8
            margin = 1
            marginL = 1
            gutter = 2
            gutterL = 2
        } else if SS.h == 480 {
            // iPhone 3.5 inch
            columns = 3
            columnsL = 4
            margin = 0
            marginL = 1
            gutter = 1
            gutterL = 2
        } else {
            // iPhone 4 inch
            columns = 3
            columnsL = 5
            margin = 0
            marginL = 0
            gutter = 1
            gutterL = 2
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SSGridCell.self, forCellWithReuseIdentifier: "GridCell")
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Cancel outstanding loading
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            if let girdCell = cell as? SSGridCell {
                girdCell.photo?.cancelAnyLoading()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        performLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func adjustOffsetsAsRequired() {
        // Move to previous content offset
        if (initialContentOffset.y != .greatestFiniteMagnitude) {
            collectionView.contentOffset = initialContentOffset
            // Layout after content offset change
            collectionView.layoutIfNeeded()
        }
        // Check if current item is visible and if not, make it so!
        if (browser.numberOfPhotos() > 0) {
            let currentPhotoIndexPath = IndexPath(row: browser.currentIndex, section: 0)
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            var currentVisible = false
            
            for indexPath in visibleIndexPaths {
                if indexPath == currentPhotoIndexPath {
                    currentVisible = true
                    break
                }
            }
            
            if !currentVisible {
                collectionView.scrollToItem(at: currentPhotoIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func performLayout() {
        if let navBar = navigationController?.navigationBar {
            collectionView.contentInset = UIEdgeInsets(top: navBar.frame.origin.y + navBar.frame.size.height + getGutter(), left: 0, bottom: 0, right: 0)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
        performLayout()
    }
    
    //MARK: - Layout
    
    func getColumns() -> CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return columns
        }
        return columnsL
    }
    
    func getMargin() -> CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return margin
        }
        return marginL
    }
    
    func getGutter() -> CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return gutter
        }
        return gutterL
    }
    
    //MARK: - Collection View
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browser.numberOfPhotos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SSGridCell = {
            if let c = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? SSGridCell {
                return c
            }
            return SSGridCell()
        }()
        if let photo = browser.thumbPhoto(at: indexPath.row) {
            cell.photo = photo
            cell.gridController = self
            cell.selectionMode = selectionMode
            cell.isSelected = browser.photoIsSelected(at: indexPath.row)
            cell.index = indexPath.row
            if let _ = browser.image(for: photo) {
                cell.displayImage()
            } else {
                photo.loadUnderlyingImageAndNotify()
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        browser.setCurrentPhotoIndex(indexPath.row)
        browser.hideGrid()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let girlCell = cell as? SSGridCell {
            girlCell.photo?.cancelAnyLoading()
        }
    }
}

extension SSGridViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = getMargin()
        let gutter = getGutter()
        let columns = getColumns()
        let value = floor(((self.view.bounds.size.width - (columns - 1) * gutter - 2 * margin) / columns))
        return CGSizeMake(value, value)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return getGutter()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return getGutter()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = getMargin()
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
}
