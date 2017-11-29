//
// UIImage+Extras.swift
// Clay Ellis
// https://gist.github.com/clayellis/3c3bfdee9cac8e9b12ecaefb103d916b
//

import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }

    func with(alpha value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    /// Initialize a `UIImage` with a `UILabel` rendered inside.
    /// - parameter label: The label to render.
    /// - parameter sizeByContent: If `true`, the size of the resulting image will be
    ///     the `instrinsicContentSize` of the `label`. Otherwise, the `label`'s `bounds`
    ///     are used to determine the size. Defaults to `true`.
    convenience init?(label: UILabel, sizeByContent: Bool = true) {
        if sizeByContent {
            label.frame.size = label.intrinsicContentSize
            UIGraphicsBeginImageContextWithOptions(label.intrinsicContentSize, false, 0.0)
        } else {
            UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }

    func color(at point: CGPoint) -> UIColor? {
        guard let cgImage = cgImage,
            let cgImageData = cgImage.dataProvider?.data,
            let pixelData = CGDataProvider(data: cgImageData)?.data,
            let data = CFDataGetBytePtr(pixelData)
            else { return nil }

        let x = Int(point.x)
        let y = Int(point.y)
        let index = Int(size.width) * y + x
        let expectedLengthA = Int(size.width * size.height)
        let expectedLengthRGB = 3 * expectedLengthA
        let expectedLengthRGBA = 4 * expectedLengthA
        let byteLength = CFDataGetLength(pixelData)
        switch byteLength {
        case expectedLengthA:
            return UIColor(red: 0,
                           green: 0,
                           blue: 0,
                           alpha: CGFloat(data[index]) / 255.0)
        case expectedLengthRGB:
            return UIColor(red: CGFloat(data[3 * index]) / 255.0,
                           green: CGFloat(data[3 * index + 1]) / 255.0,
                           blue: CGFloat(data[3 * index + 2]) / 255.0,
                           alpha: 1.0)
        case expectedLengthRGBA:
            return UIColor(red: CGFloat(data[4 * index]) / 255.0,
                           green: CGFloat(data[4 * index + 1]) / 255.0,
                           blue: CGFloat(data[4 * index + 2]) / 255.0,
                           alpha: CGFloat(data[4 * index + 3]) / 255.0)
        default:
            return nil
        }
    }
}
