//
//  UIView+Gesture.swift
//  Charming
//
//  Created by minse on 2022/10/14.
//

import UIKit

typealias SSHandler = (UIGestureRecognizer) -> ()
    
extension UIView {
    enum GestureEnum {
        case tap
        case long
        case pan
        case roation
        case swipe
        case pinch
    }
    
    private struct AssociatedKeys {
        static var actionKey = "gestureKey"
    }
    
    @objc dynamic var handler: SSHandler? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
            get {
              if let handler = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? SSHandler {
                  return handler
              }
              return nil
          }
    }
    
    @objc func viewTapAction(gesture: UIGestureRecognizer) {
        handler?(gesture)
    }
    
    /// 添加手势
    func addGesture( _ gesture: GestureEnum , response: @escaping SSHandler) {
        self.isUserInteractionEnabled = true
        switch gesture {
        case .tap: //点击
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.numberOfTapsRequired = 1
            self.addGestureRecognizer(tapGesture)
            self.handler = response
        case .long: //长按
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            self.addGestureRecognizer(longPress)
            self.handler = response
        case .pan: //拖拽
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            self.addGestureRecognizer(panGesture)
            self.handler = response
        case .roation: // 旋转
            let roation = UIRotationGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            self.addGestureRecognizer(roation)
            self.handler = response
        case .swipe: //轻扫
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            self.addGestureRecognizer(swipe)
            self.handler = response
        case .pinch: //捏合
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(viewTapAction(gesture:)))
            self.addGestureRecognizer(pinch)
            self.handler = response
        }
    }
}
