//
//  MainMenuVC.swift
//  myFirstXIBProject
//
//  Created by Nexios02 on 09/01/23.
//

import UIKit

class MainMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func nextClick(_ sender: UIButton) {
        let vc = SecondViewController.init(nibName: "SecondViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
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
