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

public enum ToastPosition {
    case top
    case center
    case bottom
}

/**
 Toast is a Swift extension that adds toast notifications to the `UIView` object class.
 It is intended to be simple, lightweight, and easy to use. Most toast notifications 
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
public extension UIView {
    
    /**
     Keys used for associated objects.
     */
    private struct ToastKeys {
        static var Timer        = "CSToastTimerKey"
        static var Duration     = "CSToastDurationKey"
        static var Position     = "CSToastPositionKey"
        static var Completion   = "CSToastCompletionKey"
        static var ActiveToast  = "CSToastActiveToastKey"
        static var ActivityView = "CSToastActivityViewKey"
        static var Queue        = "CSToastQueueKey"
    }
    
    /**
     Swift closures can't be directly associated with objects via the
     Objective-C runtime, so the (ugly) solution is to wrap them in a
     class that can be used with associated objects.
     */
    private class ToastCompletionWrapper {
        var completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: Error {
        case insufficientData
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
    
    /**
     Creates and presents a new toast view with a message and displays it with the
     default duration and position. Styled using the shared style.
    
     @param message The message to be displayed
    */
    public func makeToast(_ message: String) {
        self.makeToast(message, duration: ToastManager.shared.duration, position: ToastManager.shared.position)
    }
    
    /**
     Creates and presents a new toast view with a message. Duration and position
     can be set explicitly. Styled using the shared style.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's position
     */
    public func makeToast(_ message: String, duration: TimeInterval, position: ToastPosition) {
        self.makeToast(message, duration: duration, position: position, style: nil)
    }
    
    /**
     Creates and presents a new toast view with a message. Duration and position
     can be set explicitly. Styled using the shared style.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's center point
     */
    public func makeToast(_ message: String, duration: TimeInterval, position: CGPoint) {
        self.makeToast(message, duration: duration, position: position, style: nil)
    }
    
    /**
     Creates and presents a new toast view with a message. Duration, position, and
     style can be set explicitly.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's position
     @param style The style. The shared style will be used when nil
     */
    public func makeToast(_ message: String, duration: TimeInterval, position: ToastPosition, style: ToastStyle?) {
        self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    /**
     Creates and presents a new toast view with a message. Duration, position, and
     style can be set explicitly.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's center point
     @param style The style. The shared style will be used when nil
     */
    public func makeToast(_ message: String, duration: TimeInterval, position: CGPoint, style: ToastStyle?) {
        self.makeToast(message, duration: duration, position: position, title: nil, image: nil, style: style, completion: nil)
    }
    
    /**
     Creates and presents a new toast view with a message, title, and image. Duration,
     position, and style can be set explicitly. The completion closure executes when the
     toast completes presentation. `didTap` will be `true` if the toast view was dismissed
     from a tap.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's position
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @param completion The completion closure, executed after the toast view disappears.
            didTap will be `true` if the toast view was dismissed from a tap.
     */
    public func makeToast(_ message: String?, duration: TimeInterval, position: ToastPosition, title: String?, image: UIImage?, style: ToastStyle?, completion: ((_ didTap: Bool) -> Void)?) {
        var toastStyle = ToastManager.shared.style
        if let style = style {
           toastStyle = style
        }
        
        do {
            let toast = try self.toastViewForMessage(message, title: title, image: image, style: toastStyle)
            self.showToast(toast, duration: duration, position: position, completion: completion)
        } catch ToastError.insufficientData {
            print("Error: message, title, and image are all nil")
        } catch {}
    }
    
    /**
     Creates and presents a new toast view with a message, title, and image. Duration,
     position, and style can be set explicitly. The completion closure executes when the
     toast completes presentation. `didTap` will be `true` if the toast view was dismissed
     from a tap.
     
     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's center point
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @param completion The completion closure, executed after the toast view disappears.
            didTap will be `true` if the toast view was dismissed from a tap.
     */
    public func makeToast(_ message: String?, duration: TimeInterval, position: CGPoint, title: String?, image: UIImage?, style: ToastStyle?, completion: ((_ didTap: Bool) -> Void)?) {
        var toastStyle = ToastManager.shared.style
        if let style = style {
            toastStyle = style
        }
        
        do {
            let toast = try self.toastViewForMessage(message, title: title, image: image, style: toastStyle)
            self.showToast(toast, duration: duration, position: position, completion: completion)
        } catch ToastError.insufficientData {
            print("Error: message, title, and image cannot all be nil")
        } catch {}
    }
    
    // MARK: - Show Toast Methods
    
    /**
    Displays any view as toast using the default duration and position.
    
    @param toast The view to be displayed as toast
    */
    public func showToast(_ toast: UIView) {
        self.showToast(toast, duration: ToastManager.shared.duration, position: ToastManager.shared.position, completion: nil)
    }
    
    /**
     Displays any view as toast at a provided position and duration. The completion closure
     executes when the toast view completes. `didTap` will be `true` if the toast view was
     dismissed from a tap.
     
     @param toast The view to be displayed as toast
     @param duration The notification duration
     @param position The toast's position
     @param completion The completion block, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    public func showToast(_ toast: UIView, duration: TimeInterval, position: ToastPosition, completion: ((_ didTap: Bool) -> Void)?) {
        let point = self.centerPointForPosition(position, toast: toast)
        self.showToast(toast, duration: duration, position: point, completion: completion)
    }
    
    /**
     Displays any view as toast at a provided position and duration. The completion closure
     executes when the toast view completes. `didTap` will be `true` if the toast view was
     dismissed from a tap.
     
     @param toast The view to be displayed as toast
     @param duration The notification duration
     @param position The toast's center point
     @param completion The completion block, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    public func showToast(_ toast: UIView, duration: TimeInterval, position: CGPoint, completion: ((_ didTap: Bool) -> Void)?) {
        objc_setAssociatedObject(toast, &ToastKeys.Completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActiveToast) as? UIView, ToastManager.shared.queueEnabled {
            objc_setAssociatedObject(toast, &ToastKeys.Duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(toast, &ToastKeys.Position, NSValue(cgPoint: position), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            self.queue.add(toast)
        } else {
            self.showToast(toast, duration: duration, position: position)
        }
    }
    
    // MARK: - Activity Methods
    
    /**
     Creates and displays a new toast activity indicator view at a specified position.
    
     @warning Only one toast activity indicator view can be presented per superview. Subsequent
     calls to `makeToastActivity(position:)` will be ignored until `hideToastActivity()` is called.
    
     @warning `makeToastActivity(position:)` works independently of the `showToast` methods. Toast
     activity views can be presented and dismissed while toast views are being displayed.
     `makeToastActivity(position:)` has no effect on the queueing behavior of the `showToast` methods.
    
     @param position The toast's position
     */
    public func makeToastActivity(_ position: ToastPosition) {
        // sanity
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActivityView) as? UIView {
            return
        }
        
        let toast = self.createToastActivityView()
        let point = self.centerPointForPosition(position, toast: toast)
        self.makeToastActivity(toast, position: point)
    }
    
    /**
     Creates and displays a new toast activity indicator view at a specified position.
     
     @warning Only one toast activity indicator view can be presented per superview. Subsequent
     calls to `makeToastActivity(position:)` will be ignored until `hideToastActivity()` is called.
     
     @warning `makeToastActivity(position:)` works independently of the `showToast` methods. Toast
     activity views can be presented and dismissed while toast views are being displayed.
     `makeToastActivity(position:)` has no effect on the queueing behavior of the `showToast` methods.
     
     @param position The toast's center point
     */
    public func makeToastActivity(_ position: CGPoint) {
        // sanity
        if let _ = objc_getAssociatedObject(self, &ToastKeys.ActivityView) as? UIView {
            return
        }
        
        let toast = self.createToastActivityView()
        self.makeToastActivity(toast, position: position)
    }
    
    /**
     Dismisses the active toast activity indicator view.
     */
    public func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.ActivityView) as? UIView {
            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: { () -> Void in
                toast.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                toast.removeFromSuperview()
                objc_setAssociatedObject(self, &ToastKeys.ActivityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
        }
    }
    
    // MARK: - Private Activity Methods
    
    private func makeToastActivity(_ toast: UIView, position: CGPoint) {
        toast.alpha = 0.0
        toast.center = position
        
        objc_setAssociatedObject(self, &ToastKeys.ActivityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            toast.alpha = 1.0
        }, completion: nil)
    }
    
    private func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.backgroundColor
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        return activityView
    }
    
    // MARK: - Private Show/Hide Methods
    
    private func showToast(_ toast: UIView, duration: TimeInterval, position: CGPoint) {
        toast.center = position
        toast.alpha = 0.0
        
        if ToastManager.shared.tapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        objc_setAssociatedObject(self, &ToastKeys.ActiveToast, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: { () -> Void in
            toast.alpha = 1.0
        }) { (finished) -> Void in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            objc_setAssociatedObject(toast, &ToastKeys.Timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func hideToast(_ toast: UIView) {
        self.hideToast(toast, fromTap: false)
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: { () -> Void in
            toast.alpha = 0.0
        }) { (didFinish: Bool) -> Void in
            toast.removeFromSuperview()
            
            objc_setAssociatedObject(self, &ToastKeys.ActiveToast, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.Completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.Duration) as? NSNumber, let position = objc_getAssociatedObject(nextToast, &ToastKeys.Position) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, position: position.cgPointValue)
            }
        }
    }
    
    // MARK: - Events
    
    func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        if let toast = recognizer.view, let timer = objc_getAssociatedObject(toast, &ToastKeys.Timer) as? Timer {
            timer.invalidate()
            self.hideToast(toast, fromTap: true)
        }
    }
    
    func toastTimerDidFinish(_ timer: Timer) {
        if let toast = timer.userInfo as? UIView {
            self.hideToast(toast)
        }
    }
    
    // MARK: - Toast Construction
    
    /**
     Creates a new toast view with any combination of message, title, and image.
     The look and feel is configured via the style. Unlike the `makeToast` methods,
     this method does not present the toast view automatically. One of the `showToast`
     methods must be used to present the resulting view.
    
     @warning if message, title, and image are all nil, this method will throw
     `ToastError.InsufficientData`
    
     @param message The message to be displayed
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @throws `ToastError.InsufficientData` when message, title, and image are all nil
     @return The newly created toast view
    */
    public func toastViewForMessage(_ message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
        // sanity
        if message == nil && title == nil && image == nil {
            throw ToastError.insufficientData
        }
        
        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        if let image = image {
            imageView = UIImageView(image: image)
            imageView?.contentMode = .scaleAspectFit
            imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
        }
        
        var imageRect = CGRect.zero
        
        if let imageView = imageView {
            imageRect.origin.x = style.horizontalPadding
            imageRect.origin.y = style.verticalPadding
            imageRect.size.width = imageView.bounds.size.width
            imageRect.size.height = imageView.bounds.size.height
        }

        if let title = title {
            titleLabel = UILabel()
            titleLabel?.numberOfLines = style.titleNumberOfLines
            titleLabel?.font = style.titleFont
            titleLabel?.textAlignment = style.titleAlignment
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.textColor = style.titleColor
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.text = title;
            
            let maxTitleSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
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
            messageLabel?.lineBreakMode = .byTruncatingTail;
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clear
            
            let maxMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
            if let messageSize = messageSize {
                let actualWidth = min(messageSize.width, maxMessageSize.width)
                let actualHeight = min(messageSize.height, maxMessageSize.height)
                messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            }
        }
  
        var titleRect = CGRect.zero
        
        if let titleLabel = titleLabel {
            titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            titleRect.origin.y = style.verticalPadding
            titleRect.size.width = titleLabel.bounds.size.width
            titleRect.size.height = titleLabel.bounds.size.height
        }
        
        var messageRect = CGRect.zero
        
        if let messageLabel = messageLabel {
            messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
            messageRect.size.width = messageLabel.bounds.size.width
            messageRect.size.height = messageLabel.bounds.size.height
        }
        
        let longerWidth = max(titleRect.size.width, messageRect.size.width)
        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        let wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
        let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)))
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if let titleLabel = titleLabel {
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }
        
        if let imageView = imageView {
            wrapperView.addSubview(imageView)
        }
        
        return wrapperView
    }
    
    // MARK: - Helpers

    private func centerPointForPosition(_ position: ToastPosition, toast: UIView) -> CGPoint {
        let padding: CGFloat = ToastManager.shared.style.verticalPadding
        
        switch(position) {
        case .top:
            return CGPoint(x: self.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + padding)
        case .center:
            return CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: self.bounds.size.width / 2.0, y: (self.bounds.size.height - (toast.frame.size.height / 2.0)) - padding)
        }
    }
}

