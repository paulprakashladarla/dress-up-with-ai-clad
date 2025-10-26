
//
//  SuggestionEngine.swift
//  dress up with ai
//
//  Created by paulprakash ladarla on 26/09/25.
//

import Foundation
import UIKit
import CoreData

struct Outfit {
    let top: ClothingItem
    let bottom: ClothingItem
    let shoes: ClothingItem?
}

class SuggestionEngine {
    func generateOutfit(from items: [ClothingItem], for occasion: String) -> Outfit? {
        let tops = items.filter { $0.category == "Top" }
        let bottoms = items.filter { $0.category == "Bottom" }
        let shoes = items.filter { $0.category == "Shoes" }

        guard !tops.isEmpty, !bottoms.isEmpty else { return nil }

        // Simple suggestion logic: pick a random top and find a complementary bottom.
        let randomTop = tops.randomElement()!
        
        if let complementaryBottom = findComplementaryItem(for: randomTop, in: bottoms) {
            return Outfit(top: randomTop, bottom: complementaryBottom, shoes: shoes.randomElement())
        } else {
            // Fallback to a random bottom if no complementary one is found
            return Outfit(top: randomTop, bottom: bottoms.randomElement()!, shoes: shoes.randomElement())
        }
    }

    private func findComplementaryItem(for item: ClothingItem, in allItems: [ClothingItem]) -> ClothingItem? {
        guard let colorHex = item.primaryColorHex else { return nil }
        let sourceColor = UIColor(hex: colorHex)
        let complementaryColor = sourceColor.complementary

        var bestMatch: ClothingItem? = nil
        var smallestDistance: CGFloat = .greatestFiniteMagnitude

        for potentialMatch in allItems {
            guard let matchColorHex = potentialMatch.primaryColorHex else { continue }
            let matchColor = UIColor(hex: matchColorHex)
            let distance = complementaryColor.cgColor.distance(to: matchColor.cgColor)

            if distance < smallestDistance {
                smallestDistance = distance
                bestMatch = potentialMatch
            }
        }
        return bestMatch
    }
}

// UIColor and CGColor extensions for color calculations

extension UIColor {
    var complementary: UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        hue += 0.5
        if hue > 1.0 { hue -= 1.0 }

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension CGColor {
    func distance(to otherColor: CGColor) -> CGFloat {
        guard let c1 = self.components, let c2 = otherColor.components else { return .greatestFiniteMagnitude }
        let r1 = c1[0]
        let g1 = c1[1]
        let b1 = c1[2]
        
        let r2 = c2[0]
        let g2 = c2[1]
        let b2 = c2[2]
        
        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
    }
}
