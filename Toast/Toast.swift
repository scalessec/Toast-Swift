//
//  Toast.swift
//  Toast-Swift
//
//  Created by Charles Scalesse on 11/1/15.
//  Copyright © 2015 Charles Scalesse. All rights reserved.
//

import UIKit

enum ToastPosition {
    case Top
    case Center
    case Bottom
}

enum ToastError: ErrorType {
    case InsufficientData
}

/**
 Toast is Swift extension that adds toast notifications to the UIView object class. 
 It is intended to be simple, lightweight, and easy to use. Most toast notifications 
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
extension UIView {
    
    // MARK: - Make Toast Methods
    
    func makeToast(message: String) {
        self.makeToast(message, duration: ToastManager.shared.duration, position: ToastManager.shared.position)
    }
    
    func makeToast(message: String, duration: NSTimeInterval, position: ToastPosition) {
        self.makeToast(message, duration: duration, position: position, style: nil)
    }
    
    func makeToast(message: String, duration: NSTimeInterval, position: CGPoint) {
        self.makeToast(message, duration: duration, position: position, style: nil)
    }
    
    func makeToast(message: String, duration: NSTimeInterval, position: ToastPosition, style: ToastStyle?) {
        try! self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    func makeToast(message: String, duration: NSTimeInterval, position: CGPoint, style: ToastStyle?) {
        try! self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    func makeToast(message: String?, duration: NSTimeInterval, position: ToastPosition, title: String?, image: UIImage?, style: ToastStyle?, completion: ((didTap: Bool) -> Void)?) throws {
        let toast = try self.createToastView(message, title: title, image: image)
        self.showToast(toast, duration: duration, position: position, completion: completion)
    }
    
    func makeToast(message: String?, duration: NSTimeInterval, position: CGPoint, title: String?, image: UIImage?, style: ToastStyle?, completion: ((didTap: Bool) -> Void)?) throws {
        let toast = try self.createToastView(message, title: title, image: image)
        self.showToast(toast, duration: duration, position: position, completion: completion)
    }
    
    func makeToastActivity(position: ToastPosition) {
    
    }
    
    func makeToastActivity(position: CGPoint) {
        
    }
    
    func hideToastActivity() {
        
    }
  
    // MARK: - Show Toast Methods
    
    func showToast(toast: UIView) {
        
    }
    
    func showToast(toast: UIView, duration: NSTimeInterval, position: ToastPosition, completion: ((didTap: Bool) -> Void)?) {
        
    }
    
    func showToast(toast: UIView, duration: NSTimeInterval, position: CGPoint, completion: ((didTap: Bool) -> Void)?) {
        
    }
    
    // MARK: - View Construction
    
    func createToastView(message: String?, title: String?, image: UIImage?) throws -> UIView {
        // sanity
        if message == nil && title == nil && image == nil {
            throw ToastError.InsufficientData
        }
        
        return UIView()
    }
    
    // MARK: - Helpers
}

// MARK: - Toast Style

/**
 `ToastStyle` instances define the look and feel for toast views created via the
 `makeToast` methods as well for toast views created directly with
 `createToast(message:title:image:style:)`.

 @warning `ToastStyle` offers relatively simple styling options for the default
 toast view. If you require a toast view with more complex UI, it probably makes more
 sense to create your own custom UIView subclass and present it with the `showToast`
 methods.
*/
struct ToastStyle {
    
    /**
     The background color. Default is `UIColor.blackColor()` at 80% opacity.
    */
    var backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
    
    /**
     The title color. Default is `UIColor.whiteColor()`.
    */
    var titleColor = UIColor.whiteColor()
    
    /**
     The message color. Default is `UIColor.whiteColor()`.
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
     The title font. Default is `UIFont.boldSystemFontOfSize(16.0)`.
    */
    var titleFont = UIFont.boldSystemFontOfSize(16.0)
    
    /**
     The message font. Default is `UIFont.systemFontOfSize(16.0)`.
    */
    var messageFont = UIFont.systemFontOfSize(16.0)
    
    /**
     The title text alignment. Default is `NSTextAlignment.Left`.
    */
    var titleAlignment = NSTextAlignment.Left
    
    /**
     The message text alignment. Default is `NSTextAlignment.Left`.
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
     The shadow offset. The default is 4 x 4.
    */
    var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /**
     The image size. The default is 80 x 80.
    */
    var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /**
     The size of the toast activity view when `makeToastActivity` is called.
     Default is 100 x 100.
    */
    var activitySize = CGSize(width: 100.0, height: 100.0)
    
}

// MARK: - Toast Manager

/**
 `ToastManager` provides general configuration options for all toast
 notifications. Backed by a singleton instance.
*/
class ToastManager {
    
    static let shared = ToastManager()
    
    var style = ToastStyle()
    
    var tapToDismissEnabled = true
    
    var queueEnabled = true
    
    var duration: NSTimeInterval = 3.0
    
    var position = ToastPosition.Bottom
    
}