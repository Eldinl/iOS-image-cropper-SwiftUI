//
//  ImageCropper.swift
//  iOSImageCropperSwiftUI
//
//  Created by Леонид on 28.04.2022.
//

import Foundation
import SwiftUI
import UIKit

func ImageCropper(image: UIImage, croppedTo rect: CGRect) -> UIImage {
    
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y,
                          width: image.size.width, height: image.size.height)
    
    context?.clip(to: CGRect(x: 0, y: 0,
                             width: rect.size.width, height: rect.size.height))
    
    image.draw(in: drawRect)
    
    let subImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return subImage!
}
