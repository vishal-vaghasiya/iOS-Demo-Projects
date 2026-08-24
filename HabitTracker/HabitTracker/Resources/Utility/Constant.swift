//
//  Constant.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let AppName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
let APPID = ""
let AppleStoreURL = "https://itunes.apple.com/app/id\(APPID)?mt=8"
let RateLink = "https://itunes.apple.com/app/id\(APPID)?mt=8&action=write-review"

let appDelegate = UIApplication.shared.delegate as! AppDelegate

internal enum AppInfo { }
internal extension AppInfo {
    static var versionStore = Float()
    static var versionLocal = Float()
}

internal enum VariableInfo { }
internal extension VariableInfo {
    static let userDefault = UserDefaults.standard
    static let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    static let window = (UIApplication.shared.delegate as! AppDelegate).window
    static let fileManager = FileManager.default
}

let defaultCategory: [HabitCategory] = [
    HabitCategory(name: "Meditate", systemIcon: "brain.head.profile", defaulGoal: Goal()),
]

// Suggested Category List
//let suggestedCategories: [HabitCategory] = [
//    HabitCategory(name: "Meditate", systemIcon: "brain.head.profile"),
//    HabitCategory(name: "Set a To-do List", systemIcon: "checklist"),
//    HabitCategory(name: "Drink Water", systemIcon: "drop"),
//    HabitCategory(name: "Read Books", systemIcon: "book"),
//    HabitCategory(name: "Running", systemIcon: "figure.run"),
//    HabitCategory(name: "Quick Stretch", systemIcon: "figure.cooldown"),
//    HabitCategory(name: "Hit the Gym", systemIcon: "dumbbell"),
//    HabitCategory(name: "Swimming", systemIcon: "figure.pool.swim"),
//    HabitCategory(name: "Core Training", systemIcon: "figure.strengthtraining.traditional"),
//    HabitCategory(name: "Practice Yoga", systemIcon: "figure.yoga"),
//    HabitCategory(name: "Hit Cardio", systemIcon: "heart.fill"),
//    HabitCategory(name: "Cycling", systemIcon: "bicycle"),
//    HabitCategory(name: "Go for a Walk", systemIcon: "figure.walk"),
//    HabitCategory(name: "Get Good Sleep", systemIcon: "bed.double.fill"),
//    HabitCategory(name: "Take a Cold Shower", systemIcon: "drop.triangle"),
//    HabitCategory(name: "Take Power Naps", systemIcon: "zzz"),
//    HabitCategory(name: "Wash Your Hands", systemIcon: "hands.sparkles"),
//    HabitCategory(name: "Apply Sunscreen", systemIcon: "sun.max.fill"),
//    HabitCategory(name: "Take a Deep Breath", systemIcon: "wind"),
//    HabitCategory(name: "Wear mask", systemIcon: "facemask"),
//    HabitCategory(name: "Read an Article", systemIcon: "doc.text"),
//    HabitCategory(name: "Review Your Day", systemIcon: "calendar"),
//    HabitCategory(name: "Clean Up Emails", systemIcon: "envelope.open"),
//    HabitCategory(name: "Write in Journal", systemIcon: "pencil.and.outline"),
//    HabitCategory(name: "Call My Parents", systemIcon: "phone"),
//    HabitCategory(name: "Spend Time with Family", systemIcon: "person.3.fill"),
//    HabitCategory(name: "Pay Compliment", systemIcon: "quote.bubble"),
//    HabitCategory(name: "Meet a Friend", systemIcon: "person.2.fill"),
//    HabitCategory(name: "Say Thank You", systemIcon: "hands.clap"),
//    HabitCategory(name: "Spend Time with Yourself", systemIcon: "person.crop.circle"),
//    HabitCategory(name: "Take Vitamins", systemIcon: "pills"),
//    HabitCategory(name: "Eat Fruits", systemIcon: "applelogo"),
//    HabitCategory(name: "Limited Sugar", systemIcon: "cube"),
//    HabitCategory(name: "Track Calories", systemIcon: "flame"),
//    HabitCategory(name: "Limit Caffeine", systemIcon: "cup.and.saucer"),
//    HabitCategory(name: "Learn Spanish", systemIcon: "character.book.closed"),
//    HabitCategory(name: "Learn French", systemIcon: "character.book.closed.fill"),
//    HabitCategory(name: "Learn German", systemIcon: "character"),
//    HabitCategory(name: "Learn Japanese", systemIcon: "character.cursor.ibeam"),
//    HabitCategory(name: "Practice Coding", systemIcon: "chevron.left.slash.chevron.right"),
//    HabitCategory(name: "Try a New Recipe", systemIcon: "fork.knife"),
//    HabitCategory(name: "Play the Guitar", systemIcon: "guitars"),
//    HabitCategory(name: "Take a Photo", systemIcon: "camera"),
//    HabitCategory(name: "Paint & Draw", systemIcon: "paintpalette"),
//    HabitCategory(name: "Just Dance", systemIcon: "figure.dance"),
//    HabitCategory(name: "Play Badminton", systemIcon: "sportscourt"),
//    HabitCategory(name: "Practice for Baseball", systemIcon: "sportscourt"),
//    HabitCategory(name: "Go Bowling", systemIcon: "sportscourt"),
//    HabitCategory(name: "Practice Boxing", systemIcon: "figure.boxing"),
//    HabitCategory(name: "Go Fishing", systemIcon: "fish"),
//    HabitCategory(name: "Play Golf", systemIcon: "flag"),
//    HabitCategory(name: "Go Climbing", systemIcon: "figure.climbing"),
//    HabitCategory(name: "Count Your Steps", systemIcon: "figure.walk.motion"),
//    HabitCategory(name: "Jump Rope", systemIcon: "figure.jumprope"),
//    HabitCategory(name: "Treadmill Running", systemIcon: "figure.run.circle"),
//    HabitCategory(name: "Lift Weight", systemIcon: "dumbbell.fill"),
//    HabitCategory(name: "Climb Those Stairs", systemIcon: "stairs"),
//    HabitCategory(name: "Stay in Movements", systemIcon: "figure.walk.circle"),
//    HabitCategory(name: "Exercise Time", systemIcon: "timer"),
//    HabitCategory(name: "Burn some Calories", systemIcon: "flame.fill"),
//    HabitCategory(name: "Wheelchair Exercise", systemIcon: "figure.roll"),
//    HabitCategory(name: "Go Kayaking", systemIcon: "figure.kayak"),
//    HabitCategory(name: "Go Rowing", systemIcon: "figure.rower"),
//    HabitCategory(name: "Take Vitamin A", systemIcon: "a.circle.fill"),
//    HabitCategory(name: "Take Vitamin C", systemIcon: "c.circle.fill"),
//    HabitCategory(name: "Take Vitamin B6", systemIcon: "b.circle.fill"),
//    HabitCategory(name: "Take Vitamin E", systemIcon: "e.circle.fill"),
//    HabitCategory(name: "Niacin Intake", systemIcon: "n.circle.fill"),
//    HabitCategory(name: "Biotin Intake", systemIcon: "b.circle"),
//    HabitCategory(name: "Calcium Intake", systemIcon: "c.circle"),
//    HabitCategory(name: "Sodium Intake", systemIcon: "s.circle"),
//    HabitCategory(name: "Fat Intake", systemIcon: "circle.lefthalf.fill"),
//    HabitCategory(name: "Protein Intake", systemIcon: "bolt.fill"),
//    HabitCategory(name: "Cholesterol Intake", systemIcon: "circle.righthalf.fill")
//]

