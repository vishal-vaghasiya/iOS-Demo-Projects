//
//  CreateNoteVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit
import CoreData
import CloudKit

class CreateNoteVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var noteTextview: UITextView!
    
    // MARK: - PROPERTY
    var noteToEdit: Notes?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noteTextview.text = noteToEdit?.text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func saveButtonClick(_ sender: UIBarButtonItem) {
        guard let noteText = noteTextview.text, !noteText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Note cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        if let noteToEdit = noteToEdit {
            // Edit existing note
            noteToEdit.text = noteText
            noteToEdit.createdAt = Date()
        } else {
            // Create new note
            let noteEntity = NSEntityDescription.entity(forEntityName: "Notes", in: context)!
            let noteObject = NSManagedObject(entity: noteEntity, insertInto: context)
            noteObject.setValue(UUID(), forKey: "id")
            noteObject.setValue(noteText, forKey: "text")
            noteObject.setValue(Date(), forKey: "createdAt")
        }

        do {
            try context.save()
            print("Note saved locally in Core Data")
        } catch {
            print("Failed to save note: \(error)")
            return
        }

        // Optionally clear textview
        noteTextview.text = ""
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
