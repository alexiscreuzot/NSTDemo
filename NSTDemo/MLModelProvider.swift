//
//  MLModelProvider.swift
//  NSTDemo
//
//  Created by Alexis Creuzot on 21/05/2019.
//  Copyright © 2019 monoqle. All rights reserved.
//

import UIKit
import CoreML

enum NSTDemoModel : String, CaseIterable {
    
    case starryNight = "StarryNight"
    case pointillism = "Pointillism"
    
    func modelProvider() throws -> MLModelProvider {
        guard let url = Bundle.main.url(forResource: self.rawValue, withExtension:"mlmodelc") else {
            throw NSTError.assetPathError
        }
        
        switch self {
        case .starryNight:
            return try MLModelProvider(contentsOf: url,
                                       pixelBufferSize: CGSize(width:720, height:720),
                                       inputName: "inputImage",
                                       outputName: "outputImage")
        case .pointillism:
            return try MLModelProvider(contentsOf: url,
                                       pixelBufferSize: CGSize(width:720, height:720),
                                       inputName: "myInput",
                                       outputName: "myOutput")
        }
    }
}

/// Encapsulation class for our NST models
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MLModelProvider {
    var model: MLModel
    
    // The variable parameters for our NST models
    var inputName: String
    var outputName: String
    var pixelBufferSize: CGSize
   
    init(contentsOf url: URL,
         pixelBufferSize: CGSize,
         inputName: String,
         outputName: String) throws {
        self.model = try MLModel(contentsOf: url)
        self.pixelBufferSize = pixelBufferSize
        self.inputName = inputName
        self.outputName = outputName
    }
    
    // Provide a more abstracted prediction method
    // Allowing for an UIImage input of any size
    // and returning the result as an UIImage of same size
    func prediction(inputImage: UIImage) throws -> UIImage {

        // 1 - Resize image to our model expected size
        guard let resizedImage = inputImage.resize(to: self.pixelBufferSize) else {
            throw NSTError.resizeError
        }
        
        // 2 - Transform our UIImage to a PixelBuffer
        guard let cvBufferInput = resizedImage.pixelBuffer() else {
            throw NSTError.pixelBufferError
        }
        
        // 3 -  Feed that PixelBuffer to the model (this is where the actual magic happens)
        let MLInput = MLModelProviderInput(inputImage: cvBufferInput,
                                           inputName: inputName)
        let output = try self.prediction(input: MLInput)
        
        // 4 - Transform PixelBuffer output to UIImage
        guard let outputImage = UIImage(pixelBuffer: output.outputImage) else {
            throw NSTError.pixelBufferError
        }
        
        // 5 - Resize result back to the original input size
        guard let finalImage = outputImage.resize(to: inputImage.size) else {
            throw NSTError.resizeError
        }

        return finalImage
    }
    
    // Prediction using our custom MLModelProviderInput and MLModelProviderOutput
    func prediction(input: MLModelProviderInput) throws -> MLModelProviderOutput {
        let outFeatures = try model.prediction(from: input)
        let result = MLModelProviderOutput(outputImage: outFeatures.featureValue(for: outputName)!.imageBufferValue!, outputName: outputName)
        return result
    }
}

/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MLModelProviderInput : MLFeatureProvider {
    
    var inputImage: CVPixelBuffer
    var inputName: String
    var featureNames: Set<String> {
        get { return [inputName] }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == inputName) {
            return MLFeatureValue(pixelBuffer: inputImage)
        }
        return nil
    }
    
    init(inputImage: CVPixelBuffer, inputName: String) {
        self.inputName = inputName
        self.inputImage = inputImage
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MLModelProviderOutput : MLFeatureProvider {
    
    let outputImage: CVPixelBuffer
    var outputName: String
    var featureNames: Set<String> {
        get { return [outputName] }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == outputName) {
            return MLFeatureValue(pixelBuffer: outputImage)
        }
        return nil
    }
    
    init(outputImage: CVPixelBuffer, outputName: String) {
        self.outputName = outputName
        self.outputImage = outputImage
    }
}
