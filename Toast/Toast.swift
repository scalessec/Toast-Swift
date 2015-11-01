//
//  Toast.swift
//  Toast-Swift
//
//  Created by Charles Scalesse on 11/1/15.
//  Copyright © 2015 Charles Scalesse. All rights reserved.
//

import UIKit

enum ToastError: ErrorType {
    case InsufficientData
}

extension UIView {
    
/*
    func createToastView(message: String?, title: String?, image: UIImage?) throws -> UIView {
        // sanity
        if message == nil && title == nil && image == nil {
            throw ToastError.InsufficientData
        }
        
        
    }
*/
    
}

struct ToastStyle {
    
    /**
    The background color. Default is `[UIColor blackColor]` at 80% opacity.
    */
    var backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
    
    /**
    The title color. Default is `[UIColor whiteColor]`.
    */
    var titleColor = UIColor.whiteColor()
    
    /**
    The message color. Default is `[UIColor whiteColor]`.
    */
    var messageColor = UIColor.whiteColor()
    
    /**
    A percentage value from 0.0 to 1.0, representing the maximum width of the toast
    view relative to it's superview. Default is 0.8 (80% of the superview's width).
    */
    var maxWidthPercentage = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    
    /**
    A percentage value from 0.0 to 1.0, representing the maximum height of the toast
    view relative to it's superview. Default is 0.8 (80% of the superview's height).
    */
    var maxHeightPercentage = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    /**
    The spacing from the horizontal edge of the toast view to the content. When an image
    is present, this is also used as the padding between the image and the text.
    Default is 10.0.
    */
    var horizontalPadding = 10.0
    
    /**
    The spacing from the vertical edge of the toast view to the content. When a title
    is present, this is also used as the padding between the title and the message.
    Default is 10.0.
    */
    var verticalPadding = 10.0
    
    /**
    The corner radius. Default is 10.0.
    */
    var cornerRadius = 10.0;
    
    /**
    The title font. Default is `[UIFont boldSystemFontOfSize:16.0]`.
    */
    var titleFont = UIFont.boldSystemFontOfSize(16.0)
    
    /**
    The message font. Default is `[UIFont systemFontOfSize:16.0]`.
    */
    var messageFont = UIFont.systemFontOfSize(16.0)
    
    /**
    The title text alignment. Default is `NSTextAlignmentLeft`.
    */
    var titleAlignment = NSTextAlignment.Left
    
    /**
    The message text alignment. Default is `NSTextAlignmentLeft`.
    */
    var messageAlignment = NSTextAlignment.Left
    
    /**
    The maximum number of lines for the title. The default is 0 (no limit).
    */
    var titleNumberOfLines = 0;
    
    /**
    The maximum number of lines for the message. The default is 0 (no limit).
    */
    var messageNumberOfLines = 0;
    
    /**
    Enable or disable a shadow on the toast view. Default is `false`.
    */
    var displayShadow = false;
    
    /**
    A value from 0.0 to 1.0, representing the opacity of the shadow.
    Default is 0.8 (80% opacity).
    */
    var shadowOpacity = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    /**
    The shadow radius. Default is 6.0.
    */
    var shadowRadius = 6.0
    
    /**
    The shadow offset. The default is `CGSizeMake(4.0, 4.0)`.
    */
    var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /**
    The image size. The default is `CGSizeMake(80.0, 80.0)`.
    */
    var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /**
    The size of the toast activity view when `makeToastActivity:` is called.
    Default is `CGSizeMake(100.0, 100.0)`.
    */
    var activitySize = CGSize(width: 80.0, height: 80.0)
    
}

class ToastManager {
    
}