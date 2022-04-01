//
//  MarkdownStyles.swift
//  Markdown
//
//  Created by Petra Cackov on 09/03/2022.
//

import UIKit
import Down

class MarkdownStyles {

    private static let fontFamilyName = "Averta"
//    static let colorCollection = StaticColorCollection(heading1: .black, body: .black, link: .blue, listItemPrefix: .black)
//
//    static let fontCollection = StaticFontCollection(heading1: UIFont(name: fontFamilyName + "-Bold", size: 28) ?? .systemFont(ofSize: 28),
//                                                     body: UIFont(name: fontFamilyName, size: 20) ?? .systemFont(ofSize: 20),
//                                                     listItemPrefix: UIFont(name: fontFamilyName, size: 20) ?? UIFont.systemFont(ofSize: 20))
//
//    static let paragraphStyles = StaticParagraphStyleCollection()
//
//    static let listItemOptions = ListItemOptions()
//
//    static let itemParagraphStyler = ListItemParagraphStyler(options: listItemOptions,
//                                                             prefixFont: fontCollection.listItemPrefix)

    static let itemParagraphStyler = ListItemParagraphStyler(options: styleConfiguration.listItemOptions,
                                                             prefixFont: styleConfiguration.fonts.listItemPrefix)
    static let styleConfiguration = GIDStylerConfiguration()

    public static var colorCollection: ColorCollection { styleConfiguration.colors }
    public static var fontCollection: FontCollection { styleConfiguration.fonts }
    public static var paragraphStyles: ParagraphStyleCollection { styleConfiguration.paragraphStyles }
    public static var listParagraphStyle: NSParagraphStyle { itemParagraphStyler.leadingParagraphStyle(prefixWidth: attributedPrefix.size().width) }


    static let prefixAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor : MarkdownStyles.colorCollection.listItemPrefix,
        .font : MarkdownStyles.fontCollection.listItemPrefix
    ]


    static let prefix = "•"
    static var attributedPrefix: NSAttributedString {
        let mutablePrefix = NSMutableAttributedString(string: prefix)
        mutablePrefix.addAttributes(prefixAttributes)
        return mutablePrefix
    }

    static var prefixWithSpace: NSAttributedString {
        let mutablePrefix = NSMutableAttributedString(string: prefix + "\t")
        mutablePrefix.addAttributes(prefixAttributes)
        return mutablePrefix
    }

    static var prefixLength: Int { prefixWithSpace.length }

//    static var listParagraphStyle: NSParagraphStyle  { itemParagraphStyler.leadingParagraphStyle(prefixWidth: attributedPrefix.size().width) }


//
//    static let downConfiguration = DownStylerConfiguration(fonts: fontCollection,
//                                                           colors: colorCollection,
//                                                           paragraphStyles: paragraphStyles,
//                                                           listItemOptions: listItemOptions)



    static func evaluateAttributes(_ attributes: [NSAttributedString.Key: Any], in str: NSAttributedString) -> MarkdownType {
        let font = attributes[NSAttributedString.Key.font] as? UIFont
        let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
        if isHeading(font: font, paragraphStyle: paragraphStyle, color: color) {
            return .heading
        } else if hasIndent(paragraphStyle: paragraphStyle) {
            return .list
        } else if isParagraph(font: font) {
            return .paragraph
        } else {
            return .text
        }
    }

    static func evaluateAttributesInList(_ attributes: [NSAttributedString.Key: Any]) -> MarkdownType {
        let font = attributes[NSAttributedString.Key.font] as? UIFont
        let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor
        if isHeading(font: font, paragraphStyle: paragraphStyle, color: color) {
            return .heading
        } else if isParagraph(font: font) {
            return .paragraph
        } else {
            return .text
        }
    }

    enum MarkdownType {
        case heading
        case text
        case paragraph
        case list
    }

}

extension MarkdownStyles {

    static func isHeading(font: UIFont?, paragraphStyle: NSParagraphStyle?, color: UIColor?) -> Bool {
        return font == fontCollection.heading1 &&
        paragraphStyle == paragraphStyles.heading1 &&
        color == colorCollection.heading1
    }

    static func isHeading(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        AttributedStringTool.forEachAttribute(in: attributedString) { attribute, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attribute, in: string))
        }
        return types.allSatisfy { $0 == .heading } && !types.isEmpty
    }

    static func isParagraph(font: UIFont?) -> Bool {
        return font == nil
    }

    static func isList(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        AttributedStringTool.forEachAttribute(in: attributedString) { attribute, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attribute, in: string))
        }
        return types.allSatisfy { $0 == .list } && !types.isEmpty
    }

    static func hasIndent(paragraphStyle: NSParagraphStyle?)  -> Bool {
        return paragraphStyle?.headIndent ==  itemParagraphStyler.indentation
    }
}


