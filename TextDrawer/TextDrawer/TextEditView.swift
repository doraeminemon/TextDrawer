//
//  TextEditView.swift
//  
//
//  Created by Remi Robert on 11/07/15.
//
//

import UIKit
import Masonry

protocol TextEditViewDelegate {
    func textEditViewFinishedEditing(_ text: String)
}

open class TextEditView: UIView {

    fileprivate var textView: UITextView!
    fileprivate var textContainer: UIView!
    
    var delegate: TextEditViewDelegate?

    var textSize: Int! = 42
    
    var textEntry: String! {
        set {
            textView.text = newValue
        }
        get {
            return textView.text
        }
    }
    
    var isEditing: Bool! {
        didSet {
            if isEditing == true {
                textContainer.isHidden = false;
                isUserInteractionEnabled = true;
                backgroundColor = UIColor.black.withAlphaComponent(0.65)
                textView.becomeFirstResponder()
            }
            else {
                backgroundColor = UIColor.clear
                textView.resignFirstResponder()
                textContainer.isHidden = true;
                isUserInteractionEnabled = false;
                delegate?.textEditViewFinishedEditing(textView.text)
            }
        }
    }
        
    init() {
        super.init(frame: CGRect.zero)
        
        isEditing = false
        textContainer = UIView()
        textContainer.layer.masksToBounds = true
        addSubview(textContainer)
        textContainer.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.edges.equalTo()(self)
        }
        
        textView = UITextView()
        textView.tintColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 44)
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.clear
        textView.returnKeyType = UIReturnKeyType.done
        textView.clipsToBounds = true
        textView.delegate = self
        
        textContainer.addSubview(textView)
        textView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.edges.equalTo()(self.textContainer)
        }
        
        textContainer.isHidden = true
        isUserInteractionEnabled = false
        
        keyboardNotification()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextEditView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            isEditing = false
            return false
        }
        if textView.text.characters.count + text.characters.count > textSize {
            return false
        }
        return true
    }
}

extension TextEditView {
    
    func keyboardNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { (notification: Notification) -> Void in
            if let userInfo = notification.userInfo {
                self.textContainer.layer.removeAllAnimations()
                if let keyboardRectEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
                    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).floatValue {
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.textContainer.mas_updateConstraints({ (make: MASConstraintMaker!) -> Void in
                                make.bottom.offset()(-keyboardRectEnd.height)
                            })
                            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                                self.textContainer.layoutIfNeeded()
                                }, completion: nil)
                        })
                }
            }
        }
    }
}
