//
//  PlaceholderTextView.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import Foundation
import UIKit
class PlaceholderTextView: UITextView {

    // Placeholder text property
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            setNeedsLayout()
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = self.font
        return label
    }()

    // Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(placeholderLabel)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = CGRect(x: 5, y: textContainerInset.top, width: frame.width - 10, height: 0)
        placeholderLabel.sizeToFit()
        updatePlaceholderVisibility()
    }

    // Update visibility of the placeholder
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    // Handle text change
    @objc private func textDidChange() {
        updatePlaceholderVisibility()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
