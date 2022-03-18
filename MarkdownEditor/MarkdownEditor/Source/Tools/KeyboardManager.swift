
import UIKit

protocol KeyboardManagerDidChangeVisibleDelegate: AnyObject {
    func keyboardManagerChangedKeyboardVisible(sender: KeyboardManager, visible: Bool)
}
protocol KeyboardManagerWillChangeFrameDelegate: AnyObject {
    func keyboardManagerWillChangeKeyboardFrame(sender: KeyboardManager, from startFrame: CGRect, to endFrame: CGRect)
}
protocol KeyboardManagerDidChangeFrameDelegate: AnyObject {
    func keyboardManagerDidChangeKeyboardFrame(sender: KeyboardManager, from startFrame: CGRect, to endFrame: CGRect)
}

class KeyboardManager {
    
    var keyboardVisible: Bool = false
    var keyboardFrame: CGRect = CGRect.zero
    
    var visibilityDelegate: KeyboardManagerDidChangeVisibleDelegate?
    var willChangeFrameDelegate: KeyboardManagerWillChangeFrameDelegate?
    var didChangeFrameDelegate: KeyboardManagerDidChangeFrameDelegate?
    
    static var sharedInstance: KeyboardManager = {
        let manager = KeyboardManager(isShared: true)
        return manager
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    convenience init() {
        self.init(isShared: false)
        
    }
    
    private init(isShared: Bool) {
        attachNotifications()
        
        if isShared == false {
            keyboardVisible = KeyboardManager.sharedInstance.keyboardVisible
            keyboardFrame = KeyboardManager.sharedInstance.keyboardFrame
        }
    }
    
    private func attachNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc private func onKeyboardChange(notification: NSNotification) {
        guard let info = notification.userInfo else {
            return
        }
        guard let value: NSValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let oldValue: NSValue = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        
        let newFrame = value.cgRectValue
        self.keyboardFrame = newFrame
        
        let oldFrame = oldValue.cgRectValue
        
        if let durationNumber = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardCurveNumber = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            let duration = durationNumber.doubleValue
            let keyboardCurve = keyboardCurveNumber.uintValue
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: keyboardCurve), animations: {
                self.willChangeFrameDelegate?.keyboardManagerWillChangeKeyboardFrame(sender: self, from: oldFrame, to: newFrame)
            }, completion: { _ in
                self.didChangeFrameDelegate?.keyboardManagerDidChangeKeyboardFrame(sender: self, from: oldFrame, to: newFrame)
            })
        } else {
            self.willChangeFrameDelegate?.keyboardManagerWillChangeKeyboardFrame(sender: self, from: oldFrame, to: newFrame)
            self.didChangeFrameDelegate?.keyboardManagerDidChangeKeyboardFrame(sender: self, from: oldFrame, to: newFrame)
        }
    }
    @objc private func onKeyboardWillShow(notification: NSNotification) {
        self.keyboardVisible = true
        self.visibilityDelegate?.keyboardManagerChangedKeyboardVisible(sender: self, visible: self.keyboardVisible)
    }
    @objc private func onKeyboardWillHide(notification: NSNotification) {
        self.keyboardVisible = false
        self.visibilityDelegate?.keyboardManagerChangedKeyboardVisible(sender: self, visible: self.keyboardVisible)
    }

}

// MARK: - FirstResponder

extension KeyboardManager {
    
    static func findFirstResponderIn(view: UIView?) -> UIView? {
        guard let view = view else { return nil }
        guard !view.isFirstResponder else { return view }
        
        for subview in view.subviews {
            if let firstResponder = findFirstResponderIn(view: subview) {
                return firstResponder
            }
        }
        
        return nil
    }
    
}
