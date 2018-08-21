//
//  UIImage+Resize.swift
//

import UIKit

extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage {
        let scaleX = newSize.width / self.size.width
        let scaleY = newSize.height / self.size.height
        let newWidth = self.size.width * scaleX
        let newHeight = self.size.height * scaleY
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { (context) in
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        }
        return image
    }
}
