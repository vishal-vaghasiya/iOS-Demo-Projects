//
//  ViewController.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickWhatsapp(_ sender: UIButton) {
        let vc = StoryboardScene.WebWhatsApp.webWhatsappVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickDirectChat(_ sender: UIButton) {
        let vc = StoryboardScene.DirectChat.directChatVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func clickSticker(_ sender: UIButton) {
        let vc = StoryboardScene.WASticker.stickerPackVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickPrivateBrowser(_ sender: UIButton) {
        let vc = StoryboardScene.PrivateBrowser.privateBrowserVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickRepeatText(_ sender: UIButton) {
        let vc = StoryboardScene.RepeatText.repeatTextVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickPrivateNote(_ sender: UIButton) {
        let vc = StoryboardScene.PrivateNotes.privateNotesVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func clickFancyFonts(_ sender: UIButton) {
        let vc = StoryboardScene.FancyFonts.fancyFontsVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickStatusQuotes(_ sender: UIButton) {
        let vc = StoryboardScene.Quotes.quotesVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickSpeechToText(_ sender: UIButton) {
        let vc = StoryboardScene.SpeechToText.speechToTextVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickEmojiLetter(_ sender: UIButton) {
        let vc = StoryboardScene.EmojiLetterVC.emojiLetterVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickBackground(_ sender: UIButton) {
        let vc = StoryboardScene.ChatBackground.chatBackgroundTabbarVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickPhotoVault(_ sender: UIButton) {
        let vc = StoryboardScene.PhotoVault.photoVaultVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickWhatsCropping(_ sender: UIButton) {
        let vc = StoryboardScene.WhatsCropping.whatsCroppingVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickCameraScan(_ sender: UIButton) {
        let vc = StoryboardScene.CameraScan.cameraScanerVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
