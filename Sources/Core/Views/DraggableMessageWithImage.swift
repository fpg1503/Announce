//
//  DraggableMessageWithImage.swift
//  Announce
//
//  Created by Francesco Perrotti-Garcia on 6/13/17.
//  Copyright © 2017 Announce. All rights reserved.
//

import Foundation
import UIKit

public final class DraggableMessageWithImage: UIView, DraggableAnnouncement, TappableAnnouncement {
    public let message: String
    public let title: String
    public let image: UIImage?
    public let appearance: DraggableMessageWithImageAppearance
    
    weak var draggableAnnouncementDelegate: DraggableAnnouncementDelegate?
    
    public init(title: String,
                message: String,
                image: UIImage? = nil,
                appearance: DraggableMessageWithImageAppearance? = nil,
                tapHandler: ((DraggableMessageWithImage) -> Void)? = nil) {
        
        self.message = message
        self.title = title
        self.image = image
        self.appearance = appearance ?? DraggableMessageWithImageAppearance.defaultAppearance()
        self.tapHandler = tapHandler
        
        super.init(frame: .zero)
        
        self.layout()
        self.bindValues()
        self.addGestureRecognizers()
    }
    
    public convenience init(title: String,
                            message: String,
                            image: UIImage? = nil,
                            theme: Theme,
                            tapHandler: ((DraggableMessageWithImage) -> Void)? = nil) {
        
        self.init(title: title,
                  message: message,
                  image: image,
                  appearance: theme.appearanceForDraggableMessageWithImage(),
                  tapHandler: tapHandler)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    // MARK: - Gesture Recognizers
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap))
    }()
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        return UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    }()
    
    public var tapHandler: ((DraggableMessageWithImage) -> Void)?
    @objc private func handleTap() {
        tapHandler?(self)
    }
    
    private func addGestureRecognizers() {
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Layout
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.foregroundColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        
        label.font = self.appearance.messageFont
        label.textColor = self.appearance.foregroundColor
        
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public private (set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = self.appearance.imageContentMode
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        imageView.backgroundColor = .lightGray
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = self.appearance.imageCornerRadius
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var dragIndicator: UIView = {
        let dragIndicator = UIView()
        
        dragIndicator.backgroundColor = self.appearance.dragIndicatorColor
        
        dragIndicator.layer.masksToBounds = true
        dragIndicator.layer.cornerRadius = self.appearance.imageCornerRadius
        
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return dragIndicator
    }()
    
    private func layout() {
        self.backgroundColor = appearance.backgroundColor
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(imageView)
        addSubview(dragIndicator)
        
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        layoutTitle()
        layoutImage()
        layoutMessage()
        layoutDragIndicator()
        layoutHeightLimiter()
    }
    
    private func layoutImage() {
        let leadingConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 8.0
        )
        
        let topConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 8.0
        )
        
        let bottomConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .bottom,
            relatedBy: .lessThanOrEqual,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -8.0
        )
        
        let widthConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: self.appearance.imageSize.width
        )
        
        let heightConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: self.appearance.imageSize.height
        )
        
        leadingConstraint.isActive = true
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        widthConstraint.isActive = true
        heightConstraint.isActive = true
    }
    
    private func layoutTitle() {
        let topConstraint = NSLayoutConstraint(
            item: titleLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 8.0
        )
        
        let leadingConstraint = NSLayoutConstraint(
            item: titleLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 8.0
        )
        
        let trailingConstraint = NSLayoutConstraint(
            item: titleLabel,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: -8.0
        )
        
        let bottomConstraint = NSLayoutConstraint(
            item: titleLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: messageLabel,
            attribute: .top,
            multiplier: 1.0,
            constant: -5.0
        )
        
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        bottomConstraint.isActive = true
    }
    
    private func layoutMessage() {
        let leadingConstraint = NSLayoutConstraint(
            item: messageLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: titleLabel,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let trailingConstraint = NSLayoutConstraint(
            item: messageLabel,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: titleLabel,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let bottomConstraint = NSLayoutConstraint(
            item: messageLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: dragIndicator,
            attribute: .top,
            multiplier: 1.0,
            constant: -8.0
        )
        
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        bottomConstraint.isActive = true
    }
    
    private func layoutDragIndicator() {
        
        let heightConstraint = NSLayoutConstraint(
            item: dragIndicator,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: self.appearance.dragIndicatorSize.height)
        
        let widthConstraint = NSLayoutConstraint(
            item: dragIndicator,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: self.appearance.dragIndicatorSize.width)
        
        let centerHorizontallyConstraint = NSLayoutConstraint(
            item: dragIndicator,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let bottomConstraint = NSLayoutConstraint(
            item: dragIndicator,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -8.0
        )
        
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        centerHorizontallyConstraint.isActive = true
        bottomConstraint.isActive = true
    }
    
    private var heightLimiter: NSLayoutConstraint?
    
    private func layoutHeightLimiter() {
        let heightLimiter = NSLayoutConstraint(item: self,
                                               attribute: .height,
                                               relatedBy: .lessThanOrEqual,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1.0,
                                               constant: internalHeight)
        heightLimiter.isActive = true
        heightLimiter.priority = .required
        
        self.heightLimiter = heightLimiter
    }
    
    // MARK: - Value binding
    
    private func bindValues() {
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = image
    }
    
    // MARK - Pan gesture handling
    
    private var panGestureActive: Bool = false
    private var internalHeight: CGFloat = 64
    private let touchOffset: CGFloat = 44
    private let translateSpeedUp: CGFloat = 1.4
    
    
    private var currentHeight: CGFloat {
        get {
            return heightLimiter?.constant ?? 0
        }
        set {
            heightLimiter?.constant = newValue
        }
    }
    
    private var startHeight: CGFloat = 0
    @objc private func handlePan() {
        let translation = panGestureRecognizer.translation(in: self).y
        print("pan: \(translation)")
        
        if panGestureRecognizer.state == .began {
            currentHeight = self.bounds.height
            startHeight = currentHeight
        } else if panGestureRecognizer.state == .changed {
            panGestureActive = true
            
            let newHeight = startHeight + translation
            print("new: \(newHeight)")
            if newHeight > internalHeight {
                currentHeight = newHeight
                self.transform = .identity
            } else {
                currentHeight = internalHeight
                let amplifiedTranslation = -(internalHeight - newHeight) * translateSpeedUp
                if amplifiedTranslation > -internalHeight {
                    self.transform = CGAffineTransform(translationX: 0, y: amplifiedTranslation)
                } else {
                    self.transform = .identity
                    //dismiss
                    print("bye bye")
                }
            }
        } else {
            //TODO: Handle drags
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            draggableAnnouncementDelegate?.boundsDidUpdate(bounds)
        }
    }
}
