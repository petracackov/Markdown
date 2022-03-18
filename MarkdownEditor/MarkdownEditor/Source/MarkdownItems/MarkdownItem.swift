//
//  TextItem.swift
//  Markdown
//
//  Created by Petra Cackov on 08/03/2022.
//

import UIKit

protocol MarkdownItem {

    var attributedText: NSAttributedString { get }

    func toMarkdown() -> String

}

class TextItem: MarkdownItem {

    var attributedText: NSAttributedString
    var isBold: Bool { AttributedStringTool.allFontsContainTrait(.traitBold, attributedString: attributedText) }
    var isItalic: Bool { AttributedStringTool.allFontsContainTrait(.traitItalic, attributedString: attributedText) }

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText

    }

    func toMarkdown() -> String {
        var string = attributedText.string

        let spacePrefix = string.hasPrefix(" ") ? " " : ""
        let spaceSuffix = string.hasSuffix(" ") ? " " : ""

        string = string.trimmingCharacters(in: .whitespaces)

        if isBold {
            string = "**\(string)**"
        }

        if isItalic {
            string = "_\(string)_"
        }
        return spacePrefix + string + spaceSuffix
    }

}


class HeadingItem: MarkdownItem {

    var attributedText: NSAttributedString

    init(attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func toMarkdown() -> String {
        return "# \(attributedText.string)"
    }
}

class Paragraph: MarkdownItem {
    var attributedText: NSAttributedString = NSAttributedString(string: "\n")

    func toMarkdown() -> String {
        return attributedText.string
    }
}

class List: MarkdownItem {

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
        return items.map { $0.toMarkdown() }.joined(separator: "").replacingOccurrences(of: "•\t", with: "- ")
    }

    private func toItems() -> [MarkdownItem] {
        var currentItems: [MarkdownItem] = []

        AttributedStringTool.forEachAttribute(in: attributedText, in: attributedText.fullRange) { attribute, range in
            let string = attributedText.attributedSubstring(from: range)
            let item = MarkdownStyles.evaluateAttributesInList(attribute)
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

        return currentItems + [Paragraph()]
    }
}

class Document: MarkdownItem {

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

        AttributedStringTool.forEachAttribute(in: attributedText, in: attributedText.fullRange) { attribute, range in
            let string = attributedText.attributedSubstring(from: range)
            let item = MarkdownStyles.evaluateAttributes(attribute, in: string)
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

