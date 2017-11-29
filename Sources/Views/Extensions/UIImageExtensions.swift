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
}
