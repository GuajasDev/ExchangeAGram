//
//  FilterCollectionViewCell.swift
//  ExchangeAGram
//
//  Created by Diego Guajardo on 15/02/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    
    // Because we are setting this cell and its collection view in code, rather than the storyboard, we need to initialise the collection view cell using a custom initialiser
    override init(frame: CGRect) {
        // By doing this 'super.init' and passing the same frame that was passed in we are basically saying 'I know the super has an initialiser and we want all that functionality (hence we are calling it) but we also want to add some more custom functionality', and so we write more code afterwards
        super.init(frame: frame)
        
        self.imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(self.imageView)
    }
    
    // We also need to make this class NS-Coding compliant
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}