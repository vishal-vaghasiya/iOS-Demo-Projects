//
//  ResultVC.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 14/07/25.
//

import UIKit

class ResultVC: UIViewController {
    
    // MARK: - OUTLET
    
    // MARK: - PROPERTY
    var results: [(String, Float)] = []
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        //let treatments: [Treatment] = Bundle.main.decode([Treatment].self, from: "treatments.json")
        
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = results.map { "Condition: \($0.0)\nConfidence: \($0.1 * 100)%" }.joined(separator: "\n\n")
        
        /*
         label.text = """
                 Condition: \(result?.0 ?? "Unknown")
                 Confidence: \((result?.1 ?? 0) * 100)%
                 
                 Advice:
                 \(treatment?.advice.joined(separator: "\n• ") ?? "No treatment found.")
                 """
         */
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
