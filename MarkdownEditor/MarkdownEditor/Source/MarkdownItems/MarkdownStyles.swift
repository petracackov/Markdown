//
//  MarkdownStyles.swift
//  Markdown
//
//  Created by Petra Cackov on 09/03/2022.
//

import UIKit

class MarkdownStyles {

    static let styleConfiguration = StylerConfiguration()

    private static let itemParagraphStyler = ListItemParagraphStyler(configuration: styleConfiguration)
    private static var colorCollection: ColorCollection { styleConfiguration.colors }
    private static var fontCollection: FontCollection { styleConfiguration.fonts }
    private static var paragraphStyles: ParagraphStyleCollection { styleConfiguration.paragraphStyles }

    static func evaluateAttributes(_ attributes: [NSAttributedString.Key: Any], in str: NSAttributedString) -> MarkdownType {
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

    static func evaluateAttributesInList(_ attributes: [NSAttributedString.Key: Any], in str: NSAttributedString) -> MarkdownType {
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

    private static func isHeading(font: UIFont?, paragraphStyle: NSParagraphStyle?, color: UIColor?) -> Bool {
        return font == fontCollection.heading1 &&
        paragraphStyle == paragraphStyles.heading1 &&
        color == colorCollection.heading1
    }

    private static func hasIndent(paragraphStyle: NSParagraphStyle?)  -> Bool {
        return paragraphStyle?.headIndent ==  itemParagraphStyler.indentation
    }

    static func isHeading(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        AttributedStringTool.forEachAttributeGroup(in: attributedString) { attributes, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attributes, in: string))
        }
        return types.allSatisfy { $0 == .heading } && !types.isEmpty
    }

    static func isParagraph(attributedString: NSAttributedString?) -> Bool {
        guard let string = attributedString?.string, !string.isEmpty else { return false }
        let trimmedString = string.trimmingCharacters(in: .newlines)
        return trimmedString.isEmpty
    }

    static func isList(_ attributedString: NSAttributedString) -> Bool {
        var types: [MarkdownType] = []
        AttributedStringTool.forEachAttributeGroup(in: attributedString) { attributes, range in
            let string = attributedString.attributedSubstring(from: range)
            types.append(evaluateAttributes(attributes, in: string))
        }
        return types.allSatisfy { $0 == .list } && !types.isEmpty
    }

}

extension MarkdownStyles {
    enum MarkdownType {
        case heading
        case text
        case paragraph
        case list
    }
}


