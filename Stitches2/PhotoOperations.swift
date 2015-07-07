//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Nicole Yarroch on 6/7/15.
//  Copyright (c) 2015 raywenderlich. All rights reserved.
//
//  This simple class represents each photo displayed in the app
//  together with its current state, which defaults to .New for
//  for newly created record. The image defaults to a placeholder

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}

class PhotoRecord {
    let name:String
    let url:NSURL
    let author:String
    let craft:String
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:NSURL, author:String, craft:String) {
        self.name = name
        self.url = url
        self.author = author
        self.craft = craft
    }
}

//  MARK: - Track status of each operation
//  This class contains two dictionaries to keep track of active
//  and pending download and filter operations for each row
//  in the table and two operation queues for each type of 
//  operation
//  All the values are created lazily, meaning they are not
//  initialized until they are fist accessed. This improves
//  the performance of the app
class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:NSOperation]();
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        
        // Queue's name will show up in instruments or the debugger
        queue.name = "Download queue"
        
        // This can be left out, which will allow the queue to decide
        // how many operations to perform at once (Will improve performance)
        queue.maxConcurrentOperationCount = 1;
        return queue
    }()
    
    lazy var filtrationsInProgress = [NSIndexPath:NSOperation]()
    lazy var filtrationQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        
        // Queue's name will show up in instruments or the debugger
        queue.name = "Image Filtration Queue"
        
        // This can be left out, which will allow the queue to decide
        // how many operations to perform at once (Will improve performance)
        queue.maxConcurrentOperationCount = 1;
        return queue
    }()
}

//  MARK: - Download and filtration
class ImageDownloader:NSOperation {
    
    // Create a constant reference to the PhotoRecord object related to the operation
    let photoRecord: PhotoRecord
    
    // Create a designated initializer allowing photo record to be passed in
    init(photoRecord:PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    // Override the main method in the NSOperation subclass to actually perform work
    override func main() {
        
        // Check for cancellation before starting
        if self.cancelled {
            return
        }
        
        // Download the image data
        let imageData = NSData(contentsOfURL: photoRecord.url);
        
        // Check again for cancellation
        if (self.cancelled) {
            return
        }
        
        // If there is image data create an image object and add it to the record
        // and move the state along
        if imageData?.length > 0 {
            self.photoRecord.state = .Downloaded
            self.photoRecord.image = UIImage(data: imageData!)
        }
        else {
            self.photoRecord.state = .Failed
            self.photoRecord.image = UIImage(named: "Failed");
        }
    }
}

//  MARK: - Image filtration
class ImageFiltration:NSOperation {

    // Create a constant reference to the PhotoRecord object related to the operation
    let photoRecord: PhotoRecord
    
    // Create a designated initializer allowing photo record to be passed in
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    // Override the main method in the NSOperation subclass to actually perform work
    override func main() {
        
        self.photoRecord.state = .Filtered
//
//        // Check for cancellation before starting
//        if self.cancelled {
//            return
//        }
//        
//        // If the image has not be downloaded yet, exit
//        if self.photoRecord.state != .Downloaded {
//            return
//        }
//        
//        // Create a sepia filtered image
//        if let filteredImage = self.applySepiaFilter(self.photoRecord.image!) {
//            self.photoRecord.image = filteredImage
//            self.photoRecord.state = .Filtered
//        }
    }
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
       
        // Create a constant reference to the image
        let inputImage = CIImage(data: UIImagePNGRepresentation(image))
        
        // Check for cancellation before starting
        if (self.cancelled) {
            return nil
        }
        
        // Create sepia filter
        let context = CIContext(options: nil)
        let filter  = CIFilter(name: "CISepiaTone")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter.outputImage
        
        // Check again for cancellation
        if (self.cancelled) {
            return nil
        }
        
        // Set the value of the image
        let outImage = context.createCGImage(outputImage, fromRect: outputImage.extent())
        let returnImage = UIImage(CGImage: outImage)
        return returnImage
    }
}
