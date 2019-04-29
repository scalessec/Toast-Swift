import UIKit

public extension UIView {
    /**
     Keys used for associated objects.
     */
    private struct ToastKeys {
        static var activityView = "com.toast-swift.activityView"
    }

    /**
     Creates and displays a new toast activity indicator view at a specified position.

     @warning Only one toast activity indicator view can be presented per superview. Subsequent
     calls to `makeToastActivity(position:)` will be ignored until `hideToastActivity()` is called.

     @warning `makeToastActivity(position:)` works independently of the `showToast` methods. Toast
     activity views can be presented and dismissed while toast views are being displayed.
     `makeToastActivity(position:)` has no effect on the queueing behavior of the `showToast` methods.

     @param position The toast's position
     */
    func makeToastActivity(_ position: ToastPosition) {
        // sanity
        guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }

        let toast = createToastActivityView()
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        makeToastActivity(toast, point: point)
    }

    /**
     Creates and displays a new toast activity indicator view at a specified position.

     @warning Only one toast activity indicator view can be presented per superview. Subsequent
     calls to `makeToastActivity(position:)` will be ignored until `hideToastActivity()` is called.

     @warning `makeToastActivity(position:)` works independently of the `showToast` methods. Toast
     activity views can be presented and dismissed while toast views are being displayed.
     `makeToastActivity(position:)` has no effect on the queueing behavior of the `showToast` methods.

     @param point The toast's center point
     */
    func makeToastActivity(_ point: CGPoint) {
        // sanity
        guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }

        let toast = createToastActivityView()
        makeToastActivity(toast, point: point)
    }

    /**
     Dismisses the active toast activity indicator view.
     */
    func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView {

            let animations: () -> Void = {
                toast.alpha = 0.0
            }

            let completion: (Bool) -> Void = { _ in
                toast.removeFromSuperview()
                objc_setAssociatedObject(self,
                                         &ToastKeys.activityView,
                                         nil,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration,
                           delay: 0.0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: animations,
                           completion: completion)
        }
    }

    // MARK: - Private Activity Methods

    private func makeToastActivity(_ toast: UIView, point: CGPoint) {
        toast.alpha = 0.0
        toast.center = point

        objc_setAssociatedObject(self,
                                 &ToastKeys.activityView,
                                 toast,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.addSubview(toast)

        let animations: () -> Void = {
            toast.alpha = 1.0
        }

        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: animations)
    }

    private func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style

        let frame = CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height)

        let activityView = UIView(frame: frame)

        activityView.backgroundColor = style.activityBackgroundColor

        activityView.autoresizingMask = [.flexibleLeftMargin,
                                         .flexibleRightMargin,
                                         .flexibleTopMargin,
                                         .flexibleBottomMargin]

        activityView.layer.cornerRadius = style.cornerRadius

        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }

        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        let centerPoint = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityIndicatorView.center = centerPoint
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.color = style.activityIndicatorColor
        activityIndicatorView.startAnimating()

        return activityView
    }

}
