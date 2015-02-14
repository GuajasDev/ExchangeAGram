//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Diego Guajardo on 13/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    
    // Arrays
    // We use 'AnyObject' because when we 'xecuteFetchRequest' in viewDidLoad, we get an array with AnyObject instances. We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
    var feedArray:[AnyObject] = []
    
    // MARK: - BODY
    
    //MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
        // Request all the FeedItems we have saved
        let request = NSFetchRequest(entityName: "FeedItem")
        
        // Get the instance of the APpDelegate back
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        
        // Get access to the context from the AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        // Execute the fetch request and save the AnyObject instances
        feedArray = context.executeFetchRequest(request, error: nil)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // Camera is available
            
            // Note that UIImagePickerController is a subclass of UINavigationController, so we need to conform to the UINAvigationController protocol
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            // Specify the media types for our media controller, in our case it is media data
            // kUTTypeImage is an 'abstract type' and it type defs to CFString. Essentially it is being usedd as an identifier for certain type of data and we are specifying that the data is going to be image data. Theoretically you could have pass different media types, but we'll stick to image types for now
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            // Present the camera controller to the screen
            self.presentViewController(cameraController, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // The photo library is available
            
            var photoLibraryController = UIImagePickerController()
            // Thanks to the delegate we will be able to know which photos the user is tapping on inside our photo library
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // Specify the media types for our media controller, in our case it is media data
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            // Present the photo library controller to the screen
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            // Neither the camera nor the photo library are available
            
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library. Please check in Settings if they are enabled for this application", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIImagePickerControllerDelegaate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        // info is a dictionary that is passed in the function, we are using the 'UIImagePickerControllerOriginalImage' key to get back the value of the (original) UIImage we want to display
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        // Save the image to CoreData. The image will be converted into a data representation (NSData instance, which is a binary representation) of the UIImage instance
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        // Get the managedObjectContext
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
        // Create an entityDescription
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        
        // Create the FeedItem
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        // Setup the FeedItem and save it
        feedItem.image = imageData
        feedItem.caption = "Test Caption"
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        // Add the feedItem to the feedArray so the user can see the item without having to quit and restart the application
        feedArray.append(feedItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // reload the collectionView data so the user can see the item without having to quit and restart the application
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCollectionViewCell
        
        // The row property refers to the cell (ie row 0 is the first cell, row 1 is the second cell, etc...) not the actual rows of cells
        let thisItem = self.feedArray[indexPath.row] as FeedItem
        
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        // Create a filterViewController
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
}













