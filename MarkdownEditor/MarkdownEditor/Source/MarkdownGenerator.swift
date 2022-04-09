//
//  MarkdownGenerator.swift
//  GIDMarkdown
//
//  Created by Petra Cackov on 16/03/2022.
//

import UIKit
import Down

public class MarkdownGenerator {

    public static func attributedString(fromMarkdown markdown: String) -> NSAttributedString? {
        let attributedString = try? Down(markdownString: markdown).toAttributedString([.hardBreaks], styler: CustomStyler())
        return attributedString
    }

    public static func markdown(fromAttributedString attributedString: NSAttributedString) -> String {
        let markdown = Document(attributedText: attributedString).toMarkdown()
        return markdown
    }

}
