//
//  ImageSourceType.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import UIKit

enum ImageSourceType {
    case camera
    case photoLibrary

    var uiKitSource: UIImagePickerController.SourceType {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        }
    }
}
