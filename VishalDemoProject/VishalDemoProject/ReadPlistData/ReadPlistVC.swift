//
//  ReadPlistVC.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 30/07/25.
//

import UIKit

class ReadPlistVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let apiURL = SecureConfigManager.shared.value(forKey: "API_BASE_URL")
        print("🔗 API URL: \(apiURL ?? "Missing")")

        let firebaseKey = SecureConfigManager.shared.value(forKey: "FIREBASE_API_KEY")
        print("🌐 Firebase API Key → \(firebaseKey ?? "Not found")")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
