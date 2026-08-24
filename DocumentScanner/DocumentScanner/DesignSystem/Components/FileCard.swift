//
//  FileCard.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct FileCard: View {
    let file: SavedFile
    let onOpen: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    let onShare: () -> Void
    let isSelectionMode: Bool
    let isSelected: Bool
    let onLongPress: () -> Void
    let onSelectionToggle: () -> Void
    let moveMenu: AnyView?

    init(
        file: SavedFile,
        onOpen: @escaping () -> Void,
        onRename: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void,
        onShare: @escaping () -> Void,
        isSelectionMode: Bool = false,
        isSelected: Bool = false,
        onLongPress: @escaping () -> Void = {},
        onSelectionToggle: @escaping () -> Void = {},
        moveMenu: AnyView? = nil
    ) {
        self.file = file
        self.onOpen = onOpen
        self.onRename = onRename
        self.onDelete = onDelete
        self.onToggleFavorite = onToggleFavorite
        self.onShare = onShare
        self.isSelectionMode = isSelectionMode
        self.isSelected = isSelected
        self.onLongPress = onLongPress
        self.onSelectionToggle = onSelectionToggle
        self.moveMenu = moveMenu
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if isSelectionMode {
                Button(action: onSelectionToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .appPrimary : .appTextSecondary.opacity(0.65))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }

            Button(action: isSelectionMode ? onSelectionToggle : onOpen) {
                HStack(spacing: 12) {
                    // File Type Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(fileColor.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: fileIcon)
                            .font(.system(size: 22))
                            .foregroundColor(fileColor)
                    }
                    
                    // Metadata
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.name)
                            .appFont(.appHeadline, weight: .semibold, color: .appTextPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            Text(formattedSize)
                            Text("•")
                            Text(formattedDate)
                        }
                        .appFont(.appCaption, color: .appTextSecondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onLongPressGesture(perform: onLongPress)

            if !isSelectionMode {
                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: file.isFavorite ? Images.System.favoriteFill : Images.System.favorite)
                        .font(.system(size: 18))
                        .foregroundColor(file.isFavorite ? .appWarning : .appTextSecondary.opacity(0.6))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(ScaleButtonStyle())

                // Action Menu
                Menu {
                    Button(action: onShare) {
                        Label(Strings.General.share, systemImage: Images.System.share)
                    }
                    Button(action: onRename) {
                        Label(Strings.General.rename, systemImage: Images.System.edit)
                    }
                    if let moveMenu {
                        moveMenu
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label(Strings.General.delete, systemImage: Images.System.delete)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appTextSecondary.opacity(0.8))
                        .frame(width: 32, height: 32)
                }
            }
        }
        .cardStyle(padding: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
        )
    }
    
    private var fileIcon: String {
        switch file.fileType.lowercased() {
        case "pdf":
            return "doc.text.fill"
        case "png", "jpg", "jpeg", "heic":
            return "photo.fill"
        case "txt":
            return "doc.plaintext.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var fileColor: Color {
        switch file.fileType.lowercased() {
        case "pdf":
            return .appError // Red for PDFs
        case "png", "jpg", "jpeg", "heic":
            return .appPrimary // Blue for images
        case "txt":
            return .appSuccess // Green for text files
        default:
            return .appTextSecondary
        }
    }
    
    private var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: file.fileSize, countStyle: .file)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: file.createdAt)
    }
}
