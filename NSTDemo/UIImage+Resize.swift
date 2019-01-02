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
    
    // Resizeing using CoreGraphics
    func resizeCG(size:CGSize) -> UIImage? {
        
        let cgImage = self.cgImage!

        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = cgImage.bitsPerPixel / bitsPerComponent
        let destBytesPerRow = destWidth * bytesPerPixel
        
        let context = CGContext(data: nil,
                                width: destWidth,
                                height: destHeight,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: destBytesPerRow,
                                space: cgImage.colorSpace!,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)!
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))
        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }
}
