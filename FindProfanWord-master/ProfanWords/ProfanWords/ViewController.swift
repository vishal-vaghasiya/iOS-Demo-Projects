//
//  ViewController.swift
//  ProfanWords
//
//  Created by admin on 10/01/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    var listProfanWords:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let file = Bundle.main.path(forResource: "Profanity", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: file!))
        listProfanWords = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func checkProfanWords(_ sender: UITextField) {
        print(sender.text!)
        print(containsSwearWord(text: sender.text!, swearWords: listProfanWords))
    }
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        return swearWords
            .reduce(false) { $0 || text.contains($1.lowercased()) }
    }
}

