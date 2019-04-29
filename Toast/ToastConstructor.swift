import UIKit

public extension UIView {

    private enum ToastError: Error, LocalizedError {
        case missingParameters

        var errorDescription: String? {
            return "Error: message, title, and image are all nil"
        }
    }

    /**
     Creates a new toast view with any combination of message, title, and image.
     The look and feel is configured via the style. Unlike the `makeToast` methods,
     this method does not present the toast view automatically. One of the `showToast`
     methods must be used to present the resulting view.

     @warning if message, title, and image are all nil, this method will throw
     `ToastError.missingParameters`

     @param message The message to be displayed
     @param title The title
     @param image The image
     @param style The style. The shared style will be used when nil
     @throws `ToastError.missingParameters` when message, title, and image are all nil
     @return The newly created toast view
     */
    func toastViewForMessage(_ message: String?,
                             title: String?,
                             image: UIImage?,
                             style: ToastStyle) throws -> UIView {

        guard message != nil || title != nil || image != nil else {
            throw ToastError.missingParameters
        }

        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?

        let wrapperView = createWrapperView(with: style)

        if let image = image {
            imageView = createImageView(with: style, image: image)
        }

        var imageRect = CGRect.zero

        if let imageView = imageView {
            imageRect = createImageRect(with: style, from: imageView)
        }

        if let title = title {
            titleLabel = createTitleLabel(with: style, imageRect: imageRect, title: title)
        }

        if let message = message {
            messageLabel = createMessageLabel(with: style, imageRect: imageRect, message: message)
        }

        var titleRect = CGRect.zero

        if let titleLabel = titleLabel {
            titleRect = createTitleRect(with: style, imageRect: imageRect, titleLabel: titleLabel)
        }

        var messageRect = CGRect.zero

        if let messageLabel = messageLabel {
            messageRect = createMessageRect(with: style, imageRect: imageRect,
                                            titleRect: titleRect, messageLabel: messageLabel)
        }

        let longerWidth = max(titleRect.size.width, messageRect.size.width)

        let longerX = max(titleRect.origin.x, messageRect.origin.x)

        let wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)),
                               (longerX + longerWidth + style.horizontalPadding))

        let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding),
                                (imageRect.size.height + (style.verticalPadding * 2.0)))

        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)

        if let titleLabel = titleLabel {
            titleRect.size.width = longerWidth
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }

        if let messageLabel = messageLabel {
            messageRect.size.width = longerWidth
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }

        if let imageView = imageView {
            wrapperView.addSubview(imageView)
        }

        return wrapperView
    }

    fileprivate func createTitleRect(with style: ToastStyle, imageRect: CGRect, titleLabel: UILabel) -> CGRect {
        var titleRect = CGRect()
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
        titleRect.origin.y = style.verticalPadding
        titleRect.size.width = titleLabel.bounds.size.width
        titleRect.size.height = titleLabel.bounds.size.height
        return titleRect
    }

    fileprivate func createMessageRect(with style: ToastStyle,
                                       imageRect: CGRect,
                                       titleRect: CGRect,
                                       messageLabel: UILabel) -> CGRect {
        var messageRect = CGRect()
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
        messageRect.size.width = messageLabel.bounds.size.width
        messageRect.size.height = messageLabel.bounds.size.height
        return messageRect
    }

    fileprivate func createWrapperView(with style: ToastStyle) -> UIView {
        let wrapperView = UIView()

        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin,
                                        .flexibleRightMargin,
                                        .flexibleTopMargin,
                                        .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius

        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }

        return wrapperView
    }

    fileprivate func createImageView(with style: ToastStyle, image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: style.horizontalPadding,
                                  y: style.verticalPadding,
                                  width: style.imageSize.width,
                                  height: style.imageSize.height)
        return imageView
    }

    fileprivate func createImageRect(with style: ToastStyle, from imageView: UIImageView) -> CGRect {
        var imageRect = CGRect()
        imageRect.origin.x = style.horizontalPadding
        imageRect.origin.y = style.verticalPadding
        imageRect.size.width = imageView.bounds.size.width
        imageRect.size.height = imageView.bounds.size.height
        return imageRect
    }

    fileprivate func createTitleLabel(with style: ToastStyle, imageRect: CGRect, title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = style.titleNumberOfLines
        titleLabel.font = style.titleFont
        titleLabel.textAlignment = style.titleAlignment
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = style.titleColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.text = title

        let width = (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width
        let height = self.bounds.size.height * style.maxHeightPercentage
        let maxTitleSize = CGSize(width: width, height: height)
        let titleSize = titleLabel.sizeThatFits(maxTitleSize)
        titleLabel.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)

        return titleLabel
    }

    fileprivate func createMessageLabel(with style: ToastStyle, imageRect: CGRect, message: String) -> UILabel {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = style.messageNumberOfLines
        messageLabel.font = style.messageFont
        messageLabel.textAlignment = style.messageAlignment
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = style.messageColor
        messageLabel.backgroundColor = UIColor.clear

        let width = (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width
        let height = self.bounds.size.height * style.maxHeightPercentage
        let maxMessageSize = CGSize(width: width,
                                    height: height)
        let messageSize = messageLabel.sizeThatFits(maxMessageSize)
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
        messageLabel.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)

        return messageLabel
    }
}
