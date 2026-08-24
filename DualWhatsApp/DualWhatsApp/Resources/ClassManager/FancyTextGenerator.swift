//
//  EnumTypes.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 13/10/25.
//

import Foundation
import UIKit
struct FancyTextGenerator {
    
    static func generateFancyStyles(for text: String) -> [String] {
        let t = text.isEmpty ? "Your Text" : text
        
        // Basic Unicode styles
        let script = map(t, with: ["a":"𝒶","b":"𝒷","c":"𝒸","d":"𝒹","e":"ℯ","f":"𝒻","g":"𝓰","h":"𝒽","i":"𝒾","j":"𝒿","k":"𝓀","l":"𝓁","m":"𝓂","n":"𝓃","o":"𝓸","p":"𝓅","q":"𝓆","r":"𝓇","s":"𝓈","t":"𝓉","u":"𝓊","v":"𝓋","w":"𝓌","x":"𝓍","y":"𝓎","z":"𝓏"])
        let fraktur = map(t, with: ["a":"𝔞","b":"𝔟","c":"𝔠","d":"𝔡","e":"𝔢","f":"𝔣","g":"𝔤","h":"𝔥","i":"𝔦","j":"𝔧","k":"𝔨","l":"𝔩","m":"𝔪","n":"𝔫","o":"𝔬","p":"𝔭","q":"𝔮","r":"𝔯","s":"𝔰","t":"𝔱","u":"𝔲","v":"𝔳","w":"𝔴","x":"𝔵","y":"𝔶","z":"𝔷"])
        let doubleStruck = map(t, with: ["a":"𝕒","b":"𝕓","c":"𝕔","d":"𝕕","e":"𝕖","f":"𝕗","g":"𝕘","h":"𝕙","i":"𝕚","j":"𝕛","k":"𝕜","l":"𝕝","m":"𝕞","n":"𝕟","o":"𝕠","p":"𝕡","q":"𝕢","r":"𝕣","s":"𝕤","t":"𝕥","u":"𝕦","v":"𝕧","w":"𝕨","x":"𝕩","y":"𝕪","z":"𝕫"])
        let fullWidth = map(t, with: ["a":"ａ","b":"ｂ","c":"ｃ","d":"ｄ","e":"ｅ","f":"ｆ","g":"ｇ","h":"ｈ","i":"ｉ","j":"ｊ","k":"ｋ","l":"ｌ","m":"ｍ","n":"ｎ","o":"ｏ","p":"ｐ","q":"ｑ","r":"ｒ","s":"ｓ","t":"ｔ","u":"ｕ","v":"ｖ","w":"ｗ","x":"ｘ","y":"ｙ","z":"ｚ"])
        let smallCaps = map(t, with: ["a":"ᴀ","b":"ʙ","c":"ᴄ","d":"ᴅ","e":"ᴇ","f":"ꜰ","g":"ɢ","h":"ʜ","i":"ɪ","j":"ᴊ","k":"ᴋ","l":"ʟ","m":"ᴍ","n":"ɴ","o":"ᴏ","p":"ᴘ","q":"ǫ","r":"ʀ","s":"ꜱ","t":"ᴛ","u":"ᴜ","v":"ᴠ","w":"ᴡ","x":"x","y":"ʏ","z":"ᴢ"])
        let bubble = map(t, with: ["a":"🅐","b":"🅑","c":"🅒","d":"🅓","e":"🅔","f":"🅕","g":"🅖","h":"🅗","i":"🅘","j":"🅙","k":"🅚","l":"🅛","m":"🅜","n":"🅝","o":"🅞","p":"🅟","q":"🅠","r":"🅡","s":"🅢","t":"🅣","u":"🅤","v":"🅥","w":"🅦","x":"🅧","y":"🅨","z":"🅩"])
        let circle = map(t, with: ["a":"ⓐ","b":"ⓑ","c":"ⓒ","d":"ⓓ","e":"ⓔ","f":"ⓕ","g":"ⓖ","h":"ⓗ","i":"ⓘ","j":"ⓙ","k":"ⓚ","l":"ⓛ","m":"ⓜ","n":"ⓝ","o":"ⓞ","p":"ⓟ","q":"ⓠ","r":"ⓡ","s":"ⓢ","t":"ⓣ","u":"ⓤ","v":"ⓥ","w":"ⓦ","x":"ⓧ","y":"ⓨ","z":"ⓩ"])
        
        // Additional Unicode styles
        let sansSerifBold = map(t, with: ["a":"𝗮","b":"𝗯","c":"𝗰","d":"𝗱","e":"𝗲","f":"𝗳","g":"𝗴","h":"𝗵","i":"𝗶","j":"𝗷","k":"𝗸","l":"𝗹","m":"𝗺","n":"𝗻","o":"𝗼","p":"𝗽","q":"𝗾","r":"𝗿","s":"𝘀","t":"𝘁","u":"𝘂","v":"𝘃","w":"𝘄","x":"𝘅","y":"𝘆","z":"𝘇"])
        let sansSerifItalic = map(t, with: ["a":"𝘢","b":"𝘣","c":"𝘤","d":"𝘥","e":"𝘦","f":"𝘧","g":"𝘨","h":"𝘩","i":"𝘪","j":"𝘫","k":"𝘬","l":"𝘭","m":"𝘮","n":"𝘯","o":"𝘰","p":"𝘱","q":"𝘲","r":"𝘳","s":"𝘴","t":"𝘵","u":"𝘶","v":"𝘷","w":"𝘸","x":"𝘹","y":"𝘺","z":"𝘻"])
        let doubleStruckBold = map(t, with: ["a":"𝕬","b":"𝕭","c":"𝕮","d":"𝕯","e":"𝕰","f":"𝕱","g":"𝕲","h":"𝕳","i":"𝕴","j":"𝕵","k":"𝕶","l":"𝕷","m":"𝕸","n":"𝕹","o":"𝕺","p":"𝕻","q":"𝕼","r":"𝕽","s":"𝕾","t":"𝕿","u":"𝖀","v":"𝖁","w":"𝖂","x":"𝖃","y":"𝖄","z":"𝖅"])
        let gothicBold = map(t, with: ["a":"𝖆","b":"𝖇","c":"𝖈","d":"𝖉","e":"𝖊","f":"𝖋","g":"𝖌","h":"𝖍","i":"𝖎","j":"𝖏","k":"𝖐","l":"𝖑","m":"𝖒","n":"𝖓","o":"𝖔","p":"𝖕","q":"𝖖","r":"𝖗","s":"𝖘","t":"𝖙","u":"𝖚","v":"𝖛","w":"𝖜","x":"𝖝","y":"𝖞","z":"𝖟"])
        let outline = map(t, with: ["a":"𝔸","b":"𝔹","c":"ℂ","d":"𝔻","e":"𝔼","f":"𝔽","g":"𝔾","h":"ℍ","i":"𝕀","j":"𝕁","k":"𝕂","l":"𝕃","m":"𝕄","n":"ℕ","o":"𝕆","p":"ℙ","q":"ℚ","r":"ℝ","s":"𝕊","t":"𝕋","u":"𝕌","v":"𝕍","w":"𝕎","x":"𝕏","y":"𝕐","z":"ℤ"])
        let monospace = map(t, with: ["a":"𝚊","b":"𝚋","c":"𝚌","d":"𝚍","e":"𝚎","f":"𝚏","g":"𝚐","h":"𝚑","i":"𝚒","j":"𝚓","k":"𝚔","l":"𝚕","m":"𝚖","n":"𝚗","o":"𝚘","p":"𝚙","q":"𝚚","r":"𝚛","s":"𝚜","t":"𝚝","u":"𝚞","v":"𝚟","w":"𝚠","x":"𝚡","y":"𝚢","z":"𝚣"])
        let boldItalic = map(t, with: ["a":"𝒂","b":"𝒃","c":"𝒄","d":"𝒅","e":"𝒆","f":"𝒇","g":"𝒈","h":"𝒉","i":"𝒊","j":"𝒋","k":"𝒌","l":"𝒍","m":"𝒎","n":"𝒏","o":"𝒐","p":"𝒑","q":"𝒒","r":"𝒓","s":"𝒔","t":"𝒕","u":"𝒖","v":"𝒗","w":"𝒘","x":"𝒙","y":"𝒚","z":"𝒛"])
        let circled = map(t, with: ["a":"ⓐ","b":"ⓑ","c":"ⓒ","d":"ⓓ","e":"ⓔ","f":"ⓕ","g":"ⓖ","h":"ⓗ","i":"ⓘ","j":"ⓙ","k":"ⓚ","l":"ⓛ","m":"ⓜ","n":"ⓝ","o":"ⓞ","p":"ⓟ","q":"ⓠ","r":"ⓡ","s":"ⓢ","t":"ⓣ","u":"ⓤ","v":"ⓥ","w":"ⓦ","x":"ⓧ","y":"ⓨ","z":"ⓩ"])
        let squared = map(t, with: ["a":"🄰","b":"🄱","c":"🄲","d":"🄳","e":"🄴","f":"🄵","g":"🄶","h":"🄷","i":"🄸","j":"🄹","k":"🄺","l":"🄻","m":"🄼","n":"🄽","o":"🄾","p":"🄿","q":"🅀","r":"🅁","s":"🅂","t":"🅃","u":"🅄","v":"🅅","w":"🅆","x":"🅇","y":"🅈","z":"🅉"])
        
        // Decorative templates
        var templates = [
            "💫 \(script) 💫",
            "♛ \(fraktur) ♛",
            "🔥 \(doubleStruck) 🔥",
            "⭐ \(smallCaps) ⭐",
            "🌈 \(fullWidth) 🌈",
            "💎 \(circle) 💎",
            "🦋 \(bubble) 🦋",
            "꧁༺\(script)༻꧂",
            "♡ \(fraktur) ♡",
            "♚ \(doubleStruck) ♚",
            "✿ \(script) ✿",
            "☯ \(fraktur) ☯",
            "★彡[\(smallCaps)]彡★",
            "⚜️ \(script) ⚜️",
            "🌹 \(bubble) 🌹",
            "🍀 \(circle) 🍀",
            "🎶 \(doubleStruck) 🎶",
            "🖤 \(fraktur) 🖤",
            "🕊️ \(script) 🕊️",
            "✨『\(doubleStruck)』✨",
            "💥《\(script)》💥",
            "🦄💫 \(smallCaps) 💫🦄",
            "🌸 \(bubble) 🌸",
            "🎵 \(fraktur) 🎵",
            "💘 \(doubleStruck) 💘",
            "👑 \(script) 👑",
            "☠️ \(smallCaps) ☠️",
            "🦋『\(circle)』🦋",
            "🔥💫 \(fraktur) 💫🔥",
            "💖 \(doubleStruck) 💖",
            "✨꧁༺\(bubble)༻꧂✨",
            "🌺•°¤*(¯`★´¯)*¤°•🌺 \(script) 🌺•°¤*(¯`★´¯)*¤°•🌺",
            "🪩 \(smallCaps) 🪩",
            "💫 \(fraktur) 💫",
            "🌼 \(doubleStruck) 🌼",
            "☾ \(script) ☽",
            "🍁 \(bubble) 🍁",
            "🦋 \(circle) 🦋",
            "💎 \(smallCaps) 💎",
            "🔥 \(fraktur) 🔥",
            "🌈 \(script) 🌈",
            "⭐ \(doubleStruck) ⭐",
            "✨ \(smallCaps) ✨",
            "♛ \(circle) ♛",
            "💞 \(bubble) 💞",
            "🌹 \(fraktur) 🌹",
            "💫 \(doubleStruck) 💫",
            "💥 \(script) 💥",
            "🍀 \(smallCaps) 🍀",
            "⚡ \(circle) ⚡",
            "🌟 \(bubble) 🌟",
            "💫 \(sansSerifBold) 💫",
            "✨『\(sansSerifItalic)』✨",
            "꧁༺\(doubleStruckBold)༻꧂",
            "🌹 \(gothicBold) 🌹",
            "🦋 \(outline) 🦋",
            "⚡ \(monospace) ⚡",
            "🔥《\(boldItalic)》🔥",
            "🍀 \(circled) 🍀",
            "⭐ \(squared) ⭐"
        ]
        
        // Helper arrays of style mappings for mixing
        let stylesArrays: [[Character: String]] = [
            ["a":"𝒶","b":"𝒷","c":"𝒸","d":"𝒹","e":"ℯ","f":"𝒻","g":"𝓰","h":"𝒽","i":"𝒾","j":"𝒿","k":"𝓀","l":"𝓁","m":"𝓂","n":"𝓃","o":"𝓸","p":"𝓅","q":"𝓆","r":"𝓇","s":"𝓈","t":"𝓉","u":"𝓊","v":"𝓋","w":"𝓌","x":"𝓍","y":"𝓎","z":"𝓏"], // script
            ["a":"𝔞","b":"𝔟","c":"𝔠","d":"𝔡","e":"𝔢","f":"𝔣","g":"𝔤","h":"𝔥","i":"𝔦","j":"𝔧","k":"𝔨","l":"𝔩","m":"𝔪","n":"𝔫","o":"𝔬","p":"𝔭","q":"𝔮","r":"𝔯","s":"𝔰","t":"𝔱","u":"𝔲","v":"𝔳","w":"𝔴","x":"𝔵","y":"𝔶","z":"𝔷"], // fraktur
            ["a":"𝕒","b":"𝕓","c":"𝕔","d":"𝕕","e":"𝕖","f":"𝕗","g":"𝕘","h":"𝕙","i":"𝕚","j":"𝕛","k":"𝕜","l":"𝕝","m":"𝕞","n":"𝕟","o":"𝕠","p":"𝕡","q":"𝕢","r":"𝕣","s":"𝕤","t":"𝕥","u":"𝕦","v":"𝕧","w":"𝕨","x":"𝕩","y":"𝕪","z":"𝕫"], // doubleStruck
            ["a":"𝖆","b":"𝖇","c":"𝖈","d":"𝖉","e":"𝖊","f":"𝖋","g":"𝖌","h":"𝖍","i":"𝖎","j":"𝖏","k":"𝖐","l":"𝖑","m":"𝖒","n":"𝖓","o":"𝖔","p":"𝖕","q":"𝖖","r":"𝖗","s":"𝖘","t":"𝖙","u":"𝖚","v":"𝖛","w":"𝖜","x":"𝖝","y":"𝖞","z":"𝖟"], // gothicBold
            ["a":"ⓐ","b":"ⓑ","c":"ⓒ","d":"ⓓ","e":"ⓔ","f":"ⓕ","g":"ⓖ","h":"ⓗ","i":"ⓘ","j":"ⓙ","k":"ⓚ","l":"ⓛ","m":"ⓜ","n":"ⓝ","o":"ⓞ","p":"ⓟ","q":"ⓠ","r":"ⓡ","s":"ⓢ","t":"ⓣ","u":"ⓤ","v":"ⓥ","w":"ⓦ","x":"ⓧ","y":"ⓨ","z":"ⓩ"], // circle
            ["a":"🅐","b":"🅑","c":"🅒","d":"🅓","e":"🅔","f":"🅕","g":"🅖","h":"🅗","i":"🅘","j":"🅙","k":"🅚","l":"🅛","m":"🅜","n":"🅝","o":"🅞","p":"🅟","q":"🅠","r":"🅡","s":"🅢","t":"🅣","u":"🅤","v":"🅥","w":"🅦","x":"🅧","y":"🅨","z":"🅩"], // bubble
            ["a":"𝔸","b":"𝔹","c":"ℂ","d":"𝔻","e":"𝔼","f":"𝔽","g":"𝔾","h":"ℍ","i":"𝕀","j":"𝕁","k":"𝕂","l":"𝕃","m":"𝕄","n":"ℕ","o":"𝕆","p":"ℙ","q":"ℚ","r":"ℝ","s":"𝕊","t":"𝕋","u":"𝕌","v":"𝕍","w":"𝕎","x":"𝕏","y":"𝕐","z":"ℤ"], // outline
            ["a":"🄰","b":"🄱","c":"🄲","d":"🄳","e":"🄴","f":"🄵","g":"🄶","h":"🄷","i":"🄸","j":"🄹","k":"🄺","l":"🄻","m":"🄼","n":"🄽","o":"🄾","p":"🄿","q":"🅀","r":"🅁","s":"🅂","t":"🅃","u":"🅄","v":"🅅","w":"🅆","x":"🅇","y":"🅈","z":"🅉"] // squared
        ]
        
        func mixedStyleText(_ text: String) -> String {
            var result = ""
            let lowerText = text.lowercased()
            for ch in lowerText {
                if ch == " " {
                    result.append(" ")
                    continue
                }
                var candidates = [String]()
                for styleDict in stylesArrays {
                    if let styledChar = styleDict[ch] {
                        candidates.append(styledChar)
                    }
                }
                if candidates.isEmpty {
                    result.append(String(ch))
                } else {
                    result.append(candidates.randomElement() ?? String(ch))
                }
            }
            return result
        }
        
        let decorations = [
            ("💫 ", " 💫"),
            ("✨ ", " ✨"),
            ("꧁༺", "༻꧂"),
            ("🌹 ", " 🌹"),
            ("🔥 ", " 🔥"),
            ("🦋 ", " 🦋"),
            ("⚡ ", " ⚡"),
            ("🌈 ", " 🌈"),
            ("🍀 ", " 🍀"),
            ("💖 ", " 💖"),
            ("★彡[", "]彡★"),
            ("🪩 ", " 🪩"),
            ("☯ ", " ☯"),
            ("🕊️ ", " 🕊️"),
            ("☠️ ", " ☠️"),
            ("🎵 ", " 🎵"),
            ("🎶 ", " 🎶"),
            ("💥《", "》💥"),
            ("✨『", "』✨"),
            ("♡ ", " ♡")
        ]
        
        for _ in 0..<100 {
            let mixed = mixedStyleText(t)
            let deco = decorations.randomElement() ?? ("", "")
            let styled = "\(deco.0)\(mixed)\(deco.1)"
            templates.append(styled)
        }
        
        return templates
    }
    
    private static func map(_ text: String, with dict: [Character:String]) -> String {
        return text.lowercased().map { dict[$0] ?? String($0) }.joined()
    }
}
