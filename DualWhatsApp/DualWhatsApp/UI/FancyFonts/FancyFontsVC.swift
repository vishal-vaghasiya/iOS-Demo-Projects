//
//  FancyFontsVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 10/10/25.
//

import UIKit

class FancyFontsVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var txtText: UITextField!
    @IBOutlet weak var tblFont: UITableView!
    
    // MARK: - PROPERTY
    var defualtText: String = "Your Text"
    var showText: String = ""
    var fancyList: [String] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    
    func setUp() {
        self.title = "Fancy Font"
        self.showText = self.defualtText
        self.tblFont.register(UINib(nibName: FancyFontsCell.identifier, bundle: nil), forCellReuseIdentifier: FancyFontsCell.identifier)
        self.tblFont.delegate = self
        self.tblFont.dataSource = self
        self.updateList()
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickCreate(_ sender: UIButton) {
        let txt = txtText.text ?? ""
        self.showText = txt == "" ? self.defualtText : txt
        self.updateList()
    }
    
    // MARK: - OTHER
    
    func updateList() {
        let fancyArray = FancyTextGenerator.generateFancyStyles(for: self.showText)
        self.fancyList = fancyArray
        self.tblFont.reloadData()
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

//MARK: - TABLEVIEw
extension FancyFontsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fancyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FancyFontsCell.identifier, for: indexPath) as! FancyFontsCell        
        cell.lblMessage.text = fancyList[indexPath.row]
        cell.copyClickEvent = {
            UIPasteboard.general.string = self.fancyList[indexPath.row]
            showToast("Copied!", in: self)
        }
        
        cell.shareClickEvent = {
            shareText(self.fancyList[indexPath.row], from: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}
