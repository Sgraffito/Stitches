//
//  ListVC.swift
//  Stitches2
//
//  Created by Nicole Yarroch on 7/7/15.
//  Copyright (c) 2015 Nicole Yarroch. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class ListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let testSharedInstance = RaverlyOAuth.sharedInstance()
    let spinner : UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingNotification : MBProgressHUD?
    
    // Manage the operations
    let pendingOperations = PendingOperations()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        finishInit()
        
        // Loading spinner
        self.loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        self.loadingNotification?.mode = MBProgressHUDMode.Indeterminate
        self.loadingNotification?.labelText = "Loading"
    }
    
    func finishInit() {
        // Abstract
    }
    
    func actOnSpecialNote(note: NSNotification) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let userInfo:NSDictionary = note.userInfo!
        
        var patternName: AnyObject? = userInfo.valueForKey("patternNameURL")
        var patternURL: AnyObject? = userInfo.valueForKey("patternPhotoURL")
        var patternAuthor: AnyObject? = userInfo.valueForKey("patternAuthor")
        var patternCraft: AnyObject? = userInfo.valueForKey("patternCraft")
        
        var name:String = "No pattern name"
        var url:NSURL = NSURL(string: "http://www.google.com")!
        var author:String = "Author unknown"
        var craft:String = "Craft unknown"
        
        for var i = 0; i < patternURL!.count; i += 1 {
            if let nameObject: AnyObject = patternName?[i] {
                if let nameObject2 = nameObject as? String {
                    name = nameObject as! String
                }
                else {
                    name = "No pattern name"
                }
            }
            
            if let urlObject: AnyObject = patternURL?[i] {
                url = NSURL(string: urlObject as? String ?? "")!
            }
            
            if let authorObject: AnyObject = patternAuthor?[i] {
                if let authorObject2 = authorObject as? String {
                    author = authorObject2 as String
                }
                else {
                    author = "Unknown"
                }
            }
            
            if let craftObject: AnyObject = patternCraft?[i] {
                if let craftObject2 = craftObject as? String {
                    craft = craftObject2 as String
                }
                else {
                    craft = "Unknown"
                }
            }
            let photoRecord = PhotoRecord(name: name, url: url, author: author, craft: craft)
            appendPhoto(photoRecord)
        }
        
        // Increase the page count
        increasePageCount()
        
        // Dismiss the spinner
        self.loadingNotification?.hide(true)
        
        self.tableView.reloadData()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func increasePageCount() {
        // Abstract
    }
    
    func appendPhoto(photoRecord:PhotoRecord) {
        println("Calling main function")
        // Abstract
        // self.photos.append(photoRecord)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (getArrayCount()! + 1)
    }

    func getArrayCount() -> Int? {
        // Abstract
        // return (photos.count + 1)
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var numberOfRows = getArrayCount()
        let rowNumber = indexPath.row;
        
        // Last row is smaller than rest (load next images)
        if (numberOfRows == rowNumber) {
            return 60
        }
        
        return 150
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var defaultCell:UITableViewCell!
        let row = indexPath.row
        let rowCount = getArrayCount()
        
        println("row is: \(row)")
        if row == rowCount {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath:indexPath) as! UITableViewCell
            if row == 0 {
                cell.textLabel?.text = ""
                cell.backgroundColor = UIColor.clearColor()
            }
            else {
                cell.textLabel?.text = "Load next 25"
                cell.backgroundColor = UIColor.blueColor()
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SimpleTableRow", forIndexPath:indexPath) as! SimpleCellTVC
            
            if cell.accessoryView == nil {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                cell.accessoryView = indicator
            }
            
            // Create an indicator to provide user feedback to the user
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            
            // Fetch the right instance of the photo record based on the current row's index path
            let photoDetails = getPhotoForRow(indexPath.row)
            
            // Set the image and name of the cell
            cell.thumbNailView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.thumbNailView.clipsToBounds = true
            cell.thumbNailView.image = photoDetails!.image
            cell.projectName.text = photoDetails!.name
            let projectAuthor:String = "Designer: \(photoDetails!.author)"
            cell.projectAuthor.text = projectAuthor
            
            // Inspect the record. Set up the activity indicator and text as appropriate
            switch (photoDetails!.state) {
            case .Filtered:
                indicator.stopAnimating()
            case .Failed:
                indicator.stopAnimating()
                cell.textLabel?.text = "Failed to load"
            case .New, .Downloaded:
                indicator.startAnimating()
                if (!tableView.dragging && !tableView.decelerating) {
                    self.startOperationsForPhotoRecord(photoDetails!, indexPath: indexPath)
                }
            }
            return cell
        }
    }
    
    func getPhotoForRow(row:Int) -> PhotoRecord? {
        // Abstract
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("Selecting row")
        
        if (indexPath.row == getArrayCount()) {
            testSharedInstance.getFavorites(getPageCount())
        }
        
    }
    
    func getPageCount() -> Int? {
        return nil
    }
    
    //  MARK: - Set operations for the photos
    //  The methods for downloading and filtering the images are implemented separately
    //  so if while an image is being downloaded and the user scrolls away, the next time
    //  the user comes back, you will not have to redownload the image. You will only
    //  have to apply the filter
    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath:NSIndexPath) {
        switch (photoDetails.state) {
        case .New:
            startDownloadForRecord(photoDetails, indexPath: indexPath)
        case .Downloaded:
            startFiltrationForRecord(photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing to photo")
        }
    }
    
    
    func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: NSIndexPath){
        
        if let downloadOperation = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImageDownloader(photoRecord: photoDetails)
        
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltrationForRecord(photoDetails: PhotoRecord, indexPath: NSIndexPath){
        if let filterOperation = pendingOperations.filtrationsInProgress[indexPath]{
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.filtrationsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
    //  MARK: - Download the photos
    //  Creates an asychronous web request which, when finished, will run the completion block
    //  on the main queue
    //    func fetchPhotoDetails() {
    //
    //        let request = NSURLRequest(URL:dataSourceURL!)
    //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    //
    //        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
    //            { response, data, error in
    //
    //                // When download in complete, the property list data is extracted into a NSDictionary
    //                // and then processed again into array of PhotoRecord objects
    //                if data != nil  {
    //                    let datasourceDictionay = NSPropertyListSerialization.propertyListWithData(data,
    //                        options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue),
    //                            format: nil,
    //                            error: nil) as! NSDictionary
    //
    //                    for (key: AnyObject, value : AnyObject) in datasourceDictionay {
    //                        let name = key as? String
    //                        let url = NSURL(string:value as? String ?? "")
    //                        if name != nil && url != nil {
    ////                            let photoRecord = PhotoRecord(name:name!, url:url!)
    ////                            self.photos.append(photoRecord)
    //                        }
    //                    }
    //
    //                    self.tableView.reloadData()
    //                }
    //
    //                if error != nil {
    //                    let alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
    //                    alert.show()
    //                }
    //
    //                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    //        }
    //    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.suspended = true
        pendingOperations.filtrationQueue.suspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.suspended = false
        pendingOperations.filtrationQueue.suspended = false
    }
    
    func loadImagesForOnscreenCells () {
        //1
        if let pathsArray = tableView.indexPathsForVisibleRows() {
            //2
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys.array)
            allPendingOperations.unionInPlace(pendingOperations.filtrationsInProgress.keys.array)
            
            //3
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray as! [NSIndexPath])
            toBeCancelled.subtractInPlace(visiblePaths)
            
            //4
            var toBeStarted = visiblePaths
            toBeStarted.subtractInPlace(allPendingOperations)
            
            // 5
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValueForKey(indexPath)
            }
            
            // 6
            for indexPath in toBeStarted {
                let indexPath = indexPath as NSIndexPath
                
                // Do not render last row, which does not contain a photo (load next)
                if (indexPath.row < getArrayCount()) {
                    let recordToProcess = getPhotoForRow(indexPath.row)
                    startOperationsForPhotoRecord(recordToProcess!, indexPath: indexPath)
                }
            }
        }
    }
}
