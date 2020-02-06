import UIKit

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
     The background color. Default is `.black` at 80% opacity.
     */
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)

    /**
     The title color. Default is `UIColor.whiteColor()`.
     */
    public var titleColor: UIColor = .white

    /**
     The message color. Default is `.white`.
     */
    public var messageColor: UIColor = .white

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
     Default is 10.0. On iOS11+, this value is added added to the `safeAreaInset.top`
     and `safeAreaInsets.bottom`.
     */
    public var verticalPadding: CGFloat = 10.0

    /**
     The corner radius. Default is 10.0.
     */
    public var cornerRadius: CGFloat = 10.0

    /**
     The title font. Default is `.boldSystemFont(16.0)`.
     */
    public var titleFont: UIFont = .boldSystemFont(ofSize: 16.0)

    /**
     The message font. Default is `.systemFont(ofSize: 16.0)`.
     */
    public var messageFont: UIFont = .systemFont(ofSize: 16.0)

    /**
     The title text alignment. Default is `NSTextAlignment.Left`.
     */
    public var titleAlignment: NSTextAlignment = .left

    /**
     The message text alignment. Default is `NSTextAlignment.Left`.
     */
    public var messageAlignment: NSTextAlignment = .left

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
     The shadow color. Default is `.black`.
     */
    public var shadowColor: UIColor = .black

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

    /**
     Activity indicator color. Default is `.white`.
     */
    public var activityIndicatorColor: UIColor = .white

    /**
     Activity background color. Default is `.black` at 80% opacity.
     */
    public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)

}
