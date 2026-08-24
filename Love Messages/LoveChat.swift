// Step 1: Add Firebase to Your Project
// 1.    Add Firebase to your iOS app following the official guide.
// 2.    Add these pods to your Podfile:
//
// pod 'Firebase/Firestore'
// pod 'Firebase/Auth'
//
// 3.    Run pod install and import Firebase in AppDelegate.swift:
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// Step 2: Firestore Data Model
//
// Collection structure:
// users (userId)
//   - name: String
//   - gender: String (male/female)
//
// chats (chatId)
//   - user1Id
//   - user2Id
//   - messages (subcollection)
//       - senderId
//       - text
//       - stickerURL
//       - createdAt
//       - expireAt

// Step 3: Chat Service Class

import FirebaseFirestore
import FirebaseAuth

class ChatService {
    static let shared = ChatService()
    let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Send Message
    func sendMessage(chatId: String, text: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let now = Timestamp(date: Date())
        let expireAt = Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!)
        
        let messageData: [String: Any] = [
            "senderId": userId,
            "text": text,
            "createdAt": now,
            "expireAt": expireAt
        ]
        
        db.collection("chats").document(chatId)
            .collection("messages").addDocument(data: messageData) { error in
                completion(error)
            }
    }
    
    // MARK: - Send Sticker
    func sendSticker(chatId: String, stickerURL: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let now = Timestamp(date: Date())
        let expireAt = Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!)
        
        let messageData: [String: Any] = [
            "senderId": userId,
            "stickerURL": stickerURL,
            "createdAt": now,
            "expireAt": expireAt
        ]
        
        db.collection("chats").document(chatId)
            .collection("messages").addDocument(data: messageData) { error in
                completion(error)
            }
    }
    
    // MARK: - Listen to Messages in Real-Time
    func observeMessages(chatId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No messages")
                    return
                }
                
                let messages: [Message] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let senderId = data["senderId"] as? String,
                        let createdAt = data["createdAt"] as? Timestamp
                    else { return nil }
                    
                    let text = data["text"] as? String
                    let stickerURL = data["stickerURL"] as? String
                    
                    return Message(id: doc.documentID, senderId: senderId, text: text, stickerURL: stickerURL, createdAt: createdAt.dateValue())
                }
                
                completion(messages)
            }
    }
    
    // MARK: - Clean Expired Messages (Optional if TTL not set)
    func cleanExpiredMessages(chatId: String) {
        let now = Timestamp(date: Date())
        db.collection("chats").document(chatId)
            .collection("messages")
            .whereField("expireAt", isLessThan: now)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                for doc in documents {
                    doc.reference.delete()
                }
            }
    }
}

// Step 4: Message Model

import Foundation

struct Message {
    let id: String
    let senderId: String
    let text: String?
    let stickerURL: String?
    let createdAt: Date
}

// Step 5: ChatViewController (UIKit)

import UIKit
import FirebaseAuth
import FirebaseStorage

class ChatBubbleCell: UITableViewCell {
    static let identifier = "ChatBubbleCell"
    
