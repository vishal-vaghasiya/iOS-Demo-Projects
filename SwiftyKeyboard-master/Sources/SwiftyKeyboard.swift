//
//  SwiftyKeyboard.swift
//  SwiftyKeyboard
//
//  Created by SwiftyKit on 1/10/22.
//  Copyright © 2021 SwiftyKit. All rights reserved.
//

import UIKit

// check only one decimal point
// keyInput how to set when textField is become first responder

/// A simple keyboard to use with numbers and, optionally, a decimal point.
@available(iOS 9.0, *)
@objcMembers public class SwiftyKeyboard: UIInputView, UIInputViewAudioFeedback {

    // MARK: - UIInputViewAudioFeedback
    private var enableInputClicksWhenVisible: Bool = true

    // MARK: - Constants
    private let keyboardRows                = 4
    private let keyboardColumns             = 4
    private let rowHeight: CGFloat          = 55.0
    private let keyboardPadBorder: CGFloat  = 7.0
    private let keyboardPadSpacing: CGFloat = 8.0

    // MARK: - Public Properties
    /// The receiver key input object. If nil the object at top of the responder chain is used.
    public weak var keyInput: UIKeyInput?

    /// Delegate to change text insertion or return key behavior.
    public weak var delegate: SwiftyKeyboardDelegate?

    private var _allowsDecimalPoint = false {
        didSet {
            // configurate zero number
            self.setNeedsLayout()
        }
    }

    /**
     If true, the decimal separator key will be displayed.
     - note: The default value of this property is **false**.
     */
    public var allowsSpecialKey: Bool {
        get {
            return _allowsSpecialKey
        }
        set {
            guard _allowsSpecialKey != newValue else { return }
            _allowsSpecialKey = newValue
        }
    }

    private var _allowsSpecialKey = false {
        didSet {
            // configurate zero number
            self.setNeedsLayout()
        }
    }

    /**
     If true, the decimal separator key will be displayed.
     - note: The default value of this property is **false**.
     */
    public var allowsDecimalPoint: Bool {
        get {
            return _allowsDecimalPoint
        }
        set {
            guard _allowsDecimalPoint != newValue else { return }
            _allowsDecimalPoint = newValue
        }
    }

    // UIKitLocalizedString(@"Done")
    private lazy var _returnKeyTitle: String = "Done"

    /**
     The visible title of the Return key.
     - note: The default visible title of the Return key is "**Done**".
     */
    public var returnKeyTitle: String {
        get {
            return _returnKeyTitle
        }
        set {
            guard _returnKeyTitle != newValue else { return }
            _returnKeyTitle = newValue

            guard let button = self.buttons[NumberKeyboardButtonType.done.rawValue] else { return }
            button.setTitle(_returnKeyTitle, for: .normal)
        }
    }


    /**
     The button style of the Return key.
     - note: The default value of this property is **NumberKeyboardButtonStyleDone**.
     */
    public var returnKeyButtonStyle: NumberKeyboardButtonStyle = .done


    // MARK: - Private Properties
    lazy private(set) var locale = Locale.current

    private lazy var buttons : [Int: UIButton] = {
        let buttonFont = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light)
        let doneButtonFont = UIFont.systemFont(ofSize: 17.0)

        var buttons = [Int: UIButton]()

