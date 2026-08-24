# GlassSudoku 🔲

A modern Sudoku iOS app — SwiftUI + MVVM + Glassmorphism dark theme.

---

## ▶️ How to Open in Xcode (2 steps)

> The `.xcodeproj` is generated locally on your Mac — this avoids parse errors
> from cross-platform file generation.

### Step 1 — Generate the Xcode project

Open **Terminal**, navigate to the `GlassSudoku` folder, and run:

```bash
cd ~/Downloads/GlassSudoku
./setup.sh
```

This script:
1. Installs **XcodeGen** via Homebrew (only first time, ~10 seconds)
2. Runs `xcodegen generate` to create a valid `GlassSudoku.xcodeproj`

### Step 2 — Open in Xcode

```bash
open GlassSudoku.xcodeproj
```

Or double-click `GlassSudoku.xcodeproj` in Finder.

---

## Requirements

- macOS 13+ with Xcode 15+
- [Homebrew](https://brew.sh) (for XcodeGen install)
- iOS 17+ simulator or device

---

## Project Structure

```
GlassSudoku/
├── setup.sh                    ← Run this first!
├── project.yml                 ← XcodeGen config
└── GlassSudoku/
    ├── GlassSudokuApp.swift
    ├── Models/
    │   ├── SudokuCell.swift
    │   ├── SudokuBoard.swift       ← Supports 6×6 (Easy) and 9×9 (Medium/Hard)
    │   └── DifficultyLevel.swift
    ├── ViewModels/
    │   ├── GameViewModel.swift     ← All game state, pause, completion tracking
    │   ├── TimerViewModel.swift
    │   └── AdsViewModel.swift
    ├── Views/
    │   ├── GameView.swift          ← Premium background image
    │   ├── GameBoardView.swift     ← Dynamic 6×6 / 9×9 grid
    │   ├── SudokuCellView.swift    ← Flash animation on row/col/box complete
    │   ├── NumberPadView.swift     ← 6 buttons (Easy) or 9 (Medium/Hard)
    │   ├── GameControlsView.swift
    │   ├── HeaderView.swift        ← Pause button built into timer
    │   ├── DifficultyPickerView.swift
    │   └── ResultView.swift
    ├── Components/
    │   ├── GlassCard.swift
    │   └── GlassButton.swift
    ├── Services/
    │   ├── SudokuLoader.swift
    │   ├── ValidationService.swift
    │   └── AdsService.swift        ← AdMob stub (replace for production)
    └── Resources/
        ├── sudoku_answers.json     ← Easy=6×6, Medium/Hard=9×9 puzzles
        ├── bg_premium.jpg          ← @1x background
        ├── bg_premium@2x.jpg
        └── bg_premium@3x.jpg
```

---

## Features

| Feature | Details |
|---|---|
| Easy mode | **6×6 grid, numbers 1–6** |
| Medium / Hard | Standard **9×9 Sudoku** |
| Expert | Removed |
| Background | Premium dark image (navy + gold/purple glows) |
| Completion animation | Green flash when row/col/box completes |
| Pause | Tap timer to pause/resume |
| Undo / Redo | 30-level history |
| Notes mode | Pencil notes per cell |
| Mistake counter | Dots in header |
| Hint (Ad-gated) | AdMob rewarded ad stub |
| Haptic feedback | All interactions |

---

## Adding Real AdMob Ads

1. Add `pod 'Google-Mobile-Ads-SDK'` to a Podfile
2. Replace `StubRewardedAd` in `AdsService.swift` with `GADRewardedAd`
3. Add your App ID to `Info.plist` under `GADApplicationIdentifier`
