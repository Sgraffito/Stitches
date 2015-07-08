//
//  SearchFavorites.swift
//  Stitches2
//
//  Created by Nicole Yarroch on 6/17/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class SearchFavoritesViewController: ListVC, UISearchBarDelegate {
    
    @IBOutlet weak var searchToolbar: UISearchBar!
    var searchActive:ObjCBool = false
    var filtered:[String] = []
    
    // Array of photo detail objects
    var searchedPhotos = [PhotoRecord]()
    var pageCount:NSNumber = 1
    
    override func finishInit() {
        // Abstract
        
        // Setup delegates
        searchToolbar.delegate = self
        
        // Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnSpecialNote:", name: "searchFavoriteResults", object: nil);
    }
    
    override func appendPhoto(photoRecord:PhotoRecord) {
        // Abstract
        searchedPhotos.append(photoRecord)
    }
    
    override func getArrayCount() -> Int {
        // Abstract
        return searchedPhotos.count
    }
    
    override func getPhotoForRow(row:Int) -> PhotoRecord {
        // Abstract
        return searchedPhotos[row]
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
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if(filtered.count == 0){
            searchActive = false
        } else {
            searchActive = true
        }
        
        apiCall(searchBar.text)
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = false
        
    }
    
    // MARK: - API Call
    func apiCall(searchText:String) {
        testSharedInstance.searchFavorites(searchText)
    }
    
    // MARK: - Keyboard
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchToolbar.resignFirstResponder()
    }
}