// MARK: - Toast Style

/**
 `ToastStyle` instances define the look and feel for toast views created via the
 `makeToast` methods as well for toast views created directly with
 `toastViewForMessage(message:title:image:style:)`.

 @warning `ToastStyle` offers relatively simple styling options for the default
 toast view. If you require a toast view with more complex UI, it probably makes more
 sense to create your own custom UIView subclass and present it with the `showToast`
 methods.
*/
public struct ToastStyle {

    public init() {}
    
    /**
     The background color. Default is `UIColor.blackColor()` at 80% opacity.
    */
    public var backgroundColor = UIColor.black.withAlphaComponent(0.8)
    
    /**
     The title color. Default is `UIColor.whiteColor()`.
    */
    public var titleColor = UIColor.white
    
    /**
     The message color. Default is `UIColor.whiteColor()`.
    */
    public var messageColor = UIColor.white
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum width of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's width).
    */
    public var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum height of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's height).
    */
    public var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    /**
     The spacing from the horizontal edge of the toast view to the content. When an image
     is present, this is also used as the padding between the image and the text.
     Default is 10.0.
    */
    public var horizontalPadding: CGFloat = 10.0
    
    /**
     The spacing from the vertical edge of the toast view to the content. When a title
     is present, this is also used as the padding between the title and the message.
     Default is 10.0.
    */
    public var verticalPadding: CGFloat = 10.0
    
