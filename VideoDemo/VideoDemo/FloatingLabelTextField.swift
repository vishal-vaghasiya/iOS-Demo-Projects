import UIKit

@IBDesignable
class OutlinedFloatingTextField: UITextField {
    
    private let floatingLabel = UILabel()
    
    @IBInspectable var inactiveBorderColor: UIColor = .lightGray
    @IBInspectable var activeBorderColor: UIColor = .systemBlue
    @IBInspectable var floatingLabelColor: UIColor = .systemBlue
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var horizontalPadding: CGFloat = 8
    @IBInspectable var verticalSpacing: CGFloat = 2   // 👈 Gap between label & border
    
    private var isLabelFloated = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1
        layer.borderColor = inactiveBorderColor.cgColor
        clipsToBounds = false
        
        floatingLabel.textColor = inactiveBorderColor
        floatingLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        floatingLabel.alpha = 0
        addSubview(floatingLabel)
        
        addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let placeholder = placeholder, floatingLabel.text == nil {
            floatingLabel.text = placeholder
            floatingLabel.sizeToFit()
        }
        
        if !isLabelFloated {
            floatingLabel.frame = CGRect(
                x: horizontalPadding,
                y: bounds.height/2 - 8,
                width: bounds.width - 2 * horizontalPadding,
                height: 16
            )
        }
    }
    
    @objc private func editingBegan() {
        layer.borderColor = activeBorderColor.cgColor
        floatLabel()
    }
    
    @objc private func editingEnded() {
        layer.borderColor = inactiveBorderColor.cgColor
        if let text = text, text.isEmpty {
            resetLabel()
        }
    }
    
    private func floatLabel() {
        guard !isLabelFloated else { return }
        isLabelFloated = true
        UIView.animate(withDuration: 0.25) {
            self.floatingLabel.alpha = 1
            self.floatingLabel.textColor = self.floatingLabelColor
            self.floatingLabel.frame.origin = CGPoint(
                x: self.horizontalPadding,
                y: -self.floatingLabel.frame.height - self.verticalSpacing // 👈 Outside the border
            )
        }
        attributedPlaceholder = nil
    }
    
    private func resetLabel() {
        guard isLabelFloated else { return }
        isLabelFloated = false
        UIView.animate(withDuration: 0.25) {
            self.floatingLabel.alpha = 0
            self.floatingLabel.transform = .identity
            self.floatingLabel.frame.origin = CGPoint(
                x: self.horizontalPadding,
                y: self.bounds.height/2 - 8
            )
        }
    }
    
    // Add padding for text inside the field
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 8, left: horizontalPadding, bottom: 8, right: horizontalPadding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
