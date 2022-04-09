//
//  ListItemParagraphStyler.swift
//  MarkdownEditor
//
//  Created by Petra Cackov on 09/04/2022.
//

import UIKit

// MARK: - ListItemParagraphStyler

/// A convenient class used to format lists, such that list item prefixes
/// are right aligned and list item content left aligns.
class ListItemParagraphStyler {

    // MARK: - Properties

    public var indentation: CGFloat {
        return largestPrefixWidth + options.spacingAfterPrefix
    }

    private let options: ListItemOptions
    private let prefixColor: UIColor
    private let prefixFont: UIFont
    private let largestPrefixWidth: CGFloat

    private var baseStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacingBefore = options.spacingAbove
        style.paragraphSpacing = options.spacingBelow
        return style
    }

    var trailingParagraphStyle: NSParagraphStyle {
        let contentIndentation = indentation
        let style = baseStyle
        style.firstLineHeadIndent = contentIndentation
        style.headIndent = contentIndentation
        return style
    }

    var listParagraphStyle: NSParagraphStyle {
        leadingParagraphStyle(prefixWidth: attributedPrefix.size().width)
    }

    // MARK: Default list prefix

    private let prefix = "•"

    private lazy var prefixAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: prefixColor,
        .font: prefixFont
    ]

    var prefixWithSpace: NSAttributedString {
        let mutablePrefix = NSMutableAttributedString(string: prefix + "\t")
        mutablePrefix.addAttributes(prefixAttributes)
        return mutablePrefix
    }

    var attributedPrefix: NSAttributedString {
        let mutablePrefix = NSMutableAttributedString(string: prefix)
        mutablePrefix.addAttributes(prefixAttributes)
        return mutablePrefix
    }

    // MARK: - Life cycle

    public init(options: ListItemOptions, prefixFont: UIFont, prefixColor: UIColor) {
        self.options = options
        self.prefixColor = prefixColor
        self.prefixFont = prefixFont
        self.largestPrefixWidth = Self.widthOfNumberedPrefix(for: prefixFont, digits: options.maxPrefixDigits)
    }

    convenience init(configuration: StylerConfiguration) {
        self.init(options: configuration.listItemOptions,
                  prefixFont: configuration.fonts.listItemPrefix,
                  prefixColor: configuration.colors.listItemPrefix)
    }

    // MARK: - Methods

    /// The paragraph style intended for the first paragraph of the list item.
    ///
    /// - Parameter prefixWidth: the width (in points) off the list item prefix.
    private func leadingParagraphStyle(prefixWidth: CGFloat) -> NSParagraphStyle {
        let contentIndentation = indentation
        let prefixIndentation: CGFloat = contentIndentation - options.spacingAfterPrefix - prefixWidth
        let prefixSpill = max(0, prefixWidth - largestPrefixWidth)
        let firstLineContentIndentation = contentIndentation + prefixSpill

        let style = baseStyle
        style.firstLineHeadIndent = prefixIndentation
        style.tabStops = [tabStop(at: firstLineContentIndentation)]
        style.headIndent = contentIndentation
        return style
    }

    private func tabStop(at location: CGFloat) -> NSTextTab {
        return NSTextTab(textAlignment: .left, location: location, options: [:])
    }

    private static func widthOfNumberedPrefix(for font: UIFont, digits: UInt) -> CGFloat {
        let widthOfLargestDigit: CGFloat = {
            Array(0...9)
                .map { NSAttributedString(string: "\($0)", attributes: [.font: font]).size().width }
                .max() ?? NSAttributedString(string: "0", attributes: [.font: font]).size().width
        }()

        let widthOfPeriod: CGFloat = {
            NSAttributedString(string: ".", attributes: [.font: font])
                .size()
                .width
        }()
        return widthOfLargestDigit * CGFloat(digits) + widthOfPeriod
    }
}