        let numberMin = NumberKeyboardButtonType.numberMin.rawValue
        let numberMax = NumberKeyboardButtonType.numberMax.rawValue
        for key in numberMin...numberMax {
            let button = SwiftyKeyboardButton(numberKey: String(key), font: buttonFont, target: self, action: #selector(tapKeyNumber(button:)))
            buttons[key] = button
        }

        let backspaceImage = SwiftyKeyboard.keyboardImageNamed("numberKeyboard_delete")?.withRenderingMode(.alwaysTemplate)

        let backspaceButton = SwiftyKeyboardButton(bgImage: backspaceImage, target: self, action: #selector(tapBackspaceKey(button:)))
        backspaceButton.addTarget(self, action: #selector(tapBackspaceRepeat(button:)), forContinuousPress: 0.15)
        buttons[NumberKeyboardButtonType.backspace.rawValue] = backspaceButton

        let dismissImage = SwiftyKeyboard.keyboardImageNamed("numberKeyboard_dismiss")?.withRenderingMode(.alwaysTemplate)
        let specialButton = SwiftyKeyboardButton(bgImage: dismissImage, target: self, action: #selector(tapSpecialKey(button:)))
        buttons[NumberKeyboardButtonType.special.rawValue] = specialButton


        let doneButton = SwiftyKeyboardButton(bgImage: dismissImage, target: self, action: #selector(tapDoneKey(button:)))
        buttons[NumberKeyboardButtonType.done.rawValue] = doneButton

        let decimalPointButton = SwiftyKeyboardButton(decimalPoint: ".", font: buttonFont, target: self, action: #selector(tapDecimalPointKey(button:)))
        buttons[NumberKeyboardButtonType.decimalPoint.rawValue] = decimalPointButton

        for (_, button) in buttons {
            button.isExclusiveTouch = true
            button.addTarget(self, action: #selector(playClick(button:)), for: .touchDown)
        }

        return buttons
    }()

    /// Initialize an array for the separators.
    private lazy var separatorViews : [UIView] = {
        var separatorViews = [UIView]()
        var numberOfSeparators = self.keyboardColumns + self.keyboardRows - 1

        for index in 0..<numberOfSeparators {
            let separator = UIView(frame: CGRect.zero)
            separatorViews.append(separator)
        }

        return separatorViews
    }()

    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
        Initializes and returns a number keyboard view using the specified style information and locale.
     
        An initialized view object or nil if the view could not be initialized.
        - parameters:
            - frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
            - inputViewStyle: The style to use when altering the appearance of the view and its subviews. For a list of possible values, see **UIInputViewStyle**
            - locale: An **Locale** object that specifies options (specifically the **LocaleDecimalSeparator**) used for the keyboard. Specify nil if you want to use the current locale.

     */
    convenience init(frame: CGRect, inputViewStyle: UIInputView.Style, locale: Locale) {
        self.init(frame: frame, inputViewStyle: inputViewStyle)
        self.locale = locale
    }

    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        self.initialSetup()
    }

    // MARK: - Accessing keyboard images.
    private class func keyboardImageNamed(_ imageName: String) -> UIImage? {
        let imageExtension = "png"

        var image : UIImage?
        let bundle = Bundle(for: SwiftyKeyboard.self)
        if let imagePath = bundle.path(forResource: imageName, ofType: imageExtension) {
            image = UIImage(contentsOfFile: imagePath)
        }
        else {
            image = UIImage(named: imageName)
        }

        return image
    }

    func initialSetup() {

        for (_, button) in self.buttons {
            self.addSubview(button)
        }

        if UI_USER_INTERFACE_IDIOM() == .phone {
            for separatorView in self.separatorViews {
                self.addSubview(separatorView)
            }
        }

        let highlightGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHighlight(gestureRecognizer:)))
        self.addGestureRecognizer(highlightGestureRecognizer)

        // Size to fit.
        self.sizeToFit()
    }

    // MARK: -
    /**
        Configures the special key with an image and an action block.
        - parameters:
            - image: The image to display in the key.
            - handler: A handler block.
     */
    func configureSpecialKey(image: UIImage?, actionHandler handler: ()->()) {
//        if (image) {
//            self.specialKeyHandler = handler
//        } else {
//            self.specialKeyHandler = NULL
//        }

        guard let button = self.buttons[NumberKeyboardButtonType.special.rawValue] else { return }
        button.setImage(image, for: .normal)
    }

    // MARK: - Handle pan gesture
    func handleHighlight(gestureRecognizer : UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)

        guard gestureRecognizer.state == .changed || gestureRecognizer.state == .ended else { return }

        for (_, button) in self.buttons {
            let points = button.frame.contains(point) && !button.isHidden

            if gestureRecognizer.state == .changed {
                button.isHighlighted = points
            }
            else {
                button.isHighlighted = false
            }

            if gestureRecognizer.state == .ended && points {
                button.sendActions(for: .touchUpInside)
            }
        }
    }

    // MARK: - Handle Actions
    func playClick(button: SwiftyKeyboardButton) {
        UIDevice.current.playInputClick()
    }

    func tapKeyNumber(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard let title = button.title(for: .normal) else { return }

        // Handle number.
        if shouldChangeCharacter(for: title) {
            keyInput.insertText(title)
        }
    }

    func tapSpecialKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }
        // 🔔 Notify delegate when Save button tapped
        self.delegate?.numberKeyboardDidPressSave?(self)
    }

