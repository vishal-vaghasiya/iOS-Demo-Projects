// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:disable type_body_length type_name
internal enum StoryboardScene {
  internal enum CameraScan: StoryboardType {
    internal static let storyboardName = "CameraScan"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: CameraScan.self)

    internal static let barCodeVC = SceneType<DualWhatsApp.BarCodeVC>(storyboard: CameraScan.self, identifier: "BarCodeVC")

    internal static let cameraScanerVC = SceneType<DualWhatsApp.CameraScanerVC>(storyboard: CameraScan.self, identifier: "CameraScanerVC")
  }
  internal enum ChatBackground: StoryboardType {
    internal static let storyboardName = "ChatBackground"

    internal static let initialScene = InitialSceneType<DualWhatsApp.ChatBackgroundTabbarVC>(storyboard: ChatBackground.self)

    internal static let categoryVC = SceneType<DualWhatsApp.CategoryVC>(storyboard: ChatBackground.self, identifier: "CategoryVC")

    internal static let chatBackgroundTabbarVC = SceneType<DualWhatsApp.ChatBackgroundTabbarVC>(storyboard: ChatBackground.self, identifier: "ChatBackgroundTabbarVC")

    internal static let homeVC = SceneType<DualWhatsApp.HomeVC>(storyboard: ChatBackground.self, identifier: "HomeVC")

    internal static let trendingVC = SceneType<DualWhatsApp.TrendingVC>(storyboard: ChatBackground.self, identifier: "TrendingVC")

    internal static let viewCategoryVC = SceneType<DualWhatsApp.ViewCategoryVC>(storyboard: ChatBackground.self, identifier: "ViewCategoryVC")

    internal static let viewWallpaperVC = SceneType<DualWhatsApp.ViewWallpaperVC>(storyboard: ChatBackground.self, identifier: "ViewWallpaperVC")
  }
  internal enum DirectChat: StoryboardType {
    internal static let storyboardName = "DirectChat"

    internal static let initialScene = InitialSceneType<DualWhatsApp.DirectChatVC>(storyboard: DirectChat.self)

    internal static let directChatVC = SceneType<DualWhatsApp.DirectChatVC>(storyboard: DirectChat.self, identifier: "DirectChatVC")
  }
  internal enum EmojiLetterVC: StoryboardType {
    internal static let storyboardName = "EmojiLetterVC"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: EmojiLetterVC.self)

    internal static let emojiLetterVC = SceneType<DualWhatsApp.EmojiLetterVC>(storyboard: EmojiLetterVC.self, identifier: "EmojiLetterVC")
  }
  internal enum FancyFonts: StoryboardType {
    internal static let storyboardName = "FancyFonts"

    internal static let fancyFontsVC = SceneType<DualWhatsApp.FancyFontsVC>(storyboard: FancyFonts.self, identifier: "FancyFontsVC")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let viewController = SceneType<DualWhatsApp.ViewController>(storyboard: Main.self, identifier: "ViewController")
  }
  internal enum PhotoVault: StoryboardType {
    internal static let storyboardName = "PhotoVault"

    internal static let photoVaultVC = SceneType<DualWhatsApp.PhotoVaultVC>(storyboard: PhotoVault.self, identifier: "PhotoVaultVC")
  }
  internal enum PrivateBrowser: StoryboardType {
    internal static let storyboardName = "PrivateBrowser"

    internal static let privateBrowserVC = SceneType<DualWhatsApp.PrivateBrowserVC>(storyboard: PrivateBrowser.self, identifier: "PrivateBrowserVC")
  }
  internal enum PrivateNotes: StoryboardType {
    internal static let storyboardName = "PrivateNotes"

    internal static let createNoteVC = SceneType<DualWhatsApp.CreateNoteVC>(storyboard: PrivateNotes.self, identifier: "CreateNoteVC")

    internal static let privateNotesVC = SceneType<DualWhatsApp.PrivateNotesVC>(storyboard: PrivateNotes.self, identifier: "PrivateNotesVC")
  }
  internal enum Quotes: StoryboardType {
    internal static let storyboardName = "Quotes"

    internal static let quotesVC = SceneType<DualWhatsApp.QuotesVC>(storyboard: Quotes.self, identifier: "QuotesVC")

    internal static let viewQuotesVC = SceneType<DualWhatsApp.ViewQuotesVC>(storyboard: Quotes.self, identifier: "ViewQuotesVC")
  }
  internal enum RepeatText: StoryboardType {
    internal static let storyboardName = "RepeatText"

    internal static let repeatTextVC = SceneType<DualWhatsApp.RepeatTextVC>(storyboard: RepeatText.self, identifier: "RepeatTextVC")
  }
  internal enum SpeechToText: StoryboardType {
    internal static let storyboardName = "SpeechToText"

    internal static let speechToTextVC = SceneType<DualWhatsApp.SpeechToTextVC>(storyboard: SpeechToText.self, identifier: "SpeechToTextVC")
  }
  internal enum WASticker: StoryboardType {
    internal static let storyboardName = "WASticker"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: WASticker.self)

    internal static let stickerPackVC = SceneType<DualWhatsApp.StickerPackVC>(storyboard: WASticker.self, identifier: "StickerPackVC")

    internal static let viewStickerPackVC = SceneType<DualWhatsApp.ViewStickerPackVC>(storyboard: WASticker.self, identifier: "ViewStickerPackVC")
  }
  internal enum WebWhatsApp: StoryboardType {
    internal static let storyboardName = "WebWhatsApp"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: WebWhatsApp.self)

    internal static let webWhatsappVC = SceneType<DualWhatsApp.WebWhatsappVC>(storyboard: WebWhatsApp.self, identifier: "WebWhatsappVC")
  }
  internal enum WhatsCropping: StoryboardType {
    internal static let storyboardName = "WhatsCropping"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: WhatsCropping.self)

    internal static let whatsCroppingVC = SceneType<DualWhatsApp.WhatsCroppingVC>(storyboard: WhatsCropping.self, identifier: "WhatsCroppingVC")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:enable type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
