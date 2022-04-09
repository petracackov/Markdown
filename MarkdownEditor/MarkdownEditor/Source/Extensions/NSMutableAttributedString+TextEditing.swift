//
//  NSMutableAttributedString+TextEditing.swift
//  GIDMarkdown
//
//  Created by Petra Cackov on 08/04/2022.
//

import UIKit

extension NSMutableAttributedString {

    /// replaces existing attributes with the new ones
    func setAttributes(_ attributes: [Key: Any]) {
        setAttributes(attributes, range: fullRange)
    }

    /// adds the attributes to existing attributes
    func addAttributes(_ attributes: [Key: Any]) {
        addAttributes(attributes, range: fullRange)
    }

    /// adds the attribute to existing attributes
    func addAttribute(for key: Key, value: Any) {
        addAttribute(key, value: value, range: fullRange)
    }

    /// replaces all attributes with the new ones at the corresponding ranges
    func setAttributesToRanges(attributes: [NSAttributedString.Key: Any], ranges: [NSRange]) {
        ranges.forEach { paragraphRange in
            self.setAttributes(attributes, range: paragraphRange)
        }
    }

    /// adds font to ranges with missing font attribute
    func addMissingFont(_ font: UIFont) {
        let rangesWithoutFont = rangesWithMissingAttribute(for: .font)
        rangesWithoutFont.forEach {
            addAttribute(.font, value: font, range: $0)
        }
    }

    /// adds paragraph to ranges with missing paragraph attribute
    func addMissingParagraph(_ paragraph: NSParagraphStyle) {
        let rangesWithoutParagraph = rangesWithMissingAttribute(for: .paragraphStyle)
        rangesWithoutParagraph.forEach {
            addAttribute(.paragraphStyle, value: paragraph, range: $0)
        }
    }

    func addFontTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange? = nil, defaultFont: UIFont) {
        let stringRange = range ?? fullRange
        addMissingFont(defaultFont)
        forEachAttribute(withKey: .font, in: stringRange) { (font: UIFont, range) in
            let newFont = font.addingTrait(trait)
            addAttribute(.font, value: newFont, range: range)
        }
    }

    func removeFontTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange) {
        forEachAttribute(withKey: .font, in: range) { (font: UIFont, range) in
            let newFont = font.removingTrait(trait)
            addAttribute(.font, value: newFont, range: range)
        }
    }

    func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange? = nil, defaultFont: UIFont) {
        let stringRange = range ?? fullRange
        if allFontsContainTrait(trait, in: stringRange) {
            removeFontTrait(trait, in: stringRange)
        } else {
            addFontTrait(trait, in: stringRange, defaultFont: defaultFont)
        }
    }
}
