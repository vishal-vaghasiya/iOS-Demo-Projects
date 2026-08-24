//MARK: - HOW TO USE
/*
 let effect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
 let effectView = VisualEffectView.init(effect: effect, intensity: 0.2)
 effectView.frame = self.view.bounds
 self.view.insertSubview(effectView, at: 0)
 */

import UIKit

@IBDesignable
final class VisualEffectView: UIVisualEffectView {

  @IBInspectable var blurStyleInt: Int = 2 { //1: LIGHT 2: DARK
    didSet {
      if let style = UIBlurEffect.Style(rawValue: blurStyleInt) {
        theEffect = UIBlurEffect(style: style)
        applyEffect()
      }
    }
  }

  @IBInspectable var intensity: CGFloat = 1.0 {
    didSet {
      applyEffect()
    }
  }

  private var animator: UIViewPropertyAnimator?
  private var theEffect: UIVisualEffect = UIBlurEffect(style: .light)

  /// Create visual effect view with given effect and its intensity
  ///
  /// - Parameters:
  ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
  ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
  init(effect: UIVisualEffect, intensity: CGFloat) {
    self.theEffect = effect
    self.intensity = intensity
    super.init(effect: nil)
    applyEffect()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    if let style = UIBlurEffect.Style(rawValue: blurStyleInt) {
      theEffect = UIBlurEffect(style: style)
    }
    applyEffect()
  }

  deinit {
    animator?.stopAnimation(true)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    applyEffect()
  }

  private func applyEffect() {
    self.effect = nil
    animator?.stopAnimation(true)
    animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
      self.effect = theEffect
    }
    animator?.fractionComplete = intensity
  }
}

/*
 import UIKit
 final class VisualEffectView: UIVisualEffectView {
   /// Create visual effect view with given effect and its intensity
   ///
   /// - Parameters:
   ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
   ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
   init(effect: UIVisualEffect, intensity: CGFloat) {
     theEffect = effect
     customIntensity = intensity
     super.init(effect: nil)
   }

   required init?(coder aDecoder: NSCoder) { nil }

   deinit {
     animator?.stopAnimation(true)
   }

   override func draw(_ rect: CGRect) {
     super.draw(rect)
     effect = nil
     animator?.stopAnimation(true)
     animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
       self.effect = theEffect
     }
     animator?.fractionComplete = customIntensity
   }

   private let theEffect: UIVisualEffect
   private let customIntensity: CGFloat
   private var animator: UIViewPropertyAnimator?
 }
 */
