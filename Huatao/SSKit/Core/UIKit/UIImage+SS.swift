//
//  UIImage+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

public extension UIImage {
    
    /// 根据颜色生成图片
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else {
            self.init()
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    /// 质量压缩
    func compress(maxSize: Int) -> Data? {
        var compression: CGFloat = 1
        guard var data = jpegData(compressionQuality: 1) else { return nil }
        if data.count < maxSize {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = jpegData(compressionQuality: compression) ?? data
            if CGFloat(data.count) < CGFloat(maxSize){
                min = compression
            } else if data.count > maxSize {
                max = compression
            } else {
                break
            }
        }
        return data
    }
    
    /// 尺寸压缩
    func compress(maxLength: CGFloat) -> UIImage? {
        if maxLength <= 0 {
            return self
        }
        
        let imgMax: CGFloat = max(size.width, size.height)
        
        if imgMax > maxLength {
            let ratio = maxLength/imgMax
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContext(newSize)
            draw(in: CGRect(origin: .zero, size: newSize))
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img
        } else {
            return self
        }
    }

    /// 生成一个渐变色图片
    /// - Parameter colors: 颜色
    /// - Parameter locations: 渐变节点
    /// - Parameter startPoint: 起始点，x = 0 - 1，y = 0 - 1
    /// - Parameter endPoint: 结束点，x = 0 - 1，y = 0 - 1
    static func getImage(colors: Array<UIColor>, locations: Array<CGFloat>, startPoint: CGPoint, endPoint: CGPoint) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 5, height: 5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var colorComponents: Array<CGFloat> = []
        for color in colors {
            colorComponents += color.cgColor.components!
        }
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: locations, count: colors.count)!
        let startP = CGPoint(x: startPoint.x * rect.size.width, y: startPoint.y * rect.size.height)
        let endP = CGPoint(x: endPoint.x * rect.size.width, y: endPoint.y * rect.size.height)
        context.drawLinearGradient(gradient, start: startP, end: endP, options: .drawsBeforeStartLocation)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func reset(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return reSizeImage
    }

    func reset(scale: CGFloat) -> UIImage {
        let size = CGSize(width: size.width / scale, height: size.height / scale)
        return reset(size: size)
    }
    
    func color(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return image
    }
}
