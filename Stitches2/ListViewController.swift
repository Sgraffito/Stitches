//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = NSURL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

//let dataSourceURL = NSURL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UITableViewController {
  
    var dataSource2URL:NSURL!

    // Array of photo detail objects
    var photos = [PhotoRecord]()
    
    // Manage the operations
    let pendingOperations = PendingOperations()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorite Projects"
        
        let testSharedInstance = RaverlyOAuth.sharedInstance()
        let userName = testSharedInstance.userName;
        
        // TEST PRINT
        println("userName is: \(userName)")
        
        let urlString:String = String(format: "https://api.ravelry.com/people/%@/favorites/list.json", userName)
        dataSource2URL = NSURL(string: urlString)
        
        // TEST PRINT
        println("url is \(urlString)")
        
        testSharedInstance.getFavorites();
        
        // Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnSpecialNote:", name: "mySpecialNotificationKey", object: nil);
        
        //self.fetchPhotoDetails()
    }
  
    func actOnSpecialNote(note: NSNotification) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let userInfo:NSDictionary = note.userInfo!
//        println("userInfo is \(userInfo)")
       
        println("I got the notification!")
        
        var colors: AnyObject? = userInfo.valueForKey("colorURL")
        var url: AnyObject? = userInfo.valueForKey("nameURL")
        println("Colors is: \(colors?.objectAtIndex(1))")
//        println("URL is:  \(url)")
        
        if let screens: AnyObject = colors {
            for screen in screens as! [AnyObject] {
                let name = screen as? String
                let url = NSURL(string:screen as? String ?? "")
                if name != nil && url != nil {
                    let photoRecord = PhotoRecord(name:name!, url:url!)
                    self.photos.append(photoRecord)
                }
            }
        }
        
        self.tableView.reloadData()
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
    
        UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as! UITableViewCell
            
            if cell.accessoryView == nil {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                cell.accessoryView = indicator
            }
            
            // Create an indicator to provide user feedback to the user
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            
            // Fetch the right instance of the photo record based on the current row's index path
            let photoDetails = photos[indexPath.row]
            
            // Set the image and name of the cell
            cell.textLabel?.text = photoDetails.name
            cell.imageView?.image = photoDetails.image
            
            // Inspect the record. Set up the activity indicator and text as appropriate
            switch (photoDetails.state) {
            case .Filtered:
                indicator.stopAnimating()
            case .Failed:
                indicator.stopAnimating()
                cell.textLabel?.text = "Failed to load"
            case .New, .Downloaded:
                indicator.startAnimating()
                if (!tableView.dragging && !tableView.decelerating) {
                    self.startOperationsForPhotoRecord(photoDetails, indexPath: indexPath)
                }
            }
            return cell
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
//        case .Downloaded:
//            startFiltrationForRecord(photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing")
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
    func fetchPhotoDetails() {
        
        let request = NSURLRequest(URL:dataSourceURL!)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            { response, data, error in
                
                // When download in complete, the property list data is extracted into a NSDictionary
                // and then processed again into array of PhotoRecord objects
                if data != nil  {
                    let datasourceDictionay = NSPropertyListSerialization.propertyListWithData(data,
                        options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue),
                            format: nil,
                            error: nil) as! NSDictionary
                    
                    for (key: AnyObject, value : AnyObject) in datasourceDictionay {
                        let name = key as? String
                        let url = NSURL(string:value as? String ?? "")
                        if name != nil && url != nil {
                            let photoRecord = PhotoRecord(name:name!, url:url!)
                            self.photos.append(photoRecord)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
        
                if error != nil {
                    let alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
        
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
                let recordToProcess = self.photos[indexPath.row]
                startOperationsForPhotoRecord(recordToProcess, indexPath: indexPath)
            }
        }
    }
}
