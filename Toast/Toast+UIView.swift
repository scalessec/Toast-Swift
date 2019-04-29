import UIKit
import ObjectiveC

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
        static var timer        = "com.toast-swift.timer"
        static var duration     = "com.toast-swift.duration"
        static var point        = "com.toast-swift.point"
        static var completion   = "com.toast-swift.completion"
        static var activeToasts = "com.toast-swift.activeToasts"
        static var queue        = "com.toast-swift.queue"
    }

    /**
     Swift closures can't be directly associated with objects via the
     Objective-C runtime, so the (ugly) solution is to wrap them in a
     class that can be used with associated objects.
     */
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?

        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }

    private var activeToasts: NSMutableArray {
        if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
            return activeToasts
        } else {
            let activeToasts = NSMutableArray()
            objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return activeToasts
        }
    }

    private var queue: NSMutableArray {
        if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
            return queue
        } else {
            let queue = NSMutableArray()
            objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return queue
        }
    }

    // MARK: - Make Toast Methods

    /**
     Creates and presents a new toast view.

     @param message The message to be displayed
     @param duration The toast duration
     @param position The toast's position
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @param completion The completion closure, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    func makeToast(_ message: String?,
                   duration: TimeInterval = ToastManager.shared.duration,
                   position: ToastPosition = ToastManager.shared.position,
                   title: String? = nil,
                   image: UIImage? = nil,
                   style: ToastStyle = ToastManager.shared.style,
                   completion: ((_ didTap: Bool) -> Void)? = nil) {
        do {
            let toast = try toastViewForMessage(message, title: title, image: image, style: style)
            showToast(toast, duration: duration, position: position, completion: completion)
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
    }

    /**
     Creates a new toast view and presents it at a given center point.

     @param message The message to be displayed
     @param duration The toast duration
     @param point The toast's center point
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @param completion The completion closure, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    func makeToast(_ message: String?,
                   duration: TimeInterval = ToastManager.shared.duration,
                   point: CGPoint,
                   title: String?,
                   image: UIImage?,
                   style: ToastStyle = ToastManager.shared.style,
                   completion: ((_ didTap: Bool) -> Void)?) {
        do {
            let toast = try toastViewForMessage(message, title: title, image: image, style: style)
            showToast(toast, duration: duration, point: point, completion: completion)
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
    }

    // MARK: - Show Toast Methods

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
    func showToast(_ toast: UIView,
                   duration: TimeInterval = ToastManager.shared.duration,
                   position: ToastPosition = ToastManager.shared.position,
                   completion: ((_ didTap: Bool) -> Void)? = nil) {
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        showToast(toast, duration: duration, point: point, completion: completion)
    }

    /**
     Displays any view as toast at a provided center point and duration. The completion closure
     executes when the toast view completes. `didTap` will be `true` if the toast view was
     dismissed from a tap.

     @param toast The view to be displayed as toast
     @param duration The notification duration
     @param point The toast's center point
     @param completion The completion block, executed after the toast view disappears.
     didTap will be `true` if the toast view was dismissed from a tap.
     */
    func showToast(_ toast: UIView,
                   duration: TimeInterval = ToastManager.shared.duration,
                   point: CGPoint,
                   completion: ((_ didTap: Bool) -> Void)? = nil) {

        objc_setAssociatedObject(toast,
                                 &ToastKeys.completion,
                                 ToastCompletionWrapper(completion),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast,
                                     &ToastKeys.duration,
                                     NSNumber(value: duration),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            objc_setAssociatedObject(toast,
                                     &ToastKeys.point,
                                     NSValue(cgPoint: point),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            queue.add(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }

    // MARK: - Hide Toast Methods

    /**
     Hides the active toast. If there are multiple toasts active in a view, this method
     hides the oldest toast (the first of the toasts to have been presented).

     @see `hideAllToasts()` to remove all active toasts from a view.

     @warning This method has no effect on activity toasts. Use `hideToastActivity` to
     hide activity toasts.

     */
    func hideToast() {
        guard let activeToast = activeToasts.firstObject as? UIView else { return }
        hideToast(activeToast)
    }

    /**
     Hides an active toast.

     @param toast The active toast view to dismiss. Any toast that is currently being displayed
     on the screen is considered active.

     @warning this does not clear a toast view that is currently waiting in the queue.
     */
    func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
    }

    /**
     Hides all toast views.

     @param includeActivity If `true`, toast activity will also be hidden. Default is `false`.
     @param clearQueue If `true`, removes all toast views from the queue. Default is `true`.
     */
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }

        activeToasts.compactMap { $0 as? UIView }
            .forEach { hideToast($0) }

        if includeActivity {
            hideToastActivity()
        }
    }

    /**
     Removes all toast views from the queue. This has no effect on toast views that are
     active. Use `hideAllToasts(clearQueue:)` to hide the active toasts views and clear
     the queue.
     */
    func clearToastQueue() {
        queue.removeAllObjects()
    }

    // MARK: - Private Show/Hide Methods

    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
        toast.alpha = 0.0

        if ToastManager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }

        activeToasts.add(toast)
        self.addSubview(toast)

        let animations: () -> Void = {
            toast.alpha = 1.0
        }

        let completion: (Bool) -> Void = { _ in
            let timer = Timer(timeInterval: duration,
                              target: self,
                              selector: #selector(UIView.toastTimerDidFinish(_:)),
                              userInfo: toast,
                              repeats: false)

            RunLoop.main.add(timer, forMode: .common)

            objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration,
                       delay: 0.0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: animations,
                       completion: completion)
    }

    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }

        let animations: () -> Void = {
            toast.alpha = 0.0
        }

        let completion: (Bool) -> Void = { _ in
            toast.removeFromSuperview()

            self.activeToasts.remove(toast)

            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper,
                let completion = wrapper.completion {
                completion(fromTap)
            }

            if let nextToast = self.queue.firstObject as? UIView,
                let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber,
                let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
        }

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration,
                       delay: 0.0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: animations,
                       completion: completion)
    }

    // MARK: - Events

    @objc
    private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }

    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
    }

}
