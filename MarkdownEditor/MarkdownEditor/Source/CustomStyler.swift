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

    private let fonts: FontCollection
    private let colors: ColorCollection
    private let paragraphStyles: ParagraphStyleCollection
    private let itemParagraphStyler: ListItemParagraphStyler

    var listPrefixAttributes: [NSAttributedString.Key: Any] {
        [ .font: fonts.listItemPrefix, .foregroundColor: colors.listItemPrefix ]
    }

    // MARK: - Life cycle

    public init(configuration: StylerConfiguration = StylerConfiguration()) {
        fonts = configuration.fonts
        colors = configuration.colors
        paragraphStyles = configuration.paragraphStyles
        itemParagraphStyler = ListItemParagraphStyler(options: configuration.listItemOptions,
                                                      prefixFont: fonts.listItemPrefix)
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

        let attributedPrefix = str.prefix(with: prefixLength)
        let prefixWidth = attributedPrefix.size().width

        let defaultStyle = itemParagraphStyler.leadingParagraphStyle(prefixWidth: prefixWidth)
        AttributedStringTool.forEachAttribute(in: str) { _, range in
            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
        }
    }
}

extension CustomStyler: Styler {
    func style(document str: NSMutableAttributedString) {

    }

    func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {

    }

    func style(list str: NSMutableAttributedString, nestDepth: Int) {

    }

    func style(listItemPrefix str: NSMutableAttributedString) {
        str.setAttributes(listPrefixAttributes)
    }

    func style(item str: NSMutableAttributedString, prefixLength: Int) {
        let prefixLength = MarkdownStyles.attributedPrefix.length
        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: str.fullRange)
    }

    func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {

    }

    func style(htmlBlock str: NSMutableAttributedString) {

    }

    func style(customBlock str: NSMutableAttributedString) {

    }

    func style(paragraph str: NSMutableAttributedString) {
        //str.addAttribute(for: .paragraphStyle, value: paragraphStyles.body)
    }

    func style(heading str: NSMutableAttributedString, level: Int) {
        let (font, color, paragraphStyle) = headingAttributes(for: level)

        str.updateExistingAttributes(for: .font) { (currentFont: UIFont) in
            var newFont = font

            if currentFont.isEmphasized {
                newFont = newFont.emphasis
            }

            if currentFont.isStrong {
                newFont = newFont.strong
            }

            return newFont
        }

        str.addAttributes([
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle])
    }

    func style(thematicBreak str: NSMutableAttributedString) {

    }

    func style(text str: NSMutableAttributedString) {
        str.setAttributes([
            .font: fonts.body,
            .foregroundColor: colors.body,
            .paragraphStyle: paragraphStyles.body])
    }

    func style(softBreak str: NSMutableAttributedString) {

    }

    func style(lineBreak str: NSMutableAttributedString) {

    }

    func style(code str: NSMutableAttributedString) {

    }

    func style(htmlInline str: NSMutableAttributedString) {
    }

    func style(customInline str: NSMutableAttributedString) {

    }

    func style(emphasis str: NSMutableAttributedString) {
        str.updateExistingAttributes(for: .font) { (font: UIFont) in
            font.emphasis
        }
    }

    func style(strong str: NSMutableAttributedString) {
        str.updateExistingAttributes(for: .font) { (font: UIFont) in
            font.strong
        }
    }

    func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        styleGenericLink(in: str, url: url)
    }

    func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        styleGenericLink(in: str, url: url)
    }

}






