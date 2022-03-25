//
//  Extensions.swift
//  Markdown
//
//  Created by Petra Cackov on 07/03/2022.
//

import UIKit


// MARK: - Helper Extensions

private extension NSParagraphStyle {
//
//    func indented(by indentation: CGFloat) -> NSParagraphStyle {
//        guard let result = mutableCopy() as? NSMutableParagraphStyle else { return self }
//        result.firstLineHeadIndent += indentation
//        result.headIndent += indentation
//
//        result.tabStops = tabStops.map {
//            NSTextTab(textAlignment: $0.alignment, location: $0.location + indentation, options: $0.options)
//        }
//
//        return result
//    }
//
//    func inset(by amount: CGFloat) -> NSParagraphStyle {
//        guard let result = mutableCopy() as? NSMutableParagraphStyle else { return self }
//        result.paragraphSpacingBefore += amount
//        result.paragraphSpacing += amount
//        result.firstLineHeadIndent += amount
//        result.headIndent += amount
//        result.tailIndent = -amount
//        return result
//    }

}

extension NSMutableAttributedString {

    func setAttributes(_ attrs: [Key: Any]) {
        setAttributes(attrs, range: fullRange)
    }

    func addAttribute(for key: Key, value: Any) {
        addAttribute(key, value: value, range: fullRange)
    }

    func addAttributes(_ attrs: [Key: Any]) {
        addAttributes(attrs, range: fullRange)
    }

    func updateExistingAttributes<A>(for key: Key, using transform: (A) -> A) {
        updateExistingAttributes(for: key, in: fullRange, using: transform)
    }

    func updateExistingAttributes<A>(for key: Key, in range: NSRange, using transform: (A) -> A) {
        var existingValues = [(value: A, range: NSRange)]()
        enumerateAttributes(for: key, in: range) { existingValues.append(($0, $1)) }
        existingValues.forEach { addAttribute(key, value: transform($0.0), range: $0.1) }
    }

    func addAttributesToRanges(attributes: [NSAttributedString.Key: Any], ranges: [NSRange]) {
        ranges.forEach { paragraphRange in
            self.addAttributes(attributes, range: paragraphRange)
        }
    }
//    
//    func removeAttribute(for key: Key) {
//        removeAttribute(key, range: wholeRange)
//    }
//    
//    func replaceAttribute(for key: Key, value: Any) {
//        replaceAttribute(for: key, value: value, inRange: wholeRange)
//    }
//    
//    func replaceAttribute(for key: Key, value: Any, inRange range: NSRange) {
//        removeAttribute(key, range: range)
//        addAttribute(key, value: value, range: range)
//    }
//    
//
//    func addAttributeInMissingRanges<A>(for key: Key, value: A) {
//        addAttributeInMissingRanges(for: key, value: value, within: wholeRange)
//    }
//
//    func addAttributeInMissingRanges<A>(for key: Key, value: A, within range: NSRange) {
//        rangesMissingAttribute(for: key, in: range).forEach {
//            addAttribute(key, value: value, range: $0)
//        }
//    }
//    public func trimCharactersInSet(charSet: CharacterSet) {
//        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)
//
//        // Trim leading characters from character set.
//        while range.length != 0 && range.location == 0 {
//            replaceCharacters(in: range, with: "")
//            range = (string as NSString).rangeOfCharacter(from: charSet)
//        }
//
//        // Trim trailing characters from character set.
//        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
//        while range.length != 0 && NSMaxRange(range) == length {
//            replaceCharacters(in: range, with: "")
//            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
//        }
//    }
//
//    func addAttribute(_ key: NSAttributedString.Key, value: Any) {
//        self.addAttribute(key, value: value, range: fullRange)
//    }
}

extension UIFont {

    var isStrong: Bool {
        return contains(.strong)
    }

    var isEmphasized: Bool {
        return contains(.emphasis)
    }

    var strong: UIFont {
        return with(.strong) ?? self
    }

    var emphasis: UIFont {
        return with(.emphasis) ?? self
    }
    private func with(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard !contains(trait) else { return self }

        var traits = fontDescriptor.symbolicTraits
        traits.insert(trait)

        guard let newDescriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }

    private func contains(_ trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        return fontDescriptor.symbolicTraits.contains(trait)
    }

}

private extension UIFontDescriptor.SymbolicTraits {

    static let strong = UIFontDescriptor.SymbolicTraits.traitBold
    static let emphasis = UIFontDescriptor.SymbolicTraits.traitItalic

}

extension NSAttributedString {

    typealias Attributes = [NSAttributedString.Key: Any]

