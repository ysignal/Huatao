//
//  UIColor+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

//MARK: Methods
public extension UIColor {

    /// Gets the color based on the hex string.
    /// - Parameters:
    ///   - hex: The hex string.
    ///   - alpha: Alpha of color.
    /// - Returns: A new color.
    class func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let tempStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexint = intFromHexString(tempStr)
        return UIColor(red: CGFloat((hexint & 0xFF0000) >> 16)/255,
                       green: CGFloat((hexint & 0xFF00) >> 8)/255,
                       blue: CGFloat(hexint & 0xFF)/255,
                       alpha: alpha)
    }

    /// Gets the hex string from the current color. UIColor -> Hex String.
    var hex: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }

    /// Draw a gradient color from left to right in the rectangle.
    /// - Parameters:
    ///   - left: The color on the left.
    ///   - right: The color on the right.
    ///   - rect: Rectangle.
    /// - Returns: A gradient layer.
    static func gradient(left: UIColor, right: UIColor, rect: CGRect) -> CAGradientLayer {
        func gradientLayer(rect: CGRect) -> CAGradientLayer {
            let colorLayer = CAGradientLayer()
            colorLayer.frame = rect
            colorLayer.colors = [left.cgColor, right.cgColor]
            colorLayer.startPoint = CGPoint(x: 0, y: 0.5)
            colorLayer.endPoint = CGPoint(x: 1, y: 0.5)
            return colorLayer
        }
        return gradientLayer(rect: rect)
    }

    /// Get a random color.
    /// - Returns: color.
    class func random() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))/255.0
        let g = CGFloat(arc4random_uniform(256))/255.0
        let b = CGFloat(arc4random_uniform(256))/255.0
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: r, green: g, blue: b, alpha: 1)
        } else {
            // Fallback on earlier versions.
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        }
        
    }
    
    /// Convert the hex string to UInt64.
    private class func intFromHexString(_ hex: String) -> UInt64 {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var result: UInt64 = 0
        scanner.scanHexInt64(&result)
        return result
    }
}
