import Foundation

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
    public var isTapToDismissEnabled = true

    /**
     Enables or disables queueing behavior for toast views. When `true`,
     toast views will appear one after the other. When `false`, multiple toast
     views will appear at the same time (potentially overlapping depending
     on their positions). This has no effect on the toast activity view,
     which operates independently of normal toast views. Default is `false`.

     */
    public var isQueueEnabled = false

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
    public var position: ToastPosition = .bottom

}
