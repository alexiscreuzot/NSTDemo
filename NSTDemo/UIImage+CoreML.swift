//
//  UIImage+CoreML.swift
//

import UIKit
import VideoToolbox

extension UIImage {
    
    /**
     Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
     */
    public func pixelBuffer() -> CVPixelBuffer? {
        return pixelBuffer(width: Int(self.size.width), height: Int(self.size.height))
    }
    
    /**
     Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
     */
    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst)
    }
    
    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
            else {
                return nil
        }
        
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    /**
     Creates a new UIImage from a CVPixelBuffer.
     NOTE: This only works for RGB pixel buffers, not for grayscale.
     */
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    /**
     Creates a new UIImage from a CVPixelBuffer, using Core Image.
     */
    public convenience init?(pixelBuffer: CVPixelBuffer, context: CIContext) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer),
                          height: CVPixelBufferGetHeight(pixelBuffer))
        if let cgImage = context.createCGImage(ciImage, from: rect) {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArrayRGBA(_ bytes: [UInt8],
                                                 width: Int,
                                                 height: Int,
                                                 scale: CGFloat = 0,
                                                 orientation: UIImage.Orientation = .up) -> UIImage? {
        return fromByteArray(bytes, width: width, height: height,
                             scale: scale, orientation: orientation,
                             bytesPerRow: width * 4,
                             colorSpace: CGColorSpaceCreateDeviceRGB(),
                             alphaInfo: .premultipliedLast)
    }
    
    @nonobjc class func fromByteArray(_ bytes: [UInt8],
                                      width: Int,
                                      height: Int,
                                      scale: CGFloat,
                                      orientation: UIImage.Orientation,
                                      bytesPerRow: Int,
                                      colorSpace: CGColorSpace,
                                      alphaInfo: CGImageAlphaInfo) -> UIImage? {
        var image: UIImage?
        bytes.withUnsafeBytes { ptr in
            if let context = CGContext(data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                                       width: width,
                                       height: height,
                                       bitsPerComponent: 8,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpace,
                                       bitmapInfo: alphaInfo.rawValue),
                let cgImage = context.makeImage() {
                image = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
            }
        }
        return image
    }
}
