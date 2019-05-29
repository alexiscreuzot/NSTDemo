//
//  NSTModel.swift
//  NSTDemo
//
//  Created by Alexis Creuzot on 28/05/2019.
//  Copyright © 2019 monoqle. All rights reserved.
//

import Foundation
import CoreGraphics

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
