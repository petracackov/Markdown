//
//  NSAttributedString+TextEditing.swift
//  GIDMarkdown
//
//  Created by Petra Cackov on 08/04/2022.
//

import UIKit

extension NSAttributedString {

    // MARK: - Ranges

    var fullRange: NSRange {
        return NSRange(string.startIndex..<string.endIndex, in: string)
    }

    /// returns all ranges in attributed string, at given range, without specific attribute. If range is nil fullRange is used
    func rangesWithMissingAttribute(for key: Key, in range: NSRange? = nil) -> [NSRange] {
        let stringRange = range ?? fullRange
        var ranges = [NSRange]()
        enumerateAttribute(key, in: stringRange, options: []) { value, range, _ in
            if value == nil {
                ranges.append(range)
            }
        }
        return ranges
    }

    // MARK: - Enumerate attributes

    func forEachAttribute<A>(withKey key: NSAttributedString.Key, in range: NSRange? = nil, action: (_ attribute: A, _ range: NSRange) -> Void) {
        let range = range ?? fullRange
        enumerateAttribute(key, in: range) { attribute, range, _ in
            if let value = attribute as? A {
                action(value, range)
            }
        }
    }

    func forEachAttributeGroup(in range: NSRange? = nil, action: (_ attributes: [NSAttributedString.Key: Any], _ range: NSRange) -> Void) {
        let range = range ?? fullRange
        enumerateAttributes(in: range) { attributes, range, _ in
            action(attributes, range)
        }
    }

    // MARK: - lines

    /// If cursor is at the beginning of line, and no text is selected
    /// - Parameter range: provided range.
    /// - Returns: range off line that provided range is at the beginning of. If provided range is a selection (has length greater than 0) nil is returned
    private func beginningOfLine(range: NSRange) -> NSRange? {
        guard range.length == 0 else { return nil }
        let allLineRangesLocations = self.lineRanges()
        return allLineRangesLocations.first { $0.location  == range.location }
    }

    /// If cursor is at the beginning of line, and no text is selected
    func isBeginningOfLine(range: NSRange) -> Bool {
        return beginningOfLine(range: range) != nil
    }

    /// returns the range of last line if cursor is at the end of text and no text is selected
    private func endOfString(range: NSRange) -> NSRange? {
        guard range.length == 0 else { return nil }
        guard range.location == fullRange.length else { return nil }
        // There is no new line generated if there is an empty new line at the end of string
        if string.last == "\n" {
            return range
        } else {
            return self.lineRanges().last
        }
    }

    /// returns ranges of lines that are within the given range
    func linesOfRange(range: NSRange) -> [NSRange] {
        let allLineRanges = self.lineRanges()
        var lines = allLineRanges.filter { (range.location < $0.location + $0.length) && (range.location + range.length > $0.location) }
        if let line = beginningOfLine(range: range) {
            lines.append(line)
        } else if let endLine = endOfString(range: range) {
            lines.append(endLine)
        }
        return lines.sorted { $0.location < $1.location }
    }

    /// returns ranges of all lines in attributed string
    func lineRanges() -> [NSRange] {
        guard self.length > 0 else { return [] }

        func nextLineRange(at location: Int) -> NSRange {
            return NSString(string: self.string).lineRange(for: NSRange(location: location, length: 1))
        }

        var result = [nextLineRange(at: 0)]

        while let currentLocation = result.last?.upperBound, currentLocation < self.length {
            result.append(nextLineRange(at: currentLocation))
        }

        return result
    }

    // MARK: - Link detection

    /// returns ranges of all detected URL links
    func detectedURLRanges() -> [NSRange] {
        let linkDetector: NSDataDetector? = {
            let types: NSTextCheckingResult.CheckingType = [.link]
            return try? NSDataDetector(types: types.rawValue)
        }()
        guard let detector = linkDetector else { return [] }

        var detectedRanges: [NSRange] = []
        detector.enumerateMatches(in: string, options: [], range: fullRange, using: { match, _, _ in
            guard let match = match, match.resultType == .link, match.url != nil else {
                return
            }

            detectedRanges.append(match.range)
        })

        return detectedRanges
    }

    // MARK: - General

    /// Returns a sub string, up to the specified length.
    func prefix(with length: Int) -> NSAttributedString {
        guard length <= self.length else { return self }
        guard length > 0 else { return NSAttributedString() }
        return attributedSubstring(from: NSRange(location: 0, length: length))
    }

    /// if range is nil fullRange of string is used
    func allFontsContainTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange? = nil) -> Bool {
        var hasTraits = true
        var hasFonts = false
        let fullRange = range ?? fullRange
        forEachAttribute(withKey: .font, in: fullRange) { (font: UIFont, _) in
            hasFonts = true
            if !font.hasTrait(trait) {
                hasTraits = false
            }
        }
        return hasTraits && hasFonts
    }

}
