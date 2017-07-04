//
//  DrawTextView.swift
//  
//
//  Created by Remi Robert on 11/07/15.
//
//

import Masonry

class CustomLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 5, 0, 5)))
    }
}

open class DrawTextView: UIView {

    var textLabel: CustomLabel!
    
    var text: String! {
        didSet {
            textLabel.text = text
            sizeTextLabel()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        
        layer.masksToBounds = true
        backgroundColor = UIColor.clear
        textLabel = CustomLabel()
        textLabel.font = textLabel.font.withSize(44)
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.black
        textLabel.backgroundColor = UIColor.clear
        addSubview(textLabel)
        
        textLabel.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.right.and().left().equalTo()(self)
            make.centerY.equalTo()(self)
            make.centerX.equalTo()(self)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func sizeTextLabel() {
        let oldCenter = textLabel.center
        let styleText = NSMutableParagraphStyle()
        styleText.alignment = NSTextAlignment.center
        let attributsText = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)]
        let sizeTextLabel = (NSString(string: textLabel.text!)).boundingRect(with: superview!.frame.size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributsText, context: nil)
        textLabel.frame.size = CGSize(width: sizeTextLabel.width + 10, height: sizeTextLabel.height + 10)
        textLabel.center = oldCenter
    }
}
