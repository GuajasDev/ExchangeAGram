//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Diego Guajardo on 13/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)    // We add this so the FeedItem class can interact with Objective-C, just in case we need it
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
