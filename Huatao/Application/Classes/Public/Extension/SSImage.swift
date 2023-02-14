//
//  SSImage.swift
//  Huatao
//
//  Created on 2023/1/12.
//

import Foundation

extension UIImage {
    fileprivate var original: UIImage? {
        return withRenderingMode(.alwaysOriginal)
    }
    
    func base64String() -> String {
        let imageData = self.jpegData(compressionQuality: 1)
        let imageStr = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        return imageStr ?? ""
    }
}

struct SSImage {
    
    // 导航栏返回按钮
    static var back: UIImage? { return UIImage(named: "ic_back")?.original }
    static var backWhite: UIImage? { return UIImage(named: "ic_back_white") }
    static var userDefault: UIImage? { return UIImage(named: "ic_user_default") }
    static var photoDefault: UIImage? { return UIImage(named: "pic_default") }
    static var photoDefaultWhite: UIImage? { return UIImage(named: "pic_default_white") }

    static var radioOn: UIImage? { return UIImage(named: "ic_radio_on") }
    static var radioOff: UIImage? { return UIImage(named: "ic_radio_off") }
    
    static var taskPromote: UIImage? { return UIImage(named: "ic_task_share") }
    static var taskAuth: UIImage? { return UIImage(named: "ic_task_cert") }
    static var taskTrade: UIImage? { return UIImage(named: "ic_task_password") }
    static var taskPlace: UIImage? { return UIImage(named: "ic_task_location") }
    static var taskInvite: UIImage? { return UIImage(named: "ic_task_invite") }
    static var taskFriend: UIImage? { return UIImage(named: "ic_task_circle") }
    static var taskLike: UIImage? { return UIImage(named: "ic_task_like") }
    static var taskComplete: UIImage? { return UIImage(named: "ic_task_complete") }
    static var taskTotal: UIImage? { return UIImage(named: "ic_task_invite") }
    static var taskLook: UIImage? { return UIImage(named: "ic_task_look") }
    static var taskPay: UIImage? { return UIImage(named: "ic_task_pay") }
    static var taskMoney: UIImage? { return UIImage(named: "ic_task_money") }

}
