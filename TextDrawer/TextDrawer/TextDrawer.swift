//
//  DrawView.swift
//  
//
//  Created by Remi Robert on 11/07/15.
//
//

//Scrux

import UIKit
import Masonry

open class TextDrawer: UIView, TextEditViewDelegate {

    fileprivate var textEditView: TextEditView!
    fileprivate var drawTextView: DrawTextView!
    
    fileprivate var initialTransformation: CGAffineTransform!
    fileprivate var initialCenterDrawTextView: CGPoint!
    fileprivate var initialRotationTransform: CGAffineTransform!
    fileprivate var initialReferenceRotationTransform: CGAffineTransform!
    
    fileprivate var activieGestureRecognizer = NSMutableSet()
    fileprivate var activeRotationGesture: UIRotationGestureRecognizer?
    fileprivate var activePinchGesture: UIPinchGestureRecognizer?
    
    fileprivate lazy var tapRecognizer: UITapGestureRecognizer! = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextDrawer.handleTapGesture(_:)))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()
    
    fileprivate lazy var panRecognizer: UIPanGestureRecognizer! = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TextDrawer.handlePanGesture(_:)))
        panRecognizer.delegate = self
        return panRecognizer
    }()
    
    fileprivate lazy var rotateRecognizer: UIRotationGestureRecognizer! = {
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(TextDrawer.handlePinchGesture(_:)))
        rotateRecognizer.delegate = self
        return rotateRecognizer
    }()

    fileprivate lazy var zoomRecognizer: UIPinchGestureRecognizer! = {
        let zoomRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TextDrawer.handlePinchGesture(_:)))
        zoomRecognizer.delegate = self
        return zoomRecognizer
    }()
    
    open func clearText() {
        text = ""
    }
    
    open func resetTransformation() {
        drawTextView.transform = initialTransformation
        drawTextView.mas_updateConstraints({ (make: MASConstraintMaker!) -> Void in
            make.edges.equalTo()(self)
            make.centerX.and().centerY().equalTo()(self)
        })
        drawTextView.center = center
        //drawTextView.sizeTextLabel()
    }
    
    //MARK: -
    //MARK: Setup DrawView
    
    fileprivate func setup() {
        self.layer.masksToBounds = true
        drawTextView = DrawTextView()
        initialTransformation = drawTextView.transform
        addSubview(drawTextView)
        drawTextView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.edges.equalTo()(self)
        }

        textEditView = TextEditView()
        textEditView.delegate = self

        addSubview(textEditView)
        textEditView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.edges.equalTo()(self)
        }
        
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(rotateRecognizer)
        addGestureRecognizer(zoomRecognizer)
        
        initialReferenceRotationTransform = CGAffineTransform.identity
    }
    
    //MARK: -
    //MARK: Initialisation
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
        drawTextView.textLabel.font = drawTextView.textLabel.font.withSize(44)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func textEditViewFinishedEditing(_ text: String) {
        textEditView.isHidden = true
        drawTextView.text = text
    }
}

//MARK: -
//MARK: Proprety extension

public extension TextDrawer {
    
    public var fontSize: CGFloat! {
        set {
            drawTextView.textLabel.font = drawTextView.textLabel.font.withSize(newValue)
        }
        get {
            return  drawTextView.textLabel.font.pointSize
        }
    }
    
    public var font: UIFont! {
        set {
            drawTextView.textLabel.font = newValue
        }
        get {
            return drawTextView.textLabel.font
        }
    }
    
    public var textColor: UIColor! {
        set {
            drawTextView.textLabel.textColor = newValue
        }
        get {
            return drawTextView.textLabel.textColor
        }
    }
    
    public var textAlignement: NSTextAlignment! {
        set {
            drawTextView.textLabel.textAlignment = newValue
        }
        get {
            return drawTextView.textLabel.textAlignment
        }
    }
    
    public var textBackgroundColor: UIColor! {
        set {
            drawTextView.textLabel.backgroundColor = newValue
        }
        get {
            return drawTextView.textLabel.backgroundColor
        }
    }
    
    public var text: String! {
        set {
            drawTextView.text = newValue
        }
        get {
            return drawTextView.text
        }
    }
    
    public var textSize: Int! {
        set {
            textEditView.textSize = newValue
        }
        get {
            return textEditView.textSize
        }
    }
}

//MARK: -
//MARK: Gesture handler extension

extension TextDrawer: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        textEditView.textEntry = text
        textEditView.isEditing = true
        textEditView.isHidden = false
    }
    
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        switch recognizer.state {
        case .began, .ended, .failed, .cancelled:
            initialCenterDrawTextView = drawTextView.center
        case .changed:
            drawTextView.center = CGPoint(x: initialCenterDrawTextView.x + translation.x,
                y: initialCenterDrawTextView.y + translation.y)
        default: return
        }
    }
    
    func handlePinchGesture(_ recognizer: UIGestureRecognizer) {
        var transform = initialRotationTransform
        
        switch recognizer.state {
        case .began:
            if activieGestureRecognizer.count == 0 {
                initialRotationTransform = drawTextView.transform
            }
            activieGestureRecognizer.add(recognizer)
            break
            
        case .changed:
            for currentRecognizer in activieGestureRecognizer {
                transform = applyRecogniser(currentRecognizer as? UIGestureRecognizer, currentTransform: transform!)
            }
            drawTextView.transform = transform!
            break
            
        case .ended, .failed, .cancelled:
            initialRotationTransform = applyRecogniser(recognizer, currentTransform: initialRotationTransform)
            activieGestureRecognizer.remove(recognizer)
        default: return
        }

    }
    
    fileprivate func applyRecogniser(_ recognizer: UIGestureRecognizer?, currentTransform: CGAffineTransform) -> CGAffineTransform {
        if let recognizer = recognizer {
            if recognizer is UIRotationGestureRecognizer {
                return currentTransform.rotated(by: (recognizer as! UIRotationGestureRecognizer).rotation)
            }
            if recognizer is UIPinchGestureRecognizer {
                let scale = (recognizer as! UIPinchGestureRecognizer).scale
                return currentTransform.scaledBy(x: scale, y: scale)
            }
        }
        return currentTransform
    }
}

//MARK: -
//MARK: Render extension

public extension TextDrawer {
    
    public func render() -> UIImage? {
        return renderTextOnView(self)
    }
    
    public func renderTextOnView(_ view: UIView) -> UIImage? {        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return renderTextOnImage(img!)
    }
    
    public func renderTextOnImage(_ image: UIImage) -> UIImage? {
        let size = image.size
        let scale = size.width / self.bounds.width
        let color = layer.backgroundColor

        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        
        image.draw(in: CGRect(x: self.bounds.width / 2 - (image.size.width / scale) / 2,
            y: self.bounds.height / 2 - (image.size.height / scale) / 2,
            width: image.size.width / scale,
            height: image.size.height / scale))
        layer.backgroundColor = UIColor.clear.cgColor
        layer.render(in: UIGraphicsGetCurrentContext()!)
        layer.backgroundColor = color

        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return UIImage(cgImage: (drawnImage?.cgImage!)!, scale: 1, orientation: (drawnImage?.imageOrientation)!)
    }
}
