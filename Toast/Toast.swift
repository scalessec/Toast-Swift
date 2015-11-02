//
//  Toast.swift
//  Toast-Swift
//
//  Copyright (c) 2015 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import ObjectiveC

enum ToastPosition {
    case Top
    case Center
    case Bottom
}

/**
 Toast is Swift extension that adds toast notifications to the UIView object class.
 It is intended to be simple, lightweight, and easy to use. Most toast notifications 
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
extension UIView {
    
    private struct ToastKeys {
        static var Timer        = "CSToastTimerKey"
        static var Duration     = "CSToastDurationKey"
        static var Position     = "CSToastPositionKey"
        static var Completion   = "CSToastCompletionKey"
        static var ActiveToast  = "CSToastActiveToastKey"
        static var ActivityView = "CSToastActivityViewKey"
        static var Queue        = "CSToastQueueKey"
    }
    
    private class ToastCompletionWrapper {
        var completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: ErrorType {
        case InsufficientData
    }
    
    private var queue: NSMutableArray {
        get {
            if let queue = objc_getAssociatedObject(self, &ToastKeys.Queue) as? NSMutableArray {
                return queue
            } else {
                let queue = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.Queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return queue
            }
        }
    }
    
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
        self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    func makeToast(message: String, duration: NSTimeInterval, position: CGPoint, style: ToastStyle?) {
        self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    func makeToast(message: String?, duration: NSTimeInterval, position: ToastPosition, title: String?, image: UIImage?, style: ToastStyle?, completion: ((didTap: Bool) -> Void)?) {
        var toastStyle = ToastManager.shared.style
        if let style = style {
           toastStyle = style
        }
        
        do {
            let toast = try self.toastViewForMessage(message, title: title, image: image, style: toastStyle)
            self.showToast(toast, duration: duration, position: position, completion: completion)
        } catch ToastError.InsufficientData {
            print("Error: message, title, and image are all nil")
        } catch {}
    }
    
    func makeToast(message: String?, duration: NSTimeInterval, position: CGPoint, title: String?, image: UIImage?, style: ToastStyle?, completion: ((didTap: Bool) -> Void)?) {
        var toastStyle = ToastManager.shared.style
        if let style = style {
            toastStyle = style
        }
        
        do {
            let toast = try self.toastViewForMessage(message, title: title, image: image, style: toastStyle)
            self.showToast(toast, duration: duration, position: position, completion: completion)
        } catch ToastError.InsufficientData {
            print("Error: message, title, and image are all nil")
        } catch {}
    }
    
    // MARK: - Activity Methods
    
    func makeToastActivity(position: ToastPosition) {
        // sanity
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActiveToast) as? UIView {
            return
        }
        
        let toast = self.createToastActivityView()
        let point = self.centerPointForPosition(position, toast: toast)
        self.makeToastActivity(toast, position: point)
    }
    
    func makeToastActivity(position: CGPoint) {
        // sanity
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActiveToast) as? UIView {
            return
        }
        
        let toast = self.createToastActivityView()
        self.makeToastActivity(toast, position: position)
    }
    
    func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.ActivityView) as? UIView {
            UIView.animateWithDuration(ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: { () -> Void in
                toast.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                toast.removeFromSuperview()
                objc_setAssociatedObject (self, &ToastKeys.ActivityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
        }
    }
    
    private func makeToastActivity(toast: UIView, position: CGPoint) {
        toast.alpha = 0.0
        toast.center = position
        
        objc_setAssociatedObject (self, &ToastKeys.ActivityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toast)
        
        UIView.animateWithDuration(ToastManager.shared.style.fadeDuration, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            toast.alpha = 1.0
        }, completion: nil)
    }
    
    private func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.backgroundColor
        activityView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.CGColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        return activityView
    }

    // MARK: - Show Toast Methods

    func showToast(toast: UIView) {
        self.showToast(toast, duration: ToastManager.shared.duration, position: ToastManager.shared.position, completion: nil)
    }
    
    func showToast(toast: UIView, duration: NSTimeInterval, position: ToastPosition, completion: ((didTap: Bool) -> Void)?) {
        let point = self.centerPointForPosition(position, toast: toast)
        self.showToast(toast, duration: duration, position: point, completion: completion)
    }
    
    func showToast(toast: UIView, duration: NSTimeInterval, position: CGPoint, completion: ((didTap: Bool) -> Void)?) {
        objc_setAssociatedObject(toast, &ToastKeys.Completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActiveToast) as? UIView where ToastManager.shared.queueEnabled {
            objc_setAssociatedObject(toast, &ToastKeys.Duration, NSNumber(double: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(toast, &ToastKeys.Position, NSValue(CGPoint: position), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            self.queue.addObject(toast)
        } else {
            self.showToast(toast, duration: duration, position: position)
        }
    }
    
    // MARK: - Private Show/Hide Methods
    
    private func showToast(toast: UIView, duration: NSTimeInterval, position: CGPoint) {
        toast.center = position
        toast.alpha = 0.0
        
        if ToastManager.shared.tapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: "handleToastTapped:")
            toast.addGestureRecognizer(recognizer)
            toast.userInteractionEnabled = true
            toast.exclusiveTouch = true
        }
        
        objc_setAssociatedObject(self, &ToastKeys.ActiveToast, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.addSubview(toast)
        
        UIView.animateWithDuration(ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.CurveEaseOut, .AllowUserInteraction], animations: { () -> Void in
            toast.alpha = 1.0
        }) { (Bool finished) -> Void in
            let timer = NSTimer(timeInterval: duration, target: self, selector: "toastTimerDidFinish:", userInfo: toast, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            objc_setAssociatedObject(toast, &ToastKeys.Timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func hideToast(toast: UIView) {
        self.hideToast(toast, fromTap: false)
    }
    
    private func hideToast(toast: UIView, fromTap: Bool) {
        
        UIView.animateWithDuration(ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: { () -> Void in
            toast.alpha = 0.0
        }) { (didFinish: Bool) -> Void in
            toast.removeFromSuperview()
            
            objc_setAssociatedObject(self, &ToastKeys.ActiveToast, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.Completion) as? ToastCompletionWrapper, completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? UIView, duration = objc_getAssociatedObject(nextToast, &ToastKeys.Duration) as? NSNumber, position = objc_getAssociatedObject(nextToast, &ToastKeys.Position) as? NSValue {
                self.queue.removeObjectAtIndex(0)
                self.showToast(nextToast, duration: duration.doubleValue, position: position.CGPointValue())
            }
        }
    }
    
    // MARK: - Events
    
    func handleToastTapped(recognizer: UITapGestureRecognizer) {
        if let toast = recognizer.view, timer = objc_getAssociatedObject(toast, &ToastKeys.Timer) as? NSTimer {
            timer.invalidate()
            self.hideToast(toast, fromTap: true)
        }
    }
    
    func toastTimerDidFinish(timer: NSTimer) {
        if let toast = timer.userInfo as? UIView {
            self.hideToast(toast)
        }
    }
    
    // MARK: - Toast Construction
    
    func toastViewForMessage(message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
        // sanity
        if message == nil && title == nil && image == nil {
            throw ToastError.InsufficientData
        }
        
        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.blackColor().CGColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        if let image = image {
            imageView = UIImageView(image: image)
            imageView?.contentMode = .ScaleAspectFit
            imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
        }
        
        var imageX: CGFloat = 0.0
        var imageWidth: CGFloat = 0.0
        var imageHeight: CGFloat = 0.0
        
        if let imageView = imageView {
            imageX = style.horizontalPadding
            imageWidth = imageView.bounds.size.width
            imageHeight = imageView.bounds.size.height
        }

        if let title = title {
            titleLabel = UILabel()
            titleLabel?.numberOfLines = style.titleNumberOfLines
            titleLabel?.font = style.titleFont
            titleLabel?.textAlignment = style.titleAlignment
            titleLabel?.lineBreakMode = .ByWordWrapping
            titleLabel?.textColor = style.titleColor
            titleLabel?.backgroundColor = UIColor.clearColor();
            titleLabel?.text = title;
            
            let maxTitleSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageWidth, height: self.bounds.size.height * style.maxHeightPercentage)
            let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
            if let titleSize = titleSize {
                titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
            }
        }
        
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.text = message
            messageLabel?.numberOfLines = style.messageNumberOfLines
            messageLabel?.font = style.messageFont
            messageLabel?.textAlignment = style.messageAlignment
            messageLabel?.lineBreakMode = .ByWordWrapping;
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clearColor()
            
            let maxMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageWidth, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
            if let messageSize = messageSize {
                messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: messageSize.width, height: messageSize.height)
            }
        }
  
        var titleX: CGFloat = 0.0
        var titleY: CGFloat = 0.0
        var titleWidth: CGFloat = 0.0
        var titleHeight: CGFloat = 0.0
        
        if let titleLabel = titleLabel {
            titleX = imageX + imageWidth + style.horizontalPadding
            titleY = style.verticalPadding
            titleWidth = titleLabel.bounds.size.width
            titleHeight = titleLabel.bounds.size.height
        }
        
        var messageX: CGFloat = 0.0
        var messageY: CGFloat = 0.0
        var messageWidth: CGFloat = 0.0
        var messageHeight: CGFloat = 0.0
        
        if let messageLabel = messageLabel {
            messageX = imageX + imageWidth + style.horizontalPadding
            messageY = titleY + titleHeight + style.verticalPadding
            messageWidth = messageLabel.bounds.size.width
            messageHeight = messageLabel.bounds.size.height
        }
        
        let longerWidth = max(titleWidth, messageWidth)
        let longerX = max(titleX, messageX)
        let wrapperWidth = max((imageWidth + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
        let wrapperHeight = max((messageY + messageHeight + style.verticalPadding), (imageHeight + (style.verticalPadding * 2.0)))
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if let titleLabel = titleLabel {
            titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageLabel.frame = CGRect(x: messageX, y: messageY, width: messageWidth, height: messageHeight)
            wrapperView.addSubview(messageLabel)
        }
        
        if let imageView = imageView {
            wrapperView.addSubview(imageView)
        }
        
        return wrapperView
    }
    
    // MARK: - Helpers

    private func centerPointForPosition(position: ToastPosition, toast: UIView) -> CGPoint {
        let padding: CGFloat = ToastManager.shared.style.verticalPadding
        
        switch(position) {
        case .Top:
            return CGPoint(x: self.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + padding)
        case .Center:
            return CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        case .Bottom:
            return CGPoint(x: self.bounds.size.width / 2.0, y: (self.bounds.size.height - (toast.frame.size.height / 2.0)) - padding)
        }
    }
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
    var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum height of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's height).
    */
    var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    /**
     The spacing from the horizontal edge of the toast view to the content. When an image
     is present, this is also used as the padding between the image and the text.
     Default is 10.0.
    */
    var horizontalPadding: CGFloat = 10.0
    
    /**
     The spacing from the vertical edge of the toast view to the content. When a title
     is present, this is also used as the padding between the title and the message.
     Default is 10.0.
    */
    var verticalPadding: CGFloat = 10.0
    
    /**
     The corner radius. Default is 10.0.
    */
    var cornerRadius: CGFloat = 10.0;
    
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
     The shadow color. Default is `UIColor.blackColor()`.
     */
    var shadowColor = UIColor.blackColor()
    
    /**
     A value from 0.0 to 1.0, representing the opacity of the shadow.
     Default is 0.8 (80% opacity).
    */
    var shadowOpacity: Float = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    /**
     The shadow radius. Default is 6.0.
    */
    var shadowRadius: CGFloat = 6.0
    
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
    
    /**
     The fade in/out animation duration. Default is 0.2.
     */
    var fadeDuration: NSTimeInterval = 0.2
    
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