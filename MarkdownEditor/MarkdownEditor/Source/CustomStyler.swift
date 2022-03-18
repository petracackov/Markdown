//
//  CustomStyler.swift
//  Markdown
//
//  Created by Petra Cackov on 18/03/2022.
//

import UIKit
import Down

class CustomStyler: DownStyler {

//
//    let listItemOptions = MarkdownStyles.listItemOptions


//    var largestPrefixWidth: CGFloat {
//        let prefixFont = MarkdownStyles.fontCollection.listItemPrefix
//        return widthOfNumberedPrefix(digits: listItemOptions.maxPrefixDigits, for: prefixFont)
//    }
//
//    public var indentation: CGFloat {
//        return largestPrefixWidth + listItemOptions.spacingAfterPrefix
//    }
//
//    private var baseStyle: NSMutableParagraphStyle {
//        let style = NSMutableParagraphStyle()
//        style.paragraphSpacingBefore = listItemOptions.spacingAbove
//        style.paragraphSpacing = listItemOptions.spacingBelow
//        return style
//    }

    private let itemParagraphStyler = MarkdownStyles.itemParagraphStyler

    override func style(item str: NSMutableAttributedString, prefixLength: Int) {

        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: str.fullRange)
    }

    private func indentListItemLeadingParagraph(in str: NSMutableAttributedString,
                                                prefixLength: Int,
                                                in range: NSRange) {

        let attributedPrefix = prefix(in: str, with: prefixLength)
        let prefixWidth = attributedPrefix.size().width

        let defaultStyle = itemParagraphStyler.leadingParagraphStyle(prefixWidth: prefixWidth)
        AttributedStringTool.forEachAttribute(in: str) { attribute, range in
            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
        }
    }

    private func prefix(in string: NSAttributedString, with length: Int) -> NSAttributedString {
        guard length <= string.length else { return string }
        guard length > 0 else { return NSAttributedString() }
        return string.attributedSubstring(from: NSRange(location: 0, length: length))
    }

//    override func style(item str: NSMutableAttributedString, prefixLength: Int) {
//
//        let paragraphRanges = paragraphRanges(in: str)
//
//        guard let leadingParagraphRange = paragraphRanges.first else { return }
//
//        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: leadingParagraphRange)
//
////        paragraphRanges.dropFirst().forEach {
////            indentListItemTrailingParagraph(in: str, inRange: $0)
////        }
//    }

//    private func indentListItemLeadingParagraph(in str: NSMutableAttributedString,
//                                                prefixLength: Int,
//                                                in range: NSRange) {
//
//        // not really needed since we do not support multiple partagraphs
//        AttributedStringTool.updateExistingAttributes(in: str, for: .paragraphStyle, in: range) { (existingStyle: NSParagraphStyle) in
//            indent(existingStyle, by: itemParagraphStyler.indentation)
//        }
//
//        let attributedPrefix = prefix(in: str, with: prefixLength)
//        let prefixWidth = attributedPrefix.size().width
//
//        let defaultStyle = itemParagraphStyler.leadingParagraphStyle(prefixWidth: prefixWidth)
//        AttributedStringTool.rangesMissingAttribute(in: str, for: .paragraphStyle, in: range).forEach { range in
//            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
//        }
//    }

//    func paragraphRanges(in str: NSAttributedString) -> [NSRange] {
//        guard str.length > 0 else { return [] }
//
//        func nextParagraphRange(at location: Int) -> NSRange {
//            return NSString(string: str.string).paragraphRange(for: NSRange(location: location, length: 1))
//        }
//
//        var result = [nextParagraphRange(at: 0)]
//
//        while let currentLocation = result.last?.upperBound, currentLocation < str.length {
//            result.append(nextParagraphRange(at: currentLocation))
//        }
//
//        return result.filter { $0.length > 1 }
//    }
//
//    func indent(_ style: NSParagraphStyle, by indentation: CGFloat) -> NSParagraphStyle {
//        guard let result = style.mutableCopy() as? NSMutableParagraphStyle else { return style }
//        result.firstLineHeadIndent += indentation
//        result.headIndent += indentation
//
//        result.tabStops = style.tabStops.map {
//            NSTextTab(textAlignment: $0.alignment, location: $0.location + indentation, options: $0.options)
//        }
//
//        return result
//    }
//
//
//    private func indentListItemTrailingParagraph(in str: NSMutableAttributedString, inRange range: NSRange) {
//        AttributedStringTool.updateExistingAttributes(in: str, for: .paragraphStyle, in: range) { (existingStyle: NSParagraphStyle) in
//            indent(existingStyle, by: itemParagraphStyler.indentation)
//        }
//
//        let defaultStyle = itemParagraphStyler.trailingParagraphStyle
//        AttributedStringTool.rangesMissingAttribute(in: str, for: .paragraphStyle, in: range).forEach { range in
//            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
//        }
//    }
}

