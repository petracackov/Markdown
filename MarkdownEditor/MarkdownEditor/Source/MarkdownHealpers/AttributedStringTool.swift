//
//  AttributedStringTool.swift
//  Markdown
//
//  Created by Petra Cackov on 07/03/2022.
//

import UIKit

class AttributedStringTool: UIView {

    static private let linkDetector: NSDataDetector? = {
        let types: NSTextCheckingResult.CheckingType = [.link]
        return try? NSDataDetector(types: types.rawValue)
    }()

    static func detectedURLRanges(in string: NSAttributedString) -> [NSRange] {
        guard let detector = linkDetector else { return [] }

        var detectedRanges: [NSRange] = []
        detector.enumerateMatches(in: string.string, options: [], range: string.fullRange, using: { match, _, _ in
            guard let match = match, match.resultType == .link, match.url != nil else {
                return
            }

            detectedRanges.append(match.range)
        })

        return detectedRanges
    }

    static func addTrait(_ trait: UIFontDescriptor.SymbolicTraits, to attributedString: NSMutableAttributedString, in range: NSRange, defaultFont: UIFont) {
        addMissingFontTo(attributedString, font: defaultFont)
        forEachAttribute(in: attributedString, withKey: .font, in: range) { (font: UIFont, range) in
            let newFont = fontByAddingTrait(trait, to: font)
            attributedString.addAttribute(.font, value: newFont, range: range)
        }
    }

    static func addMissingFontTo(_ attributedString: NSMutableAttributedString, font: UIFont) {
        let rangesWithoutFont = attributedString.rangesMissingAttribute(for: .font)
        rangesWithoutFont.forEach {
            attributedString.addAttribute(.font, value: font, range: $0)
        }
    }

    static func addMissingParagraphTo(_ attributedString: NSMutableAttributedString, paragraph: NSParagraphStyle) {
        let rangesWithoutFont = attributedString.rangesMissingAttribute(for: .paragraphStyle)
        rangesWithoutFont.forEach {
            attributedString.addAttribute(.paragraphStyle, value: paragraph, range: $0)
        }
    }

    static private func removeTrait(_ trait: UIFontDescriptor.SymbolicTraits, from attributedString: NSMutableAttributedString, in range: NSRange) {
        forEachAttribute(in: attributedString, withKey: .font, in: range) { (font: UIFont, range) in
            let newFont = fontByRemovingTrait(trait, to: font)
            attributedString.addAttribute(.font, value: newFont, range: range)
        }
    }

    static func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, to attributedString: NSMutableAttributedString, in range: NSRange, defaultFont: UIFont) {
        if allFontsContainTrait(trait, attributedString: attributedString, in: range) {
            removeTrait(trait, from: attributedString, in: range)
        } else {
            addTrait(trait, to: attributedString, in: range, defaultFont: defaultFont)
        }
    }

    static private func fontByAddingTrait(_ trait: UIFontDescriptor.SymbolicTraits, to font: UIFont) -> UIFont {
        var traits = font.fontDescriptor.symbolicTraits
        guard !traits.contains(trait) else { return font }
        traits.insert(trait)

        guard let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return font }
        return UIFont(descriptor: newDescriptor, size: font.pointSize)
    }

    static private func fontByRemovingTrait(_ trait: UIFontDescriptor.SymbolicTraits, to font: UIFont) -> UIFont {
        var traits = font.fontDescriptor.symbolicTraits
        guard traits.contains(trait) else { return font }
        traits.remove(trait)

        guard let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return font }
        return UIFont(descriptor: newDescriptor, size: font.pointSize)
    }

    static private func fontHasTrait(_ trait: UIFontDescriptor.SymbolicTraits, font: UIFont) -> Bool {
        let traits = font.fontDescriptor.symbolicTraits
        return traits.contains(trait)
    }
//
//    static func forEachFontIn(attributedString: NSAttributedString, in range: NSRange, action: (_ font: UIFont, _ range: NSRange) -> Void) {
//        attributedString.enumerateAttribute(.font, in: range) { value, range, stop in
//            if let font = value as? UIFont {
//                action(font, range)
//            }
//        }
//    }
//
    static func forEachAttribute<A>(in attributedString: NSAttributedString, withKey key: NSAttributedString.Key, in range: NSRange? = nil, action: (_ attribute: A, _ range: NSRange) -> Void) {
        let range = range ?? attributedString.fullRange
        attributedString.enumerateAttribute(key, in: range) { attribute, range, _ in
            if let value = attribute as? A {
                action(value, range)
            }
        }
    }

    static func forEachAttributeGroup(in attributedString: NSAttributedString, in range: NSRange? = nil, action: (_ attributes: [NSAttributedString.Key : Any], _ range: NSRange) -> Void) {
        let range = range ?? attributedString.fullRange
        attributedString.enumerateAttributes(in: range) { attributes, range, _ in
            action(attributes, range)
        }
    }

    static func allFontsContainTrait(_ trait: UIFontDescriptor.SymbolicTraits, attributedString: NSAttributedString, in range: NSRange? = nil) -> Bool {
        var hasTraits = true
        var hasFonts = false
        let fullRange = range ?? attributedString.fullRange
        forEachAttribute(in: attributedString, withKey: .font, in: fullRange) { (font: UIFont, range) in
            hasFonts = true
            if !fontHasTrait(trait, font: font) {
                hasTraits = false
            }
        }
        return hasTraits && hasFonts
    }


//
//    static func rangesForTrait(_ trait: UIFontDescriptor.SymbolicTraits, in attributedString: NSAttributedString) -> [NSRange] {
//        var ranges: [NSRange] = []
//        forEachFontIn(attributedString: attributedString, in: attributedString.fullRangee) { font, range in
//            if fontHasTrait(trait, font: font) {
//                ranges.append(range)
//            }
//        }
//        return ranges
//    }
//
//    static func rangesForAttributes(in attributedString: NSAttributedString) -> [NSRange] {
//        var ranges = [NSRange]()
//        forEachAttribute(in: attributedString) { attribute, range in
//            ranges.append(range)
//        }
//        return ranges
//    }
//
//    static func updateExistingAttributes<A>(in str: NSMutableAttributedString, for key: NSAttributedString.Key, in range: NSRange, using transform: (A) -> A) {
//        var existingValues = [(value: A, range: NSRange)]()
//        forEachAttribute(in: str, with: key)  { existingValues.append(($0, $1)) }
//        existingValues.forEach { str.addAttribute(key, value: transform($0.value), range: $0.range) }
//    }
//
//    static func rangesMissingAttribute(in str: NSAttributedString, for key: NSAttributedString.Key, in range: NSRange) -> [NSRange] {
//        var ranges = [NSRange]()
//        str.enumerateAttribute(key, in: range, options: []) { value, range, _ in
//            if  value == nil {
//                ranges.append(range)
//            }
//        }
//
//        return ranges
//    }

}
