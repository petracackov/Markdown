//
//  CustomStyler.swift
//  Markdown
//
//  Created by Petra Cackov on 18/03/2022.
//

import UIKit
import Down


class CustomStyler {

    // MARK: - Properties

    private let fonts: MarkdownFontCollection
    private let colors: MarkdownColorCollection
    private let paragraphStyles: MarkdownParagraphStyleCollection
    private let itemParagraphStyler: ListItemParagraphStyler

    var listPrefixAttributes: [NSAttributedString.Key: Any] {
        [ .font: fonts.listItemPrefix, .foregroundColor: colors.listItemPrefix ]
    }

    // MARK: - Life cycle

    public init(configuration: StylerConfiguration = StylerConfiguration.default) {
        fonts = configuration.fonts
        colors = configuration.colors
        paragraphStyles = configuration.paragraphStyles
        itemParagraphStyler = ListItemParagraphStyler(configuration: configuration)
    }

    // MARK: - Common Styling

    private func styleGenericLink(in str: NSMutableAttributedString, url: String) {
        str.addAttributes([
            .link: url,
            .foregroundColor: colors.link])
    }

    private func headingAttributes(for level: Int) -> (UIFont, UIColor, NSParagraphStyle) {
        switch level {
        case 1: return (fonts.heading1, colors.heading1, paragraphStyles.heading1)
        case 2: return (fonts.heading2, colors.heading2, paragraphStyles.heading2)
        default: return (fonts.heading1, colors.heading1, paragraphStyles.heading2)
        }
    }

    private func indentListItemLeadingParagraph(in str: NSMutableAttributedString,
                                                prefixLength: Int,
                                                in range: NSRange) {

        let numberOfLines = str.linesOfRange(range: range)
        guard numberOfLines.count > 0, let firstLine = numberOfLines.first else { return }

        let defaultStyle = itemParagraphStyler.listParagraphStyle
        str.forEachAttributeGroup(in: firstLine) { _, range in
            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
        }
        guard numberOfLines.count > 1 else { return }
        // In list paragraph we want to preserve the new lines that are part of that list item.
        // The text acts as all new line.
        // "\u{B}" -> Vertical tabulation, "\u{A}" -> line feed ("\n")
        let newString = str.mutableString.replacingOccurrences(of: "\u{A}", with: "\u{B}", options: .literal , range: str.fullRange)
        str.replaceCharacters(in: str.fullRange, with: newString)
        str.forEachAttributeGroup(in: numberOfLines[1]) { _, range in
            str.addAttribute(.paragraphStyle, value: itemParagraphStyler.trailingParagraphStyle, range: range)
        }


    }
}

extension CustomStyler: Styler {

    func style(listItemPrefix str: NSMutableAttributedString) {
        str.setAttributes(listPrefixAttributes)
    }

    func style(item str: NSMutableAttributedString, prefixLength: Int) {
        let prefixLength = itemParagraphStyler.attributedPrefix.length
        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: str.fullRange)
    }

    func style(heading str: NSMutableAttributedString, level: Int) {
        let (font, color, paragraphStyle) = headingAttributes(for: level)
        str.addAttributes([
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .font: font])
    }

    func style(text str: NSMutableAttributedString) {
        str.setAttributes([
            .font: fonts.body,
            .foregroundColor: colors.body,
            .paragraphStyle: paragraphStyles.body])
    }

    func style(softBreak str: NSMutableAttributedString) {
        // "\u{A}" -> line feed ("\n")
        str.replaceCharacters(in: str.fullRange, with: "\u{A}")
    }

    func style(emphasis str: NSMutableAttributedString) {
        str.addFontTrait(.traitItalic, defaultFont: fonts.body)
    }

    func style(strong str: NSMutableAttributedString) {
        str.addFontTrait(.traitBold, defaultFont: fonts.body)
    }

    func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        styleGenericLink(in: str, url: url)
    }

    func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        styleGenericLink(in: str, url: url)
    }

    func style(paragraph str: NSMutableAttributedString) {
        let missingFontRanges = str.rangesWithMissingAttribute(for: .font)
        missingFontRanges.forEach { range in
            guard range.location > 0 else { return }
            let previousAttributes = str.attributes(at: range.location-1, effectiveRange: nil)
            str.addAttributes(previousAttributes, range: range)
        }
    }

    func style(lineBreak str: NSMutableAttributedString) {
        print("lineBreak")
    }

    func style(document str: NSMutableAttributedString) {

    }

    func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {

    }

    func style(list str: NSMutableAttributedString, nestDepth: Int) {

    }

    func style(code str: NSMutableAttributedString) {

    }

    func style(htmlInline str: NSMutableAttributedString) {

    }

    func style(customInline str: NSMutableAttributedString) {

    }

    func style(thematicBreak str: NSMutableAttributedString) {
        print("thematicBreak")
    }

    func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {

    }

    func style(htmlBlock str: NSMutableAttributedString) {

    }

    func style(customBlock str: NSMutableAttributedString) {

    }

}
