//
//  GetFavorites.swift
//  Stitches2
//
//  Created by Nicole Yarroch on 6/17/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class GetFavoritesViewController: ListVC {
    
    // Array of photo detail objects
    var getFavoritePhotos = [PhotoRecord]()
    var pageCount:NSNumber = 1
    
    override func finishInit() {
        // Abstract
        
        // Call get favorites
        apiCall()
        
        // Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnSpecialNote:", name: "mySpecialNotificationKey", object: nil);
    }
    
    func apiCall() {
        testSharedInstance.getFavorites(pageCount)
    }
    
    override func appendPhoto(photoRecord:PhotoRecord) {
        // Abstract
        getFavoritePhotos.append(photoRecord)
    }
    
    override func getArrayCount() -> Int {
        // Abstract
        return getFavoritePhotos.count
    }
    
    override func getPhotoForRow(row:Int) -> PhotoRecord {
        // Abstract
        return getFavoritePhotos[row]
    }
    
    override func increasePageCount() {
        // Abstract
        var value = pageCount.integerValue
        value = value + 1
        pageCount = value
    }
    
    override func getPageCount() -> Int? {
        return pageCount.integerValue
    }
}