    func tapDecimalPointKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard let decimalText = button.title(for: .normal) else { return }

        // Handle decimal point.
        if shouldChangeCharacter(for: decimalText) {
            keyInput.insertText(decimalText)
        }
    }

    func tapBackspaceKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }

        // Handle backspace.
        if let shouldDeleteBackward = self.delegate?.numberKeyboardShouldDeleteBackward?(self) {
            guard shouldDeleteBackward == true else { return }
        }

        keyInput.deleteBackward()
    }

    func tapDoneKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Handle done.
        if let shouldReturn = self.delegate?.numberKeyboardShouldReturn?(self) {
            guard shouldReturn == true else { return }
        }

        self.dismissKeyboard()
    }

    func tapBackspaceRepeat(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard keyInput.hasText else { return }

        self.playClick(button: button)
        self.tapBackspaceKey(button: button)
    }

    private func shouldChangeCharacter(for text: String) -> Bool {
        guard let keyInput = self.keyInput else { return false}
        if let shouldInsert = self.delegate?.numberKeyboard?(self, shouldInsertText: text), shouldInsert == true{
            return true
        }

        if keyInput.isKind(of: UITextField.self), let textField = keyInput as? UITextField {
            //let range = NSRange(location: textField.selectedTextRange?.start ?? UITextPosition, length: 1)
            if let selectedRange = textField.selectedRange {
                let shouldInsert = textField.delegate?.textField?(textField, shouldChangeCharactersIn: selectedRange, replacementString: text) ?? true
                return shouldInsert
            }
        }

        return false
    }

    // MARK: -
    func dismissKeyboard() {
       //guard let keyInput = self.keyInput as? UIResponder else { return }
       //keyInput.resignFirstResponder()
    }

    // MARK: - Layout
    @inline(__always) func convertButtonRect(rect: CGRect, contentOrigin: CGPoint, interfaceIdiom: UIUserInterfaceIdiom) -> CGRect {
        var newRect = rect.offsetBy(dx: contentOrigin.x, dy: contentOrigin.y)

        if interfaceIdiom == .pad {
            let inset : CGFloat = self.keyboardPadSpacing / 2.0
            newRect = newRect.insetBy(dx: inset, dy: inset)
        }

        return newRect
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Make the keyboard background white with rounded corners
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        self.clipsToBounds = true
        
        // ... keep your existing layout code ...

        let bounds = self.bounds
        let spacing: CGFloat = 8.0

        let contentRect = CGRect(x: spacing,
                                 y: spacing,
                                 width: bounds.width - spacing * 2,
                                 height: bounds.height - spacing * 2)

        let columnWidth = contentRect.width / 3.0
        let rowHeight: CGFloat = self.rowHeight
        let numberSize = CGSize(width: columnWidth, height: rowHeight)

        let buttons = self.buttons

        // Layout numbers 1–9 in 3x3 grid (rows 0–2, cols 0–2)
        let numberMin = NumberKeyboardButtonType.numberMin.rawValue
        let numberMax = NumberKeyboardButtonType.numberMax.rawValue
        for key in numberMin...numberMax {
            guard let button = buttons[key] else { continue }
            let digit = key
            if digit >= 1 && digit <= 9 {
                let row = (digit - 1) / 3
                let col = (digit - 1) % 3
                let rect = CGRect(x: contentRect.minX + CGFloat(col) * numberSize.width,
                                  y: contentRect.minY + CGFloat(row) * numberSize.height,
                                  width: numberSize.width,
                                  height: numberSize.height)
                button.frame = rect
            }
            // Disable default highlight effect for number buttons
            button.adjustsImageWhenHighlighted = false
            button.showsTouchWhenHighlighted = false
        }

        // Layout "." at bottom-left (row 3, col 0)
        if let decimal = buttons[NumberKeyboardButtonType.decimalPoint.rawValue] {
            decimal.frame = CGRect(x: contentRect.minX,
                                   y: contentRect.minY + numberSize.height * 3,
                                   width: numberSize.width,
                                   height: numberSize.height)
            // Disable default highlight effect for decimal button
            decimal.adjustsImageWhenHighlighted = false
            decimal.showsTouchWhenHighlighted = false
        }

        // Layout "0" at bottom-middle (row 3, col 1)
        if let zero = buttons[0] {
            zero.frame = CGRect(x: contentRect.minX + numberSize.width,
                                y: contentRect.minY + numberSize.height * 3,
                                width: numberSize.width,
                                height: numberSize.height)
            // Disable default highlight effect for zero button
            zero.adjustsImageWhenHighlighted = false
            zero.showsTouchWhenHighlighted = false
        }

        // Layout Backspace at bottom-right (row 3, col 2), make it smaller and visually distinct
        if let backspace = buttons[NumberKeyboardButtonType.backspace.rawValue] {
            let smallWidth = numberSize.width * 0.7
            let smallHeight = numberSize.height * 0.7
            backspace.frame = CGRect(
                x: contentRect.minX + numberSize.width * 2 + (numberSize.width - smallWidth) / 2,
                y: contentRect.minY + numberSize.height * 3 + (numberSize.height - smallHeight) / 2,
                width: smallWidth,
                height: smallHeight
            )
            backspace.backgroundColor = .white
            backspace.tintColor = .black
            backspace.layer.cornerRadius = 8
            backspace.imageView?.contentMode = .scaleAspectFit
            backspace.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            // Disable default highlight effect for backspace button
            backspace.adjustsImageWhenHighlighted = false
            backspace.showsTouchWhenHighlighted = false
        }

        // Layout Save button at row 4, spanning 75% of columns, centered horizontally, just below keypad, height 50
        if let saveButton = buttons[NumberKeyboardButtonType.special.rawValue] {
            let saveHeight: CGFloat = 54.0
            let saveWidth = contentRect.width * 0.75
            saveButton.frame = CGRect(x: contentRect.midX - saveWidth / 2,
                                      y: contentRect.minY + numberSize.height * 4 + spacing,
                                      width: saveWidth,
                                      height: saveHeight)
            saveButton.layer.cornerRadius = 27
            saveButton.backgroundColor = .systemIndigo
            saveButton.setTitle("Save", for: .normal)
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
            saveButton.setImage(nil, for: .normal)
            saveButton.contentHorizontalAlignment = .center
            saveButton.isHidden = false
            // Disable default highlight effect for save button
            saveButton.adjustsImageWhenHighlighted = false
            saveButton.showsTouchWhenHighlighted = false
        }
    }

    func layoutSeparators(separators: [UIView], contentRect: CGRect, columnWidth: CGFloat) {
        var scale : CGFloat = 1.0
        if let window = self.window {
            scale = window.screen.scale
        }
        let separatorDimension : CGFloat = 1.0 / scale

        let totalRows = self.keyboardRows

        for (index, separator) in separators.enumerated() {
            var rect = CGRect.zero

            if index < totalRows {
                rect.origin.y = CGFloat(index) * rowHeight

                if index % 2 == 1 {
                    // to not cross backspace and done buttons
                    rect.size.width = contentRect.width - CGFloat(columnWidth)
                }
                else {
                    rect.size.width = contentRect.width
                }

                rect.size.height = separatorDimension
            }
            else {
                let columnIndex = index - totalRows

                rect.origin.x = CGFloat(columnIndex + 1) * columnWidth
                rect.size.width = separatorDimension

                if columnIndex == 1, !self.allowsDecimalPoint {
                    rect.size.height = contentRect.height - rowHeight
                }
                else if columnIndex == 0, !self.allowsSpecialKey {
                    rect.size.height = contentRect.height - rowHeight
                }
                else {
                    rect.size.height = contentRect.height
                }
            }

            separator.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: .phone)
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let interfaceIdiom = UI_USER_INTERFACE_IDIOM()
        let spacing = (interfaceIdiom == .pad) ? self.keyboardPadBorder : 0.0

        var newSize = size
        let saveButtonHeight: CGFloat = 80.0
        newSize.height = self.rowHeight * 4 + saveButtonHeight + spacing * 4.0
        if #available(iOS 11.0, *) {
            newSize.height += UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }

        if (newSize.width == 0.0) {
            newSize.width = UIScreen.main.bounds.size.width
        }

        return newSize
    }
}


extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