// Health Category List
//let healthCategories: [HabitCategory] = [
//    HabitCategory(name: "Sleep", systemIcon: "bed.double.fill"),
//    HabitCategory(name: "Water Intake", systemIcon: "drop.fill"),
//    HabitCategory(name: "Step Count", systemIcon: "figure.walk"),
//    HabitCategory(name: "Mindfulness", systemIcon: "brain.head.profile"),
//    HabitCategory(name: "Exercise Time", systemIcon: "timer"),
//    HabitCategory(name: "Walking", systemIcon: "figure.walk"),
//    HabitCategory(name: "Running", systemIcon: "figure.run"),
//    HabitCategory(name: "Yoga", systemIcon: "figure.yoga"),
//    HabitCategory(name: "Hiking", systemIcon: "figure.hiking"),
//    HabitCategory(name: "HIIT", systemIcon: "flame"),
//    HabitCategory(name: "Pilates", systemIcon: "figure.strengthtraining.functional"),
//    HabitCategory(name: "Time in Daylight", systemIcon: "sun.max.fill"),
//    HabitCategory(name: "Tooth Brushing", systemIcon: "mouth"),
//    HabitCategory(name: "Hand Washing", systemIcon: "hands.sparkles"),
//    HabitCategory(name: "Stand Hours", systemIcon: "hourglass"),
//    HabitCategory(name: "Move Time", systemIcon: "figure.walk.circle"),
//    HabitCategory(name: "Stand Minutes", systemIcon: "timer"),
//    HabitCategory(name: "Fiber Intake", systemIcon: "leaf"),
//    HabitCategory(name: "Protein Intake", systemIcon: "bolt.fill"),
//    HabitCategory(name: "Core Training", systemIcon: "figure.core.training"),
//    HabitCategory(name: "Swimming", systemIcon: "figure.pool.swim"),
//    HabitCategory(name: "Jump Rope", systemIcon: "figure.jumprope"),
//    HabitCategory(name: "Kickboxing", systemIcon: "figure.kickboxing"),
//    HabitCategory(name: "Boxing", systemIcon: "figure.boxing"),
//    HabitCategory(name: "Climbing", systemIcon: "figure.climbing"),
//    HabitCategory(name: "Social Dance", systemIcon: "figure.dance"),
//    HabitCategory(name: "Cardio Dance", systemIcon: "music.note"),
//    HabitCategory(name: "Mixed Cardio", systemIcon: "heart.fill"),
//    HabitCategory(name: "Fitness Gaming", systemIcon: "gamecontroller"),
//    HabitCategory(name: "Hard Cycling", systemIcon: "bicycle"),
//    HabitCategory(name: "Badminton", systemIcon: "sportscourt"),
//    HabitCategory(name: "Cycling", systemIcon: "bicycle"),
//    HabitCategory(name: "Pickleball", systemIcon: "sportscourt"),
//    HabitCategory(name: "Baseball", systemIcon: "sportscourt"),
//    HabitCategory(name: "Bowling", systemIcon: "sportscourt"),
//    HabitCategory(name: "Golf", systemIcon: "flag"),
//    HabitCategory(name: "Underwater Diving", systemIcon: "lungs"),
//    HabitCategory(name: "Active Calories", systemIcon: "flame"),
//    HabitCategory(name: "Flights Climbed", systemIcon: "stairs"),
//    HabitCategory(name: "Swimming Strokes", systemIcon: "figure.pool.swim"),
//    HabitCategory(name: "Cycling Power", systemIcon: "bolt"),
//    HabitCategory(name: "Rowing", systemIcon: "figure.rower"),
//    HabitCategory(name: "Distance", systemIcon: "ruler"),
//    HabitCategory(name: "Estimated Workout Effort", systemIcon: "figure.strengthtraining.traditional"),
//    HabitCategory(name: "Workout Effort Score", systemIcon: "chart.bar.fill"),
//    HabitCategory(name: "Vitamin D", systemIcon: "d.circle.fill"),
//    HabitCategory(name: "Calcium", systemIcon: "c.circle.fill"),
//    HabitCategory(name: "Iron", systemIcon: "i.circle.fill"),
//    HabitCategory(name: "Vitamin C", systemIcon: "c.circle"),
//    HabitCategory(name: "Potassium", systemIcon: "p.circle.fill"),
//    HabitCategory(name: "Vitamin B12", systemIcon: "b.circle"),
//    HabitCategory(name: "Vitamin B6", systemIcon: "b.circle.fill"),
//    HabitCategory(name: "Vitamin A", systemIcon: "a.circle.fill"),
//    HabitCategory(name: "Vitamin E", systemIcon: "e.circle.fill"),
//    HabitCategory(name: "Vitamin K", systemIcon: "k.circle.fill"),
//    HabitCategory(name: "Folate", systemIcon: "f.circle.fill"),
//    HabitCategory(name: "Magnesium", systemIcon: "m.circle.fill"),
//    HabitCategory(name: "Zinc", systemIcon: "z.circle.fill"),
//    HabitCategory(name: "Niacin", systemIcon: "n.circle"),
//    HabitCategory(name: "Thiamin", systemIcon: "t.circle.fill"),
//    HabitCategory(name: "Riboflavin", systemIcon: "r.circle.fill"),
//    HabitCategory(name: "Biotin", systemIcon: "b.circle"),
//    HabitCategory(name: "Pantothenic Acid", systemIcon: "p.circle"),
//    HabitCategory(name: "Manganese", systemIcon: "m.circle"),
//    HabitCategory(name: "Selenium", systemIcon: "s.circle"),
//    HabitCategory(name: "Copper", systemIcon: "c.circle"),
//    HabitCategory(name: "Iodine", systemIcon: "i.circle"),
//    HabitCategory(name: "Phosphorus", systemIcon: "p.circle"),
//    HabitCategory(name: "Chloride", systemIcon: "c.circle"),
//    HabitCategory(name: "Molybdenum", systemIcon: "m.circle"),
//    HabitCategory(name: "Chromium", systemIcon: "c.circle"),
//    HabitCategory(name: "Carbohydrates", systemIcon: "circle.grid.hex"),
//    HabitCategory(name: "Monounsaturated Fat", systemIcon: "drop.circle"),
//    HabitCategory(name: "Total Fat", systemIcon: "circle.lefthalf.fill"),
//    HabitCategory(name: "Saturated Fat", systemIcon: "circle.righthalf.fill"),
//    HabitCategory(name: "Calories Consumed", systemIcon: "flame.fill"),
//    HabitCategory(name: "Cholesterol", systemIcon: "c.circle"),
//    HabitCategory(name: "Sodium Intake", systemIcon: "s.circle.fill"),
//    HabitCategory(name: "Caffeine Intake", systemIcon: "cup.and.saucer.fill"),
//    HabitCategory(name: "Sugar Intake", systemIcon: "cube.fill"),
//    HabitCategory(name: "Alcoholic Beverages", systemIcon: "wineglass")
//]