//class CustomStyler: DownStyler {
//
////
////    let listItemOptions = MarkdownStyles.listItemOptions
//
//
////    var largestPrefixWidth: CGFloat {
////        let prefixFont = MarkdownStyles.fontCollection.listItemPrefix
////        return widthOfNumberedPrefix(digits: listItemOptions.maxPrefixDigits, for: prefixFont)
////    }
////
////    public var indentation: CGFloat {
////        return largestPrefixWidth + listItemOptions.spacingAfterPrefix
////    }
////
////    private var baseStyle: NSMutableParagraphStyle {
////        let style = NSMutableParagraphStyle()
////        style.paragraphSpacingBefore = listItemOptions.spacingAbove
////        style.paragraphSpacing = listItemOptions.spacingBelow
////        return style
////    }
//
//    private let itemParagraphStyler = MarkdownStyles.itemParagraphStyler
//
//    override func style(item str: NSMutableAttributedString, prefixLength: Int) {
//
//        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: str.fullRange)
//    }
//
//    override func style(list str: NSMutableAttributedString, nestDepth: Int) {
//        print(str)
//    }
//
//    // TODO: add line spacing
//    override func style(text str: NSMutableAttributedString) {
//        str.setAttributes([
//            .font: fonts.body,
//            .foregroundColor: colors.body,
//            .paragraphStyle: paragraphStyles.body])
//    }
//
//    override func style(paragraph str: NSMutableAttributedString) {
//        print("------")
//        print(str)
//    }
//
//    private func indentListItemLeadingParagraph(in str: NSMutableAttributedString,
//                                                prefixLength: Int,
//                                                in range: NSRange) {
//
//        let attributedPrefix = str.prefix(length: prefixLength)// prefix(in: str, with: prefixLength)
//        let prefixWidth = attributedPrefix.size().width
//
//        let defaultStyle = itemParagraphStyler.leadingParagraphStyle(prefixWidth: prefixWidth)
//        AttributedStringTool.forEachAttribute(in: str) { attribute, range in
//            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
//        }
//    }
//
//
////    override func style(item str: NSMutableAttributedString, prefixLength: Int) {
////
////        let paragraphRanges = paragraphRanges(in: str)
////
////        guard let leadingParagraphRange = paragraphRanges.first else { return }
////
////        indentListItemLeadingParagraph(in: str, prefixLength: prefixLength, in: leadingParagraphRange)
////
//////        paragraphRanges.dropFirst().forEach {
//////            indentListItemTrailingParagraph(in: str, inRange: $0)
//////        }
////    }
//
////    private func indentListItemLeadingParagraph(in str: NSMutableAttributedString,
////                                                prefixLength: Int,
////                                                in range: NSRange) {
////
////        // not really needed since we do not support multiple partagraphs
////        AttributedStringTool.updateExistingAttributes(in: str, for: .paragraphStyle, in: range) { (existingStyle: NSParagraphStyle) in
////            indent(existingStyle, by: itemParagraphStyler.indentation)
////        }
////
////        let attributedPrefix = prefix(in: str, with: prefixLength)
////        let prefixWidth = attributedPrefix.size().width
////
////        let defaultStyle = itemParagraphStyler.leadingParagraphStyle(prefixWidth: prefixWidth)
////        AttributedStringTool.rangesMissingAttribute(in: str, for: .paragraphStyle, in: range).forEach { range in
////            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
////        }
////    }
//
////    func paragraphRanges(in str: NSAttributedString) -> [NSRange] {
////        guard str.length > 0 else { return [] }
////
////        func nextParagraphRange(at location: Int) -> NSRange {
////            return NSString(string: str.string).paragraphRange(for: NSRange(location: location, length: 1))
////        }
////
////        var result = [nextParagraphRange(at: 0)]
////
////        while let currentLocation = result.last?.upperBound, currentLocation < str.length {
////            result.append(nextParagraphRange(at: currentLocation))
////        }
////
////        return result.filter { $0.length > 1 }
////    }
////
////    func indent(_ style: NSParagraphStyle, by indentation: CGFloat) -> NSParagraphStyle {
////        guard let result = style.mutableCopy() as? NSMutableParagraphStyle else { return style }
////        result.firstLineHeadIndent += indentation
////        result.headIndent += indentation
////
////        result.tabStops = style.tabStops.map {
////            NSTextTab(textAlignment: $0.alignment, location: $0.location + indentation, options: $0.options)
////        }
////
////        return result
////    }
////
////
////    private func indentListItemTrailingParagraph(in str: NSMutableAttributedString, inRange range: NSRange) {
////        AttributedStringTool.updateExistingAttributes(in: str, for: .paragraphStyle, in: range) { (existingStyle: NSParagraphStyle) in
////            indent(existingStyle, by: itemParagraphStyler.indentation)
////        }
////
////        let defaultStyle = itemParagraphStyler.trailingParagraphStyle
////        AttributedStringTool.rangesMissingAttribute(in: str, for: .paragraphStyle, in: range).forEach { range in
////            str.addAttribute(.paragraphStyle, value: defaultStyle, range: range)
////        }
////    }
//}
