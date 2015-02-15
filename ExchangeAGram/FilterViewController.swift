//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Diego Guajardo on 14/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: Variables
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    var context: CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    // MARK: Constants
    
    let kIntensity = 0.7
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    // MARK: - BODY
    
    // MARK: Initialisers

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // UICollectionViewFlowLayout is responsible of determining the way into which to organise the items inside our CollectionView
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
        // Create the collectionView instance
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        // Important step, otherwise if we do not register our class (and give it a reuseIdentifier we will not have the FilterCollectionViewCell available
        self.collectionView.registerClass(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        self.view.addSubview(self.collectionView)
        
        self.filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCollectionViewCell
        
        // If the cell does not have an image then load it up, otherwise just leave the image as it is
        
        // Set a default placeholder image that will be seen while the phone gets the different filters updated
        cell.imageView.image = self.placeHolderImage
        // GCD (Grand Central Dispatch) is a way to thread your application. Different threads are queued and run when the processor has enough (or available) processing power to run them, ie they are run asynchronously. ** REMEMBER ** that UI updates (touch events, UI update changes like updating labels, etc) should ALWAYS be run on the main thread, otherwise BAD BAD things will happen
        // Create a queue that waits in line until the processor determines there is some space or processing power ready to go and the code will be run. So it will do things as it has availability and will not block your main thread of code, helping a lot to decrease lag
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in
            // Block of code to be run when the processor is ready to run this queue
            
            // Get the filter image from the cache. The function will create a new (unique) file if it doesn't exist yet or will use the existing one if it does
            let filterImage = self.getCachedImage(indexPath.row)
            
            // Go back to the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Get back a UIImage (full size rather than compressed, hence 'thisFeedItem.image' rather than 'thisFeedItem.thumbNail') with the filter in selected item (hence indexPath.row)
        let filterImage:UIImage = filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        // Update the image property in thisFeedItem to have the new filtered image
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        
        // Update the thumbNail property in thisFeedItem to have the new filtered image
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        
        // Save the changes to CoreData
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Helper Functions
    
    func photoFilters() -> [CIFilter] {
        // Photo filters using the Core Image Filter Reference (hence CI)
        
        // Create filters using the ones that come default with iOS
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        // Create filters using your own values. Note that the keys in 'forKey:' are actually strings, we are just using constants that have already been created by Apple
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        // Create a composite filter. The first one is a CIHardLightBlendMode and we are using the output image from the sepia filter (so the sepia filter is evaluated first) and then apply the CIHardLightBlendMode (so both of them are being combined)
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage {
        
        // Convert the imageData into a CIImage
        let unfilteredImage = CIImage(data: imageData)
        
        // Pass the unfilteredImage to the filter and tell it it is an input image
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        
        // Save the output of the filter into a new CIImage
        let filteredImage: CIImage = filter.outputImage
        
        // The extent function allows us to determine what is the rect of our image, so we don't have an extremely large image and the app doesn't have to figure out the size later on
        let extent = filteredImage.extent()
        
        // Create a sample image (a bitmap image, actually) using the filtered image and the extent. It will optimise the UIImage that will be returned later. If unsure what it does try commenting it out and see the difference
        let cgImage: CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        // Create the final image by converting the CGImage into a UIImage
        let finalImage = UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Up)
        
        return finalImage!
    }
    
    // MARK: Caching Fucntions
    
    func cacheImage(imageNumber: Int) {
        // Give the imageFile a unique name and get the path to the temporary directory
        let fileName = "\(imageNumber)"
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
        
        // If a file in the given path DOES NOT exist, create one
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            // Get the image data and THEN write it to the file in the uniquePath. Then 'atomically' will write this data to a backup file and if there are no errors then the backup is renamed to the selected path. Try to write atomically:true unless you have a specific reason not to
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        // Give the imageFile a unique name and get the path to the temporary directory
        let fileName = "\(imageNumber)"
        println(fileName)
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
//        println(uniquePath)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            // If a file exists in the given path then make the image equal to the contents of that file
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            // else if there is no content in the file with the given path, create one and then make the image equal to the contents of that file
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }
}

















