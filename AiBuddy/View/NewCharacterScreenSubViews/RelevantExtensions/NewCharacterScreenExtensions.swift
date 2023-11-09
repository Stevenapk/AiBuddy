//
//  RelevantExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import UIKit

extension UIImage {
    
    var resizeToContactIconSize: UIImage? {
        let targetSize = CGSize(width: 240, height: 240) // Set target size

        // Begin a graphics context of the specified size
        UIGraphicsBeginImageContext(targetSize)
        
        // Ensure the context is properly cleaned up when exiting the block
        defer { UIGraphicsEndImageContext() }
        
        // Draw the current image into the specified rectangle
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        
        // Get the image from the current graphics context
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return resizedImage
    }
    
    var toCompressedData: Data? {
        // Attempt to create JPEG data with a compression quality of 50%
        guard let imageData = self.jpegData(compressionQuality: 0.5) else {
            return nil
        }
        
        // Calculate the size of the image data in kilobytes
        let sizeInKB = Double(imageData.count) / 1024.0
        
        // Check if the image is already below 100KB
        if sizeInKB < 100 {
            // If so, return the image data
            return imageData
        } else {
            // If the image is larger than 100KB, attempt further compression
            // Guard against infinite recursion by checking if size is very small
            guard sizeInKB > 1 else {
                return nil
            }
            
            // Resize the image by half (scale of 0.5)
            let resizedImage = UIImage(data: imageData, scale: 0.5)
            // Attempt compression by recalling this same computed property (recursion)
            return resizedImage?.toCompressedData
        }
    }
}
