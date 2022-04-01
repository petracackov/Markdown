//
//  Configurations.swift
//  MarkdownEditor
//
//  Created by Petra Cackov on 01/04/2022.
//

import UIKit

// MARK: - GIDStylerConfiguration

public struct GIDStylerConfiguration {

    // MARK: - Properties

    public var fonts: FontCollection
    public var colors: ColorCollection
    public var paragraphStyles: ParagraphStyleCollection

    public var listItemOptions: ListItemOptions

    // MARK: - Life cycle

    public init(fonts: FontCollection = GIDMarkdownFontCollection(),
                colors: ColorCollection = GIDMarkdownColorCollection(),
                paragraphStyles: ParagraphStyleCollection = GIDMarkdownParagraphStyleCollection(),
                listItemOptions: ListItemOptions = ListItemOptions()
    ) {
        self.fonts = fonts
        self.colors = colors
        self.paragraphStyles = paragraphStyles
        self.listItemOptions = listItemOptions
    }

}

// MARK: - FontCollection

public protocol FontCollection {

    var heading1: UIFont { get }
    var heading2: UIFont { get }
    var body: UIFont { get }
    var listItemPrefix: UIFont { get }

}

public struct GIDMarkdownFontCollection: FontCollection {

    public var heading1: UIFont
    public var heading2: UIFont
    public var body: UIFont
    public var listItemPrefix: UIFont
    public static let fontFamilyName = "Averta"
    public init(
        heading1: UIFont = UIFont(name: GIDMarkdownFontCollection.fontFamilyName + "-Bold", size: 28) ?? .systemFont(ofSize: 28),
        heading2: UIFont = UIFont(name: GIDMarkdownFontCollection.fontFamilyName + "-Bold", size: 28) ?? .systemFont(ofSize: 28),
        body: UIFont = UIFont(name: GIDMarkdownFontCollection.fontFamilyName, size: 20) ?? .systemFont(ofSize: 20),
        listItemPrefix: UIFont = UIFont(name: GIDMarkdownFontCollection.fontFamilyName, size: 20) ?? .systemFont(ofSize: 20)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.body = body
        self.listItemPrefix = listItemPrefix
    }

}

// MARK: - ColorCollection

public protocol ColorCollection {

    var heading1: UIColor { get }
    var heading2: UIColor { get }
    var body: UIColor { get }
    var link: UIColor { get }
    var listItemPrefix: UIColor { get }

}

public struct GIDMarkdownColorCollection: ColorCollection {

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

public protocol ParagraphStyleCollection {

    var heading1: NSParagraphStyle { get }
    var heading2: NSParagraphStyle { get }
    var body: NSParagraphStyle { get }

}

public struct GIDMarkdownParagraphStyleCollection: ParagraphStyleCollection {

    public var heading1: NSParagraphStyle
    public var heading2: NSParagraphStyle
    public var body: NSParagraphStyle

    public init() {
        let headingStyle = NSMutableParagraphStyle()
        headingStyle.paragraphSpacing = 8

        let bodyStyle = NSMutableParagraphStyle()
//        bodyStyle.paragraphSpacingBefore = 8
//        bodyStyle.paragraphSpacing = 8
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

// MARK: - ListItemParagraphStyler

/// A convenient class used to format lists, such that list item prefixes
/// are right aligned and list item content left aligns.
public class ListItemParagraphStyler {

    // MARK: - Properties

    public var indentation: CGFloat {
        return largestPrefixWidth + options.spacingAfterPrefix
    }

    private let options: ListItemOptions
    private let largestPrefixWidth: CGFloat

    private var baseStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacingBefore = options.spacingAbove
        style.paragraphSpacing = options.spacingBelow
        return style
    }

    // MARK: - Life cycle

    public init(options: ListItemOptions, prefixFont: UIFont) {
        self.options = options
        self.largestPrefixWidth = prefixFont.widthOfNumberedPrefix(digits: options.maxPrefixDigits)
    }

    // MARK: - Methods

    /// The paragraph style intended for the first paragraph of the list item.
    ///
    /// - Parameter prefixWidth: the width (in points) of the list item prefix.

    public func leadingParagraphStyle(prefixWidth: CGFloat) -> NSParagraphStyle {
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

}

// MARK: - Helpers

private extension UIFont {

    func widthOfNumberedPrefix(digits: UInt) -> CGFloat {
        return widthOfLargestDigit * CGFloat(digits) + widthOfPeriod
    }

    private var widthOfLargestDigit: CGFloat {
        return Int.decimalDigits
            .map { NSAttributedString(string: "\($0)", attributes: [.font: self]).size().width }
            .max()!
    }

    private var widthOfPeriod: CGFloat {
        return NSAttributedString(string: ".", attributes: [.font: self])
            .size()
            .width
    }

}

private extension Int {

    static var decimalDigits: [Int] {
        return Array(0...9)
    }

}

