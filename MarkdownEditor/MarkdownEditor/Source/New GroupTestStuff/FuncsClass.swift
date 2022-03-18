//
//  FuncsClass.swift
//  Markdown
//
//  Created by Petra Cackov on 03/03/2022.
//

import Foundation
import UIKit

class FunscClass {

    private let markdown: String = "**Bold **_Itawlic **ItalicBold**_"
    private let markdown2: String = "***ItalicBold***"
    private let html = """
<html>
<body>
<h1>Hello, world!</h1>
<b>This text is bold</b><br>
<strong>This text is important!</strong>
<em>Thiwws text is emphasized</em>
<em><b>This text is bold, This text is emphasized</b></em>

<ul>
  <li>Coffee</li>
  <li>Tea</li>
  <li>Milk</li>
</ul>
<b>This text is bold</b>
</body>
</html>
"""


    func string() {
        var escapedString = markdown.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
        print("escapedString: \(escapedString)")
    }

    func string2() -> NSAttributedString? {
        let html2 = "<span style=\"font-family: Averta; font-size: 18; color: rgb(40, 60, 60)\">" + html + "</span>"
        let data = Data(html2.utf8)
        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {

            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: attributedString.fullRange)
            return attributedString
        }
        return nil
    }

    func toString(html: String?) -> NSAttributedString? {
        guard let html = html else { return nil }
        let html2 = "<span style=\"font-family: Averta; font-size: 18; color: rgb(60, 60, 60)\">" + html + "</span>"
        let data = Data(html2.utf8)
        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {

            //attributedString.addAttribute(.foregroundColor, value: UIColor.red)
            return attributedString
        }
        return nil
    }


}

extension NSAttributedString {
    func toHtml() -> String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes:documentAttributes)
            if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
                return htmlString
            }
        }
        catch {
            print("error creating HTML from Attributed String")
        }
        return nil
    }
}


extension NSMutableAttributedString {
    func htmlSimpleTagString() -> String {
        enumerateAttributes(in: fullRange, options: []) { (attributes, range, pointeeStop) in
            let occurence = self.attributedSubstring(from: range).string
            var replacement: String = occurence
            if let font = attributes[.font] as? UIFont {
                replacement = self.font(initialString: replacement, fromFont: font)
            }
            if let underline = attributes[.underlineStyle] as? Int {
                replacement = self.underline(text: replacement, fromStyle: underline)
            }
            if let striked = attributes[.strikethroughStyle] as? Int {
                replacement = self.strikethrough(text: replacement, fromStyle: striked)
            }
            self.replaceCharacters(in: range, with: replacement)
        }
        return self.string
    }
}

// MARK: In multiple loop
extension NSMutableAttributedString {
    func htmlSimpleTagString(options: [NSAttributedString.Key]) -> String {
        if options.contains(.underlineStyle) {
            enumerateAttribute(.underlineStyle, in: fullRange, options: []) { (value, range, pointeeStop) in
                let occurence = self.attributedSubstring(from: range).string
                guard let style = value as? Int else { return }
                if NSUnderlineStyle(rawValue: style) == NSUnderlineStyle.single {
                    let replacement = self.underline(text: occurence, fromStyle: style)
                    self.replaceCharacters(in: range, with: replacement)
                }
            }
        }
        if options.contains(.strikethroughStyle) {
            enumerateAttribute(.strikethroughStyle, in: fullRange, options: []) { (value, range, pointeeStop) in
                let occurence = self.attributedSubstring(from: range).string
                guard let style = value as? Int else { return }
                let replacement = self.strikethrough(text: occurence, fromStyle: style)
                self.replaceCharacters(in: range, with: replacement)
            }
        }
        if options.contains(.font) {
            enumerateAttribute(.font, in: fullRange, options: []) { (value, range, pointeeStop) in
                let occurence = self.attributedSubstring(from: range).string
                guard let font = value as? UIFont else { return }
                let replacement = self.font(initialString: occurence, fromFont: font)
                self.replaceCharacters(in: range, with: replacement)
            }
        }
        return self.string

    }
}

//MARK: Replacing
extension NSMutableAttributedString {

    func font(initialString: String, fromFont font: UIFont) -> String {
        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        let isHeader = font.pointSize > 20
        var retString = initialString

        if isHeader {
            retString = "<h1>" + retString + "</h1>"
        } else {
            if isBold {
                retString = "<b>" + retString + "</b>"
            }
            if isItalic {
                retString = "<i>" + retString + "</i>"
            }
        }
        return retString
    }

    func underline(text: String, fromStyle style: Int) -> String {
        return "<u>" + text + "</u>"
    }

    func strikethrough(text: String, fromStyle style: Int) -> String {
        return "<s>" + text + "</s>"
    }
}

//MARK: Utility
//private extension NSAttributedString {
//    func fullRange() -> NSRange {
//        return NSRange(location: 0, length: self.length)
//    }
//}