    // MARK: - Ranges

//    var wholeRange: NSRange {
//        return NSRange(location: 0, length: length)
//    }

    var fullRange: NSRange {
        return NSRange(string.startIndex..<string.endIndex, in: string)
    }

//    func ranges(of key: Key) -> [NSRange] {
//        return ranges(of: key, in: wholeRange)
//    }
//
//    func ranges(of key: Key, in range: NSRange) -> [NSRange] {
//        return ranges(for: key, in: range, where: { $0 != nil })
//    }
//
//    func rangesMissingAttribute(for key: Key) -> [NSRange] {
//        return rangesMissingAttribute(for: key, in: wholeRange)
//    }
//
//    func rangesMissingAttribute(for key: Key, in range: NSRange) -> [NSRange] {
//        return ranges(for: key, in: range, where: { $0 == nil })
//    }
//
//    private func ranges(for key: Key, in range: NSRange, where predicate: (Any?) -> Bool) -> [NSRange] {
//        var ranges = [NSRange]()
//
//        enumerateAttribute(key, in: range, options: []) { value, attrRange, _ in
//            if predicate(value) {
//                ranges.append(attrRange)
//            }
//        }
//
//        return ranges
//    }

    func paragraphsOfRange(range: NSRange) -> [NSRange] {
        let allParagraphRanges = self.paragraphRanges()
        return allParagraphRanges.filter { (range.location <= $0.location + $0.length) && (range.location + range.length > $0.location) }
    }

    func paragraphRanges() -> [NSRange] {
        guard self.length > 0 else { return [] }

        func nextParagraphRange(at location: Int) -> NSRange {
            return NSString(string: self.string).paragraphRange(for: NSRange(location: location, length: 1))
        }

        var result = [nextParagraphRange(at: 0)]

        while let currentLocation = result.last?.upperBound, currentLocation < self.length {
            result.append(nextParagraphRange(at: currentLocation))
        }

        return result.filter { $0.length > 1 }
    }
    

    // MARK: - Enumerate attributes

    func enumerateAttributes<A>(for key: Key, block: (_ attr: A, _ range: NSRange) -> Void) {
        enumerateAttributes(for: key, in: fullRange, block: block)
    }

    func enumerateAttributes<A>(for key: Key, in range: NSRange, block: (_ attr: A, _ range: NSRange) -> Void) {
        enumerateAttribute(key, in: range, options: []) { value, range, _ in
            if let value = value as? A {
                block(value, range)
            }
        }
    }

//    public func attributedStringByTrimmingCharacterSet(charSet: CharacterSet) -> NSAttributedString {
//        let modifiedString = NSMutableAttributedString(attributedString: self)
//        modifiedString.trimCharactersInSet(charSet: charSet)
//        return NSAttributedString(attributedString: modifiedString)
//    }
//



//MARK: - Ranges
//
//
//    func ranges(of key: Key) -> [NSRange] {
//        return ranges(of: key, in: wholeRange)
//    }
//
//    func ranges(of key: Key, in range: NSRange) -> [NSRange] {
//        return ranges(for: key, in: range, where: { $0 != nil })
//    }
//
//    func rangesMissingAttribute(for key: Key) -> [NSRange] {
//        return rangesMissingAttribute(for: key, in: wholeRange)
//    }
//
//    func rangesMissingAttribute(for key: Key, in range: NSRange) -> [NSRange] {
//        return ranges(for: key, in: range, where: { $0 == nil })
//    }
//
//    private func ranges(for key: Key, in range: NSRange, where predicate: (Any?) -> Bool) -> [NSRange] {
//        var ranges = [NSRange]()
//
//        enumerateAttribute(key, in: range, options: []) { value, attrRange, _ in
//            if predicate(value) {
//                ranges.append(attrRange)
//            }
//        }
//
//        return ranges
//    }
//
//    func paragraphRanges() -> [NSRange] {
//        guard length > 0 else { return [] }
//
//        func nextParagraphRange(at location: Int) -> NSRange {
//            return NSString(string: string).paragraphRange(for: NSRange(location: location, length: 1))
//        }
//
//        var result = [nextParagraphRange(at: 0)]
//
//        while let currentLocation = result.last?.upperBound, currentLocation < length {
//            result.append(nextParagraphRange(at: currentLocation))
//        }
//
//        return result.filter { $0.length > 1 }
//    }
//
    func prefix(length: Int) -> NSAttributedString {
        guard length <= self.length else { return self }
        guard length > 0 else { return NSAttributedString() }
        return attributedSubstring(from: NSRange(location: 0, length: length))
    }

}
