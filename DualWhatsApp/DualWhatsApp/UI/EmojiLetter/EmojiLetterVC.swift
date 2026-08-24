//
//  EmojiLetterVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 13/10/25.
//

import UIKit

class EmojiLetterVC: UIViewController, UITextFieldDelegate{

    // MARK: - OUTLET
    @IBOutlet weak var txtChar: UITextField!
    @IBOutlet weak var txtEmoji: UITextField!
    @IBOutlet weak var lblEmojiLetter: UILabel!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emoji Letter"
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    func setup() {
        txtEmoji.delegate = self
        txtChar.delegate = self
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickGenerate(_ sender: UIButton) {
        let emojiTxt = self.txtEmoji.text ?? ""
        let charTxt = self.txtChar.text ?? ""
        if emojiTxt != "" && charTxt != "" {
            self.emojiLatter(emoji: emojiTxt, latter: charTxt)
        }
    }
    
    // MARK: - OTHER
    
    func emojiLatter(emoji: String, latter: String) {
        let letter = latter.uppercased()
        
        self.lblEmojiLetter.numberOfLines = 0
        self.lblEmojiLetter.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        self.lblEmojiLetter.textAlignment = .left

        switch letter {
        case "A":
            self.lblEmojiLetter.textAlignment = .center
            self.lblEmojiLetter.text = "\(emoji)\n\n\(emoji)   \(emoji)\n\n\(emoji)       \(emoji)\n\n\(emoji)    \(emoji)    \(emoji)\n\n\(emoji)             \(emoji)\n\n\(emoji)                \(emoji)"
        case "B":
            self.lblEmojiLetter.text = "\(emoji)  \(emoji)\n\n\(emoji)      \(emoji)\n\n\(emoji)   \(emoji)\n\n\(emoji)      \(emoji)\n\n\(emoji)  \(emoji)"
        case "C":
            self.lblEmojiLetter.text = "   \(emoji)  \(emoji)\n\n \(emoji)\n\n\(emoji)\n\n \(emoji)\n\n   \(emoji)  \(emoji)"
        case "D":
            self.lblEmojiLetter.text = "\(emoji) \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji) \(emoji)"
        case "E":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "F":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji)"
        case "G":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji)      \(emoji) \(emoji)\n\n\(emoji)      \(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "H":
            self.lblEmojiLetter.text = "\(emoji)    \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji) \(emoji) \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji)    \(emoji)"
        case "I":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n   \(emoji)\n\n   \(emoji)\n\n   \(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "J":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n      \(emoji)\n\n      \(emoji)\n\n\(emoji)   \(emoji)\n\n\(emoji) \(emoji)"
        case "K":
            self.lblEmojiLetter.text = "\(emoji)    \(emoji)\n\n\(emoji)  \(emoji)\n\n\(emoji)\n\n\(emoji)  \(emoji)\n\n\(emoji)    \(emoji)"
        case "L":
            self.lblEmojiLetter.text = "\(emoji)\n\n\(emoji)\n\n\(emoji)\n\n\(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "M":
            self.lblEmojiLetter.text = "\(emoji)           \(emoji)\n\n\(emoji) \(emoji)     \(emoji) \(emoji)\n\n\(emoji)  \(emoji)   \(emoji)  \(emoji)\n\n\(emoji)   \(emoji) \(emoji)   \(emoji)\n\n\(emoji)     \(emoji)     \(emoji)"
        case "N":
            self.lblEmojiLetter.text = "\(emoji)        \(emoji)\n\n\(emoji) \(emoji)     \(emoji)\n\n\(emoji)   \(emoji)   \(emoji)\n\n\(emoji)     \(emoji) \(emoji)\n\n\(emoji)        \(emoji)"
        case "O":
            self.lblEmojiLetter.text = "      \(emoji)   \(emoji)\n\n   \(emoji)         \(emoji)\n\n\(emoji)               \(emoji)\n\n   \(emoji)         \(emoji)\n\n      \(emoji)   \(emoji)"
        case "P":
            self.lblEmojiLetter.text = "\(emoji) \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji) \(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji)"
        case "Q":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n\(emoji)     \(emoji)\n\n\(emoji)     \(emoji)\n\n\(emoji)   \(emoji) \(emoji)\n\n\(emoji) \(emoji) \(emoji)   \(emoji)"
        case "R":
            self.lblEmojiLetter.text = "\(emoji) \(emoji)\n\n\(emoji)    \(emoji)\n\n\(emoji) \(emoji) \(emoji)\n\n\(emoji)  \(emoji)\n\n\(emoji)    \(emoji)"
        case "S":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n\(emoji)\n\n\(emoji) \(emoji) \(emoji)\n\n      \(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "T":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n   \(emoji)\n\n   \(emoji)\n\n   \(emoji)\n\n   \(emoji)"
        case "U":
            self.lblEmojiLetter.text = "\(emoji)     \(emoji)\n\n\(emoji)     \(emoji)\n\n\(emoji)     \(emoji)\n\n\(emoji)     \(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        case "V":
            self.lblEmojiLetter.text = "\(emoji)        \(emoji)\n\n \(emoji)      \(emoji)\n\n  \(emoji)    \(emoji)\n\n   \(emoji)  \(emoji)\n\n     \(emoji)"
        case "W":
            self.lblEmojiLetter.text = "\(emoji)     \(emoji)     \(emoji)\n\n\(emoji)   \(emoji) \(emoji)   \(emoji)\n\n\(emoji)  \(emoji)   \(emoji)  \(emoji)\n\n\(emoji) \(emoji)     \(emoji) \(emoji)\n\n\(emoji)           \(emoji)"
        case "X":
            self.lblEmojiLetter.text = "\(emoji)     \(emoji)\n\n  \(emoji) \(emoji)\n\n    \(emoji)\n\n  \(emoji) \(emoji)\n\n\(emoji)     \(emoji)"
        case "Y":
            self.lblEmojiLetter.text = "\(emoji)      \(emoji)\n\n  \(emoji)  \(emoji)\n\n    \(emoji)\n\n    \(emoji)\n\n    \(emoji)"
        case "Z":
            self.lblEmojiLetter.text = "\(emoji) \(emoji) \(emoji)\n\n      \(emoji)\n\n    \(emoji)\n\n  \(emoji)\n\n\(emoji) \(emoji) \(emoji)"
        default:
            self.lblEmojiLetter.text = "❌ Invalid Letter"
        }
    }
    
//    func emojiLatter(emoji: String, latter: String) {
//        let size = 7
//        let letter = latter.uppercased()
//        
//        // Make sure label can show multiple lines and use a monospaced font for better alignment
//        self.lblEmojiLetter.numberOfLines = 0
//        self.lblEmojiLetter.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
//        self.lblEmojiLetter.textAlignment = .center
//        
//        var finalLines: [String] = []
//        
//        for i in 0..<size {
//            var line = ""
//            for j in 0..<size {
//                var placeEmoji = false
//                
//                switch letter {
//                case "A":
//                    // top, diagonals, and middle bar
//                    if i == 0 && j == 3 { placeEmoji = true }
//                    else if i > 0 && (j == 3 - i || j == 3 + i) { placeEmoji = true }
//                    else if i == 3 && j > 0 && j < 6 { placeEmoji = true }
//                    
//                case "B":
//                    if j == 0 { placeEmoji = true }
//                    else if (i == 0 || i == 3 || i == 6) && j < 5 { placeEmoji = true }
//                    else if j == 5 && (i != 0 && i != 3 && i != 6) { placeEmoji = true }
//                    
//                case "C":
//                    if j == 0 && i != 0 && i != 6 { placeEmoji = true }
//                    else if (i == 0 || i == 6) && j > 0 && j < 6 { placeEmoji = true }
//                    
//                case "D":
//                    if j == 0 { placeEmoji = true }
//                    else if j == 5 && i != 0 && i != 6 { placeEmoji = true }
//                    else if (i == 0 || i == 6) && j < 5 { placeEmoji = true }
//                    
//                case "E":
//                    if j == 0 { placeEmoji = true }
//                    else if i == 0 || i == 3 || i == 6 { placeEmoji = true }
//                    
//                case "F":
//                    if j == 0 { placeEmoji = true }
//                    else if i == 0 || i == 3 { placeEmoji = true }
//                    
//                case "G":
//                    if j == 0 && i != 0 && i != 6 { placeEmoji = true }
//                    else if (i == 0 || i == 6) && j > 0 && j < 6 { placeEmoji = true }
//                    else if i >= 3 && j == 5 { placeEmoji = true }
//                    else if i == 3 && j > 2 { placeEmoji = true }
//                    
//                case "H":
//                    if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == 3 { placeEmoji = true }
//                    
//                case "I":
//                    if i == 0 || i == 6 { placeEmoji = true } // full row
//                    else if j == 3 { placeEmoji = true }
//                    
//                case "J":
//                    if i == 0 { placeEmoji = true }
//                    else if j == 3 { placeEmoji = true }
//                    else if i == 6 && j < 3 { placeEmoji = true }
//                    
//                case "K":
//                    if j == 0 { placeEmoji = true }
//                    else if i + j == 3 { placeEmoji = true }
//                    else if i - j == 3 { placeEmoji = true }
//                    
//                case "L":
//                    if j == 0 { placeEmoji = true }
//                    else if i == 6 { placeEmoji = true }
//                    
//                case "M":
//                    if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == j && j <= 3 { placeEmoji = true }
//                    else if i + j == 6 && j >= 3 { placeEmoji = true }
//                    
//                case "N":
//                    if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == j { placeEmoji = true }
//                    
//                case "O":
//                    if i == 0 || i == 6 { placeEmoji = true }
//                    else if j == 0 || j == 6 { placeEmoji = true }
//                    
//                case "P":
//                    if j == 0 { placeEmoji = true }
//                    else if (i == 0 || i == 3) && j < 5 { placeEmoji = true }
//                    else if j == 4 && i < 3 { placeEmoji = true }
//                    
//                case "Q":
//                    if i == 0 || i == 5 { placeEmoji = true }
//                    else if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == 4 && j == 5 { placeEmoji = true }
//                    
//                case "R":
//                    if j == 0 { placeEmoji = true }
//                    else if (i == 0 || i == 3) && j < 5 { placeEmoji = true }
//                    else if j == 4 && i < 3 { placeEmoji = true }
//                    else if i - j == 0 && i > 3 { placeEmoji = true }
//                    
//                case "S":
//                    if i == 0 || i == 3 || i == 6 { placeEmoji = true }
//                    else if (i < 3 && j == 0) || (i > 3 && j == 4) { placeEmoji = true }
//                    
//                case "T":
//                    if i == 0 { placeEmoji = true }
//                    else if j == 3 { placeEmoji = true }
//                    
//                case "U":
//                    if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == 6 { placeEmoji = true }
//                    
//                case "V":
//                    if j == i && i < 4 { placeEmoji = true }
//                    else if j == 6 - i && i < 4 { placeEmoji = true }
//                    
//                case "W":
//                    if j == 0 || j == 6 { placeEmoji = true }
//                    else if i == 3 && (j == 2 || j == 4) { placeEmoji = true }
//                    
//                case "X":
//                    if i == j || i + j == 6 { placeEmoji = true }
//                    
//                case "Y":
//                    if i < 3 && (i == j || i + j == 6) { placeEmoji = true }
//                    else if i >= 3 && j == 3 { placeEmoji = true }
//                    
//                case "Z":
//                    if i == 0 || i == 6 { placeEmoji = true }
//                    else if j == 6 - i { placeEmoji = true }
//                    
//                default:
//                    placeEmoji = false
//                }
//                
//                // Append emoji or a placeholder space.
//                // Use one space for empty cell; emoji where needed.
//                line += placeEmoji ? emoji : " "
//            }
//            finalLines.append(line)
//        }
//        
//        // Join lines with newline and set to label
//        self.lblEmojiLetter.text = finalLines.joined(separator: "\n")
//    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtEmoji {
            // Allow deleting text
            if string.isEmpty { return true }
            // Get the new text if this change is applied
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Allow only 1 character
            if updatedText.count > 1 {
                return false
            }
            // Only allow emojis
            return string.isOnlyEmojis
        }
        
        if textField == self.txtChar {
            // Allow deleting text
            if string.isEmpty { return true }
            // Get the current text and proposed new text
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            // Allow only 1 character
            if updatedText.count > 1 {
                return false
            }
            // Convert to uppercase
            textField.text = updatedText.uppercased()
            // Prevent the system from adding the original input (we already set the uppercase)
            return false
        }
        return true
    }
}
