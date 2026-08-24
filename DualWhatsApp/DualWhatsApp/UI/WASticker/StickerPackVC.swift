//
//  StickerPackVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit

class StickerPackVC: UIViewController {
    
    @IBOutlet private weak var stickerPacksTableView: UITableView!

    private var stickerPacks: [StickerPack] = []
    private var selectedIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        stickerPacksTableView.register(UINib(nibName: StickerPackTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: StickerPackTableViewCell.identifier)
        stickerPacksTableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if let selectedIndex = selectedIndex {
            stickerPacksTableView.deselectRow(at: selectedIndex, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchStickerPacks()
    }

    private func fetchStickerPacks() {
        let loadingAlert = UIAlertController(title: "Loading sticker packs", message: "\n\n", preferredStyle: .alert)
        loadingAlert.addSpinner()
        if self.stickerPacks.count == 0 {
            present(loadingAlert, animated: true)
        }
        do {
            try StickerPackManager.fetchStickerPacks(fromJSON: StickerPackManager.stickersJSON(contentsOfFile: "sticker_packs")) { stickerPacks in
                loadingAlert.dismiss(animated: false) {
                    self.navigationController?.navigationBar.alpha = 1.0
                    self.stickerPacks = stickerPacks
                    self.stickerPacksTableView.reloadData()
                }
            }
        } catch StickerPackError.fileNotFound {
            fatalError("sticker_packs.wasticker not found.")
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navigationBar = navigationController?.navigationBar {
            let contentInset: UIEdgeInsets = {
                if #available(iOS 11.0, *) {
                    return scrollView.adjustedContentInset
                } else {
                    return scrollView.contentInset
                }
            }()

            if scrollView.contentOffset.y <= -contentInset.top {
                navigationBar.shadowImage = UIImage()
            } else {
                navigationBar.shadowImage = nil
            }
        }
    }

    @objc func addButtonTapped(button: UIButton) {
        let loadingAlert: UIAlertController = UIAlertController(title: "Sending to WhatsApp", message: "\n\n", preferredStyle: .alert)
        loadingAlert.addSpinner()
        present(loadingAlert, animated: true)

        stickerPacks[button.tag].sendToWhatsApp { completed in
            loadingAlert.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate

extension StickerPackVC: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedIndex = indexPath
      let data = stickerPacks[indexPath.row]
      let vc = StoryboardScene.WASticker.viewStickerPackVC.instantiate()
      vc.title = data.name
      vc.stickerPack = data
      self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDataSource

extension StickerPackVC: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return stickerPacks.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 100
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell: StickerPackTableViewCell = tableView.dequeueReusableCell(withIdentifier: StickerPackTableViewCell.identifier) as? StickerPackTableViewCell else { return UITableViewCell() }
      cell.stickerPack = stickerPacks[indexPath.row]

      let addButton = UIButton(type: .contactAdd)
      addButton.tag = indexPath.row
      addButton.isEnabled = Interoperability.canSend()
      addButton.addTarget(self, action: #selector(addButtonTapped(button:)), for: .touchUpInside)
      cell.accessoryView = addButton

      return cell
  }
}