    private let bubbleBackgroundView = UIView()
    private let messageLabel = UILabel()
    private let stickerImageView = UIImageView()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bubbleBackgroundView.layer.cornerRadius = 16
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleBackgroundView)
        
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.addSubview(messageLabel)
        
        stickerImageView.contentMode = .scaleAspectFit
        stickerImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.addSubview(stickerImageView)
        
        // Constraints for messageLabel and stickerImageView inside bubbleBackgroundView
        let messageLabelConstraints = [
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12)
        ]
        NSLayoutConstraint.activate(messageLabelConstraints)
        
        let stickerImageViewConstraints = [
            stickerImageView.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            stickerImageView.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            stickerImageView.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            stickerImageView.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),
            stickerImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            stickerImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        ]
        NSLayoutConstraint.activate(stickerImageViewConstraints)
        
        // Constraints for bubbleBackgroundView
        let bubbleConstraints = [
            bubbleBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        NSLayoutConstraint.activate(bubbleConstraints)
        
        leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        trailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: Message, isCurrentUser: Bool) {
        if let stickerURL = message.stickerURL {
            messageLabel.isHidden = true
            stickerImageView.isHidden = false
            stickerImageView.image = UIImage(named: stickerURL) ?? nil
            bubbleBackgroundView.backgroundColor = .clear
        } else if let text = message.text {
            messageLabel.isHidden = false
            stickerImageView.isHidden = true
            messageLabel.text = text
            bubbleBackgroundView.backgroundColor = isCurrentUser ? UIColor.systemBlue : UIColor(white: 0.90, alpha: 1)
            messageLabel.textColor = isCurrentUser ? .white : .black
        } else {
            // Neither text nor sticker, hide both
            messageLabel.isHidden = true
            stickerImageView.isHidden = true
            bubbleBackgroundView.backgroundColor = .clear
        }
        
        if isCurrentUser {
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var chatId: String!
    var messages: [Message] = []
    var listener: ListenerRegistration?
    
    // Pagination properties
    let pageSize = 20
    var lastDocument: DocumentSnapshot?
    var isLoading = false
    var allMessagesLoaded = false
    var isInitialLoad = true
    
    private let tableView = UITableView()
    private let messageInputBar = UITextField()
    private let sendButton = UIButton(type: .system)
    private let imagePickerButton = UIButton(type: .system)
    private var stickerCollectionView: UICollectionView!
    
    private let stickers = ["sticker1.png", "sticker2.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialMessages()
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        tableView.prefetchDataSource = nil
        tableView.showsVerticalScrollIndicator = true
        tableView.scrollsToTop = true
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        tableView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(tableView)
        
        // Sticker CollectionView setup
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        stickerCollectionView.backgroundColor = .clear
        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self
        stickerCollectionView.showsHorizontalScrollIndicator = false
        stickerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        stickerCollectionView.register(StickerCell.self, forCellWithReuseIdentifier: StickerCell.identifier)
        view.addSubview(stickerCollectionView)
        
        // Message input bar setup
        messageInputBar.borderStyle = .roundedRect
        messageInputBar.placeholder = "Type message..."
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputBar)
        
        // Image picker button setup
        imagePickerButton.setTitle("+", for: .normal)
        imagePickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        imagePickerButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imagePickerButton)
        
        // Send button setup
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: stickerCollectionView.topAnchor, constant: -8),
            
            stickerCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            stickerCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            stickerCollectionView.heightAnchor.constraint(equalToConstant: 80),
            stickerCollectionView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor, constant: -8),
            
            imagePickerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            imagePickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 40),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 40),
            
            messageInputBar.leftAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: 8),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            messageInputBar.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8),
            messageInputBar.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: messageInputBar.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollsToTop = true
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        tableView.keyboardDismissMode = .interactive
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Image Picker
    @objc func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        // Compress image
        guard let compressedData = compressImage(image) else {
            print("Failed to compress image")
            return
        }
        // Upload to Firebase Storage
        uploadImageToFirebase(data: compressedData) { [weak self] urlString in
            guard let self = self, let urlString = urlString else {
                print("Failed to upload image")
                return
            }
            // Send as sticker message
            ChatService.shared.sendSticker(chatId: self.chatId, stickerURL: urlString) { error in
                if let error = error {
                    print("Error sending image sticker: \(error.localizedDescription)")
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    /// Compress the image to JPEG with 0.7 quality and resize if needed
    func compressImage(_ image: UIImage) -> Data? {
        // Optionally resize if image is too large
        let maxDimension: CGFloat = 1024
        var scaledImage = image
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let aspectRatio = image.size.width / image.size.height
            var newSize: CGSize
            if aspectRatio > 1 {
                newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            }
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.7)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        return scaledImage.jpegData(compressionQuality: 0.7)
    }

    /// Upload image data to Firebase Storage and return URL string
    func uploadImageToFirebase(data: Data, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let fileName = "chatImages/\(UUID().uuidString).jpg"
        let ref = storage.reference().child(fileName)
        ref.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("Download URL error: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    @objc func sendMessage() {
        guard let text = messageInputBar.text, !text.isEmpty else { return }
        ChatService.shared.sendMessage(chatId: chatId, text: text) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.messageInputBar.text = ""
                }
            }
        }
    }
    
    // MARK: - Pagination
    func loadInitialMessages() {
        guard !isLoading else { return }
        isLoading = true
        allMessagesLoaded = false
        lastDocument = nil
        let ref = ChatService.shared.db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
        ref.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            guard let snapshot = snapshot, error == nil else { return }
            let docs = snapshot.documents
            if docs.count < self.pageSize {
                self.allMessagesLoaded = true
            }
            self.lastDocument = docs.last
            let newMessages: [Message] = docs.compactMap { doc in
                let data = doc.data()
                guard let senderId = data["senderId"] as? String,
                      let createdAt = data["createdAt"] as? Timestamp else { return nil }
                let text = data["text"] as? String
                let stickerURL = data["stickerURL"] as? String
                return Message(id: doc.documentID, senderId: senderId, text: text, stickerURL: stickerURL, createdAt: createdAt.dateValue())
            }
            // Firestore returns descending, so reverse to ascending
            self.messages = newMessages.reversed()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }

    func loadOlderMessages() {
        guard !isLoading, !allMessagesLoaded, let lastDoc = lastDocument else { return }
        isLoading = true
        let ref = ChatService.shared.db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDoc)
            .limit(to: pageSize)
        ref.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            guard let snapshot = snapshot, error == nil else { return }
            let docs = snapshot.documents
            if docs.isEmpty {
                self.allMessagesLoaded = true
                return
            }
            if docs.count < self.pageSize {
                self.allMessagesLoaded = true
            }
            self.lastDocument = docs.last
            let newMessages: [Message] = docs.compactMap { doc in
                let data = doc.data()
                guard let senderId = data["senderId"] as? String,
                      let createdAt = data["createdAt"] as? Timestamp else { return nil }
                let text = data["text"] as? String
                let stickerURL = data["stickerURL"] as? String
                return Message(id: doc.documentID, senderId: senderId, text: text, stickerURL: stickerURL, createdAt: createdAt.dateValue())
            }
            // Firestore returns descending, so reverse to ascending
            let toPrepend = newMessages.reversed()
            let oldContentOffset = self.tableView.contentOffset
            let oldContentHeight = self.tableView.contentSize.height
            self.messages.insert(contentsOf: toPrepend, at: 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                // Maintain scroll position after prepending
                self.tableView.layoutIfNeeded()
                let newContentHeight = self.tableView.contentSize.height
                let offsetDelta = newContentHeight - oldContentHeight
                self.tableView.contentOffset = CGPoint(x: oldContentOffset.x, y: oldContentOffset.y + offsetDelta)
            }
        }
    }

    func observeMessages() {
        listener = ChatService.shared.observeMessages(chatId: chatId) { [weak self] messages in
            guard let self = self else { return }
            // Only update messages that are new (real-time update)
            // When paginating, don't overwrite prepended messages
            // So, merge new messages at the end (if any)
            // Find first message not in self.messages and append
            if self.isInitialLoad {
                // On initial load, ignore, since loadInitialMessages handles it
                self.isInitialLoad = false
                return
            }
            // Only add new messages at the end (real-time)
            if let last = self.messages.last {
                // Find new messages after last
                let new = messages.filter { msg in
                    if let idx = self.messages.firstIndex(where: { $0.id == msg.id }) {
                        return false
                    }
                    return msg.createdAt > last.createdAt
                }
                if !new.isEmpty {
                    self.messages.append(contentsOf: new)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            } else {
                // If no messages, just set
                self.messages = messages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let lastIndex = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.identifier, for: indexPath) as? ChatBubbleCell else {
            return UITableViewCell()
        }
        let msg = messages[indexPath.row]
        let isCurrentUser = msg.senderId == Auth.auth().currentUser?.uid
        cell.configure(with: msg, isCurrentUser: isCurrentUser)
        
        // Add long press gesture for deleting message
        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.contentView.addGestureRecognizer(longPress)
        cell.contentView.tag = indexPath.row
        
        return cell
    }

    // MARK: - UIScrollViewDelegate (for lazy loading)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else { return }
        // If user scrolls to very top, load older messages
        if scrollView.contentOffset.y <= 0 {
            loadOlderMessages()
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let index = gesture.view?.tag else { return }
        let message = messages[index]
        
        let alert = UIAlertController(title: "Delete Message",
                                      message: "Are you sure you want to delete this message?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteMessage(message)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteMessage(_ message: Message) {
        let docRef = ChatService.shared.db.collection("chats").document(chatId)
            .collection("messages").document(message.id)
        docRef.delete { error in
            if let error = error {
                print("Failed to delete message: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UICollectionView (Sticker Picker)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCell.identifier, for: indexPath) as? StickerCell else {
            return UICollectionViewCell()
        }
        let stickerName = stickers[indexPath.item]
        cell.configure(with: UIImage(named: stickerName))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stickerName = stickers[indexPath.item]
        ChatService.shared.sendSticker(chatId: chatId, stickerURL: stickerName) { error in
            if let error = error {
                print("Error sending sticker: \(error.localizedDescription)")
            }
        }
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

class StickerCell: UICollectionViewCell {
    static let identifier = "StickerCell"
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
}
