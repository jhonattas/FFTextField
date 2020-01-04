//
//  FFTextField.swift
//  FFTextField
//
//  Created by Felipe Figueiredo on 2/13/18.
//  Copyright © 2018 Felipe. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import SwiftMaskTextfield

/// TextField class that makes the composition of some common functions used by apps.
/// ## Mask:
/// The mask property allows for the insertion of a pattern mask for the textField.
/// Refer to the Library SwiftMaskTextField for more details on how to construct the masks.
/// ## Indicator:

/// Allows for the insertion of an image indicator on the right of the textfield.
/// Intended to use together with picker views.
/// ## Right Button:
/// Allows for the insertion of a Button on the right side of the textField.
/// The text will not pass under the button, clipping before it begins.
/// The action that will be called when the button is tapped should be defined on the
/// Property rightbuttoncompletionBlock property.

open class FFTextField: SkyFloatingLabelTextField {
    
    public var indicatorView: UIImageView
    public var rightMargin: CGFloat = 20
    public var leftMargin: CGFloat = 0
    public var topMargin: CGFloat = 0
    public var bottomMargin: CGFloat = 0
    
    private var rectWidthModificator: CGFloat { return rightMargin + leftMargin }
    private var rectHeightModificator: CGFloat { return topMargin + bottomMargin }
    
    public override init(frame: CGRect) {
        maskTextField = SwiftMaskTextField()
        indicatorView = UIImageView()
        activityIndicator = UIActivityIndicatorView()
        super.init(frame: frame)
        configureSubviews()
        setupMaskConfigs()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        maskTextField = SwiftMaskTextField()
        indicatorView = UIImageView()
        activityIndicator = UIActivityIndicatorView()
        super.init(coder: aDecoder)
        configureSubviews()
        setupMaskConfigs()
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        rect.size.width -= rectWidthModificator
        rect.origin.y = rect.origin.y + topMargin - 4
        rect.origin.x = bounds.origin.x + 10 + leftMargin
        return rect
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.size.width -= rectWidthModificator
        
        rect.origin.y = rect.origin.y + topMargin - 4
        
        rect.origin.x = bounds.origin.x + 10 + leftMargin
        return rect
    }
    
    open override func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        var rect = super.titleLabelRectForBounds(bounds, editing: editing)
        rect.size.width -= rectWidthModificator
        rect.origin.y = rect.origin.y + topMargin + 4
        rect.origin.x = bounds.origin.x + 10 + leftMargin
        return rect
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.size.width -= rectWidthModificator
        rect.origin.y = rect.origin.y + topMargin - 4
        rect.origin.x = bounds.origin.x + 10 + leftMargin
        return rect
    }
    
    private func configureSubviews() {
        indicatorView.contentMode = .scaleAspectFit
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf:[
            indicatorView.rightAnchor.constraint(equalTo: indicatorView.superview!.rightAnchor,
                                                 constant: -20),
            indicatorView.centerYAnchor.constraint(equalTo: indicatorView.superview!.centerYAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 17),
            indicatorView.widthAnchor.constraint(equalToConstant: 17)])
        constraints.forEach({$0.isActive = true})
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.1)
        constraint.priority = .defaultHigh
        constraint.isActive = true
    }
    
    private func configureButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rightAnchor.constraint(equalTo: button.superview!.rightAnchor,
                                      constant: -10)
        button.bottomAnchor.constraint(equalTo: button.superview!.bottomAnchor,
                                       constant: -0.02 * UIScreen.main.bounds.height)
        button.sizeToFit()
        let width = button.frame.width
        rightMargin = 10 + width + 8
    }
    
    @objc func didTapRightButton() {
        rightButtonCompletionBlock?()
    }
    
    // MARK: - Public API
    
    public var rightButtonCompletionBlock: (() -> Void)?
    
    public func addRightButton(title: String, completion: @escaping () -> Void) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        rightButtonCompletionBlock = completion
        configureButton(button)
    }
    
    public func addRightButton(image: UIImage, completion: @escaping () -> Void) {
        rightButtonCompletionBlock = completion
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        configureButton(button)
    }
    
    public var activityIndicator: UIActivityIndicatorView
    
    private var lastIndicatorImage: UIImage?
    public func startActivityIndicator() {
        activityIndicator.bounds = indicatorView.bounds
        activityIndicator.frame = indicatorView.bounds
        indicatorView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        lastIndicatorImage = indicatorView.image
        indicatorView.image = nil
    }
    
    public func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        indicatorView.image = lastIndicatorImage
    }
    
    // MARK: - Swift Mask Configuration
    
    private var maskTextField: SwiftMaskTextField
    
    public var formatPattern: String? = nil {
        didSet {
            maskTextField.formatPattern = formatPattern ?? ""
        }
    }
    
    open override var text: String? {
        set {
            if formatPattern != nil {
                maskTextField.text = newValue
                maskTextField.formatText()
                super.text = maskTextField.text
            } else {
                super.text = newValue
            }
        } get {
            return super.text
        }
    }
    
    fileprivate func setupMaskConfigs() {
        self.registerForNotifications()
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSNotification.Name(
                rawValue: "UITextFieldTextDidChangeNotification"),
            object: self)
    }
    
    @objc fileprivate func textDidChange() {
        errorMessage = ""
        self.undoManager?.removeAllActions()
        text = super.text
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

