//
//  UIImage+Resize.swift
//

import UIKit

extension UIImage {
    
    // Resizeing using CoreGraphics
    func resize(to size:CGSize) -> UIImage? {
        
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
