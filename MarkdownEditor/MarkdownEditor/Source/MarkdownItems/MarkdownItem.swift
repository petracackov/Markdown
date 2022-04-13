//
//  TextItem.swift
//  Markdown
//
//  Created by Petra Cackov on 08/03/2022.
//

import UIKit

/// An item representing part of the attributed text with specific properties.
/// Items are build and generated from attributed string and build into a tree/document that represents the whole attributed text
/// and can be converted to markdown
protocol MarkdownItem {

    var attributedText: NSAttributedString { get }

    func toMarkdown() -> String

}

/// Contains only characters -> the part of attributed string that is just plain text
final class CharacterSetItem: MarkdownItem {

    var attributedText: NSAttributedString
    var isBold: Bool { attributedText.allFontsContainTrait(.traitBold) }
    var isItalic: Bool { attributedText.allFontsContainTrait(.traitItalic) }

    /// those characters should be escaped so they are not handled as indicators for some font attribute
    private var escapingCharactersString: String {
        let escapingCharacters = "`*_{}[]<>()#+-.!|"
        var string = attributedText.string
        escapingCharacters.forEach { character in
            string = string.replacingOccurrences(of: "\(character)", with: "\\" + "\(character)")
        }
        return string
    }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        var string = escapingCharactersString

        let spacePrefix = string.hasPrefix(" ") ? " " : ""
        let spaceSuffix = string.hasSuffix(" ") ? " " : ""

        string = string.trimmingCharacters(in: .whitespaces)

        if isBold {
            string = "**\(string)**"
        }

        if isItalic {
            string = "*\(string)*"
        }
        return spacePrefix + string + spaceSuffix
    }

}

/// Item containing characters, paragraphs and spaces
final class TextItem: MarkdownItem {

    var attributedText: NSAttributedString
    private var items: [MarkdownItem] { toItems() }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return items.map { $0.toMarkdown() }.joined(separator: "")
    }

    private func toItems() -> [MarkdownItem] {
        var items: [MarkdownItem] = []
        var currentTextRange: NSRange = NSRange(location: 0, length: 0)

        attributedText.string.forEach { character in
            let string = NSAttributedString(string: "\(character)")
            if StylerConfiguration.default.isParagraph(attributedString: string) {
                items.append(CharacterSetItem(attributedText: attributedText.attributedSubstring(from: currentTextRange)))
                items.append(Paragraph())
                currentTextRange.location = currentTextRange.location + currentTextRange.length + string.fullRange.length
                currentTextRange.length = 0
            } else {
                currentTextRange.length += string.fullRange.length
            }
        }
        items.append(CharacterSetItem(attributedText: attributedText.attributedSubstring(from: currentTextRange)))
        return items
    }

}

/// Item representing the heading
final class HeadingItem: MarkdownItem {

    var attributedText: NSAttributedString

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return "# \(attributedText.string)"
    }
}

/// Item paragraph (most of the time that is treated as new line)
final class Paragraph: MarkdownItem {
    var attributedText: NSAttributedString = NSAttributedString(string: "\n")

    func toMarkdown() -> String {
        return attributedText.string
    }
}

/// Item that represents the prefix of list item
final class ListPrefix: MarkdownItem {
    var attributedText: NSAttributedString

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return attributedText.string.replacingOccurrences(of: "•\t", with: "- ")
    }
}

/// Item of the list (has prefix at the beginning -> bullet point/item)
final class ListItem: MarkdownItem {

    var attributedText: NSAttributedString
    private var items: [MarkdownItem] { toItems() }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return items.map { $0.toMarkdown() }.joined(separator: "")
    }

    func toItems() -> [MarkdownItem] {
        var currentItems: [MarkdownItem] = []

        let prefixString = NSMutableAttributedString(attributedString: attributedText)
        let rangeOfPrefix = prefixString.mutableString.range(of: "•\t")
        if rangeOfPrefix.location != NSNotFound {
            currentItems.append(ListPrefix(attributedText: prefixString.attributedSubstring(from: rangeOfPrefix)))
            prefixString.replaceCharacters(in: rangeOfPrefix, with: "")
        }

        prefixString.forEachAttributeGroup { attributes, range in
            let string = prefixString.attributedSubstring(from: range)
            let item = StylerConfiguration.default.evaluateAttributesInList(attributes, in: string)
            switch item {
            case .heading:
                currentItems.append(HeadingItem(attributedText: string))
            case .text:
                currentItems.append(TextItem(attributedText: string))
            case .paragraph:
                currentItems.append(Paragraph())
            case .list:
                if let existingList = currentItems.last as? List {
                    existingList.addListItem(attributedText: string)
                } else {
                    currentItems.append(List(attributedText: string))
                }
            }
        }
        return currentItems
    }
}

/// Contains list items (bullet points) and a paragraph at the end to separate itself from regular text
final class List: MarkdownItem {

    var attributedText: NSAttributedString
    private var items: [MarkdownItem] { toItems() }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func addListItem(attributedText: NSAttributedString) {
        let newAttributedText = NSMutableAttributedString(attributedString: self.attributedText)
        newAttributedText.append(attributedText)
        self.attributedText = newAttributedText
    }

    func toMarkdown() -> String {
        return items.map { $0.toMarkdown() }.joined(separator: "")
    }

    private func toItems() -> [MarkdownItem] {
        let itemsRanges = attributedText.lineRanges()
        let items = itemsRanges.map { ListItem(attributedText: attributedText.attributedSubstring(from: $0)) }
        return items + [Paragraph()]
    }
}

/// Contains all hierarchy of the attributed text -> the whole tree of items
final class Document: MarkdownItem {

    var attributedText: NSAttributedString

    var items: [MarkdownItem] { toItems() }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return items.map { $0.toMarkdown() }.joined(separator: "")
    }

    private func toItems() -> [MarkdownItem] {
        var currentItems: [MarkdownItem] = []

        attributedText.forEachAttributeGroup { attributes, range in
            let string = attributedText.attributedSubstring(from: range)
            let item = StylerConfiguration.default.evaluateAttributes(attributes, in: string)
            switch item {
            case .heading:
                currentItems.append(HeadingItem(attributedText: string))
            case .text:
                currentItems.append(TextItem(attributedText: string))
            case .paragraph:
                currentItems.append(Paragraph())
            case .list:
                if let existingList = currentItems.last as? List {
                    existingList.addListItem(attributedText: string)
                } else {
                    currentItems.append(List(attributedText: string))
                }
            }
        }

        return currentItems
    }

}