    /**
     The corner radius. Default is 10.0.
    */
    public var cornerRadius: CGFloat = 10.0;
    
    /**
     The title font. Default is `UIFont.boldSystemFontOfSize(16.0)`.
    */
    public var titleFont = UIFont.boldSystemFont(ofSize: 16.0)
    
    /**
     The message font. Default is `UIFont.systemFontOfSize(16.0)`.
    */
    public var messageFont = UIFont.systemFont(ofSize: 16.0)
    
    /**
     The title text alignment. Default is `NSTextAlignment.Left`.
    */
    public var titleAlignment = NSTextAlignment.left
    
    /**
     The message text alignment. Default is `NSTextAlignment.Left`.
    */
    public var messageAlignment = NSTextAlignment.left
    
    /**
     The maximum number of lines for the title. The default is 0 (no limit).
    */
    public var titleNumberOfLines = 0
    
    /**
     The maximum number of lines for the message. The default is 0 (no limit).
    */
    public var messageNumberOfLines = 0
    
    /**
     Enable or disable a shadow on the toast view. Default is `false`.
    */
    public var displayShadow = false
    
    /**
     The shadow color. Default is `UIColor.blackColor()`.
     */
    public var shadowColor = UIColor.black
    
    /**
     A value from 0.0 to 1.0, representing the opacity of the shadow.
     Default is 0.8 (80% opacity).
    */
    public var shadowOpacity: Float = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    /**
     The shadow radius. Default is 6.0.
    */
    public var shadowRadius: CGFloat = 6.0
    
