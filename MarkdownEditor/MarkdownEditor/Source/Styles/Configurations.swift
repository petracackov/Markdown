//
//  Configurations.swift
//  MarkdownEditor
//
//  Created by Petra Cackov on 01/04/2022.
//

import UIKit

// MARK: - StylerConfiguration

struct StylerConfiguration {

    // MARK: Default configuration

    static let `default`: StylerConfiguration = StylerConfiguration()

    // MARK: - Properties

    let fonts: MarkdownFontCollection
    let colors: MarkdownColorCollection
    let paragraphStyles: MarkdownParagraphStyleCollection
    let listItemOptions: ListItemOptions
    let itemParagraphStyler: ListItemParagraphStyler

    // MARK: - Life cycle

    public init(fonts: MarkdownFontCollection = MarkdownFontCollection(),
                colors: MarkdownColorCollection = MarkdownColorCollection(),
                paragraphStyles: MarkdownParagraphStyleCollection = MarkdownParagraphStyleCollection(),
                listItemOptions: ListItemOptions = ListItemOptions()) {
        self.fonts = fonts
        self.colors = colors
        self.paragraphStyles = paragraphStyles
        self.listItemOptions = listItemOptions
        self.itemParagraphStyler = ListItemParagraphStyler(options: listItemOptions,
                                                                                  prefixFont: fonts.listItemPrefix,
                                                                                  prefixColor: colors.listItemPrefix)
    }

    func evaluateAttributes(_ attributes: [NSAttributedString.Key: Any], in str: NSAttributedString) -> MarkdownType {
        let font = attributes[NSAttributedString.Key.font] as? UIFont
        let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
        if isHeading(font: font, paragraphStyle: paragraphStyle, color: color) {
            return .heading
        } else if hasIndent(paragraphStyle: paragraphStyle) {
            return .list
        } else if isParagraph(attributedString: str) {
            return .paragraph
        } else {
            return .text
        }
    }

    func evaluateAttributesInList(_ attributes: [NSAttributedString.Key: Any], in str: NSAttributedString) -> MarkdownType {
        let font = attributes[NSAttributedString.Key.font] as? UIFont
        let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
        if isHeading(font: font, paragraphStyle: paragraphStyle, color: color) {
            return .heading
        } else if isParagraph(attributedString: str) {
            return .paragraph
        } else {
            return .text
        }
    }

    private func isHeading(font: UIFont?, paragraphStyle: NSParagraphStyle?, color: UIColor?) -> Bool {
        return font == fonts.heading1 &&
        paragraphStyle == paragraphStyles.heading1 &&
        color == colors.heading1
    }

    private func hasIndent(paragraphStyle: NSParagraphStyle?) -> Bool {
        return paragraphStyle?.headIndent ==  itemParagraphStyler.indentation
    }

    func isHeading(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        attributedString.forEachAttributeGroup { attributes, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attributes, in: string))
        }
        return types.allSatisfy { $0 == .heading } && !types.isEmpty
    }

    func isParagraph(attributedString: NSAttributedString?) -> Bool {
        guard let string = attributedString?.string, !string.isEmpty else { return false }
        let trimmedString = string.trimmingCharacters(in: .newlines)
        return trimmedString.isEmpty
    }

    func isList(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        attributedString.forEachAttributeGroup { attributes, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attributes, in: string))
        }
        return types.allSatisfy { $0 == .list } && !types.isEmpty
    }

    enum MarkdownType {
        case heading
        case text
        case paragraph
        case list
    }

}

// MARK: - FontCollection

public struct MarkdownFontCollection {

    public var heading1: UIFont
    public var heading2: UIFont
    public var body: UIFont
    public var listItemPrefix: UIFont
    public static let fontFamilyName = "Averta"
    public init(
        heading1: UIFont = UIFont(name: MarkdownFontCollection.fontFamilyName + "-Bold", size: 28) ?? .systemFont(ofSize: 28),
        heading2: UIFont = UIFont(name: MarkdownFontCollection.fontFamilyName + "-Bold", size: 28) ?? .systemFont(ofSize: 28),
        body: UIFont = UIFont(name: MarkdownFontCollection.fontFamilyName, size: 20) ?? .systemFont(ofSize: 20),
        listItemPrefix: UIFont = UIFont(name: MarkdownFontCollection.fontFamilyName, size: 20) ?? .systemFont(ofSize: 20)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.body = body
        self.listItemPrefix = listItemPrefix
    }

}

// MARK: - ColorCollection

public struct MarkdownColorCollection {

    public var heading1: UIColor
    public var heading2: UIColor
    public var body: UIColor
    public var link: UIColor
    public var listItemPrefix: UIColor

    public init(
        heading1: UIColor = .black,
        heading2: UIColor = .black,
        body: UIColor = .black,
        link: UIColor = .blue,
        listItemPrefix: UIColor = .black
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.body = body
        self.link = link
        self.listItemPrefix = listItemPrefix
    }

}

// MARK: - ParagraphStyleCollection

public struct MarkdownParagraphStyleCollection {

    public var heading1: NSParagraphStyle
    public var heading2: NSParagraphStyle
    public var body: NSParagraphStyle

    public init() {
        let headingStyle = NSMutableParagraphStyle()
        headingStyle.lineSpacing = 8

        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.lineSpacing = 4

        heading1 = headingStyle
        heading2 = headingStyle
        body = bodyStyle
    }

}

// MARK: - ListItemOptions

public struct ListItemOptions {

    public var maxPrefixDigits: UInt
    public var spacingAfterPrefix: CGFloat
    public var spacingAbove: CGFloat
    public var spacingBelow: CGFloat

    public init(maxPrefixDigits: UInt = 2,
                spacingAfterPrefix: CGFloat = 8,
                spacingAbove: CGFloat = 4,
                spacingBelow: CGFloat = 8) {

        self.maxPrefixDigits = maxPrefixDigits
        self.spacingAfterPrefix = spacingAfterPrefix
        self.spacingAbove = spacingAbove
        self.spacingBelow = spacingBelow
    }

}