    /**
     The shadow offset. The default is 4 x 4.
    */
    public var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /**
     The image size. The default is 80 x 80.
    */
    public var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /**
     The size of the toast activity view when `makeToastActivity(position:)` is called.
     Default is 100 x 100.
    */
    public var activitySize = CGSize(width: 100.0, height: 100.0)
    
    /**
     The fade in/out animation duration. Default is 0.2.
     */
    public var fadeDuration: TimeInterval = 0.2
    
}

// MARK: - Toast Manager

/**
 `ToastManager` provides general configuration options for all toast
 notifications. Backed by a singleton instance.
*/
public class ToastManager {
    
    /**
     The `ToastManager` singleton instance.
     */
    public static let shared = ToastManager()
    
    /**
     The shared style. Used whenever toastViewForMessage(message:title:image:style:) is called
     with with a nil style.
     */
    public var style = ToastStyle()
    
    /**
     Enables or disables tap to dismiss on toast views. Default is `true`.
     */
    public var tapToDismissEnabled = true
    
    /**
     Enables or disables queueing behavior for toast views. When `true`,
     toast views will appear one after the other. When `false`, multiple toast
     views will appear at the same time (potentially overlapping depending
     on their positions). This has no effect on the toast activity view,
     which operates independently of normal toast views. Default is `true`.
     */
    public var queueEnabled = true
    
    /**
     The default duration. Used for the `makeToast` and
     `showToast` methods that don't require an explicit duration.
     Default is 3.0.
     */
    public var duration: TimeInterval = 3.0
    
    /**
     Sets the default position. Used for the `makeToast` and
     `showToast` methods that don't require an explicit position.
     Default is `ToastPosition.Bottom`.
     */
    public var position = ToastPosition.bottom
    
}
