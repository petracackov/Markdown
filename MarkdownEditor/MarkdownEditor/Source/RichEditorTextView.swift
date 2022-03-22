//
//  RichEditorTextView.swift
//  Markdown
//
//  Created by Petra Cackov on 04/03/2022.
//

import UIKit

protocol RichEditorTextViewDelegate: AnyObject {
    func richEditorTextView(_ sender: RichEditorTextView, didChangeBoldSelection isSelected: Bool)
    func richEditorTextView(_ sender: RichEditorTextView, didChangeItalicSelection isSelected: Bool)
    func richEditorTextView(_ sender: RichEditorTextView, didChangeListSelection isSelected: Bool)
    func richEditorTextView(_ sender: RichEditorTextView, didChangeHeadingSelection isSelected: Bool)
}

class RichEditorTextView: UIView {

    // MARK: - Views

    private lazy var textView: MyTextView = {
        let textView = MyTextView(frame: self.frame)
        textView.textContainerInset = .zero
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.textContainer.lineFragmentPadding = 0
        //textView.allowsEditingTextAttributes = true
        textView.autocapitalizationType = .none
        textView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                       NSAttributedString.Key.foregroundColor: UIColor.red]
        textView.keyboardDismissMode = .interactive
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .white
        return textView
    }()

    // For testing
    lazy var markdownStringLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()


    // MARK: - Properties

    var delegate: RichEditorTextViewDelegate?

    private let baseAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor : MarkdownStyles.colorCollection.body,
        .font : MarkdownStyles.fontCollection.body,
        .paragraphStyle : MarkdownStyles.paragraphStyles.body
    ]

    private let headingAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor : MarkdownStyles.colorCollection.heading1,
        .font : MarkdownStyles.fontCollection.heading1,
        .paragraphStyle : MarkdownStyles.paragraphStyles.heading1
    ]

    private let listAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle : MarkdownStyles.listParagraphStyle
    ]

//    private let prefixAttributes:  [NSAttributedString.Key: Any] = [
//        .foregroundColor : MarkdownStyles.colorCollection.listItemPrefix,
//        .font : MarkdownStyles.fontCollection.listItemPrefix,
//        .paragraphStyle : MarkdownStyles.listParagraphStyle
//    ]

    // MARK: - TextView selected options

    var attributedString: NSAttributedString? {
        didSet {
            textView.attributedText = attributedString
        }
    }

    lazy var currentSelectedRange: NSRange = NSRange(location: attributedString?.length ?? 0, length: 0) {
        didSet {
            let maxLocation = attributedString?.length ?? 0
            if currentSelectedRange.length > maxLocation {
                currentSelectedRange = NSRange(location: maxLocation, length: 0)
            }
        }
    }

    private var boldIsActive: Bool = false {
        didSet {
            guard oldValue != boldIsActive else { return }
            delegate?.richEditorTextView(self, didChangeBoldSelection: boldIsActive)
        }
    }

    private var italicIsActive: Bool = false {
        didSet {
            guard oldValue != italicIsActive else { return }
            delegate?.richEditorTextView(self, didChangeItalicSelection: italicIsActive)
        }
    }

    private var listIsActive: Bool = false {
        didSet {
            guard oldValue != listIsActive else { return }
            delegate?.richEditorTextView(self, didChangeListSelection: listIsActive)
        }
    }

    private var headingIsActive: Bool = false {
        didSet {
            guard oldValue != headingIsActive else { return }
            delegate?.richEditorTextView(self, didChangeHeadingSelection: headingIsActive)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.addArrangedSubview(textView)
        vStack.addArrangedSubview(markdownStringLabel)

        addSubviewWithPinnedEdgesToView(self, subview: vStack)
    }

    func selectBold() {
        guard headingIsActive == false else { return }
        boldIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        let currentRange = currentSelectedRange
        AttributedStringTool.toggleTrait(.traitBold, to: mutableString, in: currentSelectedRange)
        attributedString = NSAttributedString(attributedString: mutableString)
        textView.selectedRange = currentRange
    }

    func selectItalic() {
        guard headingIsActive == false else { return }
        italicIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        let currentRange = currentSelectedRange
        AttributedStringTool.toggleTrait(.traitItalic, to: mutableString, in: currentSelectedRange)
        attributedString = NSAttributedString(attributedString: mutableString)
        textView.selectedRange = currentRange
    }

    func selectList() {
        listIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)


        let selectedParagraphs = paragraphsOfRange(range: currentSelectedRange, str: textView.attributedText)
//        let selectedParagraphStrings = selectedParagraphs.map { (range: $0, string: mutableString.attributedSubstring(from: $0)) }

//        let attributes = listIsActive ? listAttributes : [NSAttributedString.Key.paragraphStyle: MarkdownStyles.listParagraphStyle]
//        addAttributesToRanges(in: mutableString, attributes: attributes, ranges: selectedParagraphs)

        let paragraphStyle = listIsActive ? MarkdownStyles.listParagraphStyle : MarkdownStyles.paragraphStyles.body

        selectedParagraphs.forEach { paragraphRange in
            var paragraphString = NSMutableAttributedString(attributedString: mutableString.attributedSubstring(from: paragraphRange))
            if listIsActive, !stringHasPrefix(paragraphString) {
                // add prefix
                let prefixWithParagraphString = NSMutableAttributedString(attributedString: MarkdownStyles.prefixWithSpace)
                prefixWithParagraphString.append(paragraphString)
                paragraphString = prefixWithParagraphString

            } else if !listIsActive, stringHasPrefix(paragraphString) {
                // remove prefix
                paragraphString.replaceCharacters(in: NSRange(location: 0, length: MarkdownStyles.prefixWithSpace.length), with: "")
            }

            paragraphString.addAttribute(for: .paragraphStyle, value: paragraphStyle)
           // paragraphString.addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
            mutableString.replaceCharacters(in: paragraphRange, with: paragraphString)

        }

        let currentRange = currentSelectedRange
        attributedString = NSAttributedString(attributedString: mutableString)
        textView.selectedRange = currentRange
    }

    func selectHeading() {

        headingIsActive.toggle()

        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        let selectedParagraphs = paragraphsOfRange(range: currentSelectedRange, str: textView.attributedText)
        let attributes = headingIsActive ? headingAttributes : baseAttributes
        addAttributesToRanges(in: mutableString, attributes: attributes, ranges: selectedParagraphs)

        if headingIsActive {
            listIsActive = false
            italicIsActive = false
            boldIsActive = false
        }

        let currentRange = currentSelectedRange
        attributedString = mutableString
        textView.selectedRange = currentRange
    }
}

private extension RichEditorTextView {

    private func updateAttributeState(forRange range: NSRange) {
        var biggerRange = range
        if range.length == 0 && range.location > 0 {
            biggerRange.length += 1
            biggerRange.location -= 1
        }

        let attributedString = textView.attributedText.attributedSubstring(from: biggerRange)

        headingIsActive = MarkdownStyles.isHeading(attributedString)
        listIsActive = MarkdownStyles.isList(attributedString)
        boldIsActive = AttributedStringTool.allFontsContainTrait(.traitBold, attributedString: attributedString) && !headingIsActive
        italicIsActive = AttributedStringTool.allFontsContainTrait(.traitItalic, attributedString: attributedString)

    }



    private func updateString(with string: String, at range: NSRange) {
        guard let attributedString = attributedString else { return }
        let mutableText = NSMutableAttributedString(attributedString: attributedString)
        let attributedNewString = NSMutableAttributedString(string: string)
        attributedNewString.setAttributes(baseAttributes)

        if boldIsActive {
            AttributedStringTool.addTrait(.traitBold, to: attributedNewString, in: attributedNewString.wholeRange)
        }

        if italicIsActive {
            AttributedStringTool.addTrait(.traitItalic, to: attributedNewString, in: attributedNewString.wholeRange)
        }

        if headingIsActive {
            attributedNewString.setAttributes(headingAttributes)
        }

        mutableText.replaceCharacters(in: range, with: attributedNewString)
        var currentRange = currentSelectedRange

        // TODO:handle emoji because character count is fifferent that lenght
        // An empty string is replacing the previous character -> deletion of one character
        if attributedNewString.length == 0, currentRange.length == 0 {
            currentRange.location -= 1
        } else {
            currentRange.location += attributedNewString.length
        }
        // if text was previously selected (the length of range was not 0) after replacing characters it should not be selected anymore
        currentRange.length = 0

        self.attributedString = mutableText
        textView.selectedRange = currentRange

    }

    func stringHasPrefix(_ string: NSAttributedString) -> Bool {
        let prefixLength = MarkdownStyles.prefixWithSpace.length
        return string.prefix(length: prefixLength).string == MarkdownStyles.prefixWithSpace.string
    }
}

private extension RichEditorTextView {

    func paragraphsOfRange(range: NSRange, str: NSAttributedString) -> [NSRange] {
        let allParagraphRanges = paragraphRanges(in: textView.attributedText)
        return allParagraphRanges.filter { (range.location <= $0.location + $0.length) && (range.location + range.length > $0.location) }
    }

    func paragraphRanges(in str: NSAttributedString) -> [NSRange] {
        guard str.length > 0 else { return [] }

        func nextParagraphRange(at location: Int) -> NSRange {
            return NSString(string: str.string).paragraphRange(for: NSRange(location: location, length: 1))
        }

        var result = [nextParagraphRange(at: 0)]

        while let currentLocation = result.last?.upperBound, currentLocation < str.length {
            result.append(nextParagraphRange(at: currentLocation))
        }

        return result.filter { $0.length > 1 }
    }

    func addAttributesToRanges(in string: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any], ranges: [NSRange]) {
        ranges.forEach { paragraphRange in
            string.addAttributes(attributes, range: paragraphRange)
        }
    }

}

// TODO:
extension RichEditorTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        //self.attributedString = textView.attributedText
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        print("textViewDidChangeSelection")
        //print(textView.selectedRange)
        currentSelectedRange = textView.selectedRange
        updateAttributeState(forRange: textView.selectedRange)
    }

//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldEndEditing")
//    }
//
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldBeginEditing")
//    }
//
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextIn", text)
        // text empty indicates that deletion is happening. Text is only manually set when it is added not when deleted
//        if text.isEmpty {
//            return true
//        } else {
            updateString(with: text, at: range)
            return false
        //}

    }
//
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        print("shouldInteractWithURL")
//    }
//
//    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        print("shouldInteractWithtextAttachment")
//    }

}


class MyTextView: UITextView {

    // TODO: calculate caret position and size based on font
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        var superRect = super.caretRect(for: position)
//        guard let font = self.font else { return superRect }
//
//        // "descender" is expressed as a negative value,
//        // so to add its height you must subtract its value
//        superRect.size.height = font.pointSize - font.descender
//        print(superRect.size.height, font)
//        return superRect
//    }
}


// MARK: - Helpers

extension RichEditorTextView {
    func addSubviewWithPinnedEdgesToView(_ view: UIView,
                                                       subview: UIView,
                                                       pinToSafeAreaIfPossible: Bool = false,
                                                       topConstraintConstant: CGFloat = 0,
                                                       bottomConstraintConstant: CGFloat = 0,
                                                       leadingConstraintConstant: CGFloat = 0,
                                                       trailingConstraintConstant: CGFloat = 0,
                                                       priority: Float = 1000) {
        subview.removeFromSuperview()
        view.addSubview(subview)
        subview.frame = view.bounds
        subview.translatesAutoresizingMaskIntoConstraints = false

        if pinToSafeAreaIfPossible {
            configurePinnedConstraint(
                subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: leadingConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: trailingConstraintConstant),
                priority: priority)
        } else {
            configurePinnedConstraint(
                subview.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingConstraintConstant),
                priority: priority)
            configurePinnedConstraint(
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConstraintConstant),
                priority: priority)
        }
    }

    private func configurePinnedConstraint(_ constraint: NSLayoutConstraint, priority: Float) {
        constraint.priority = UILayoutPriority(priority)
        constraint.isActive = true
    }
}
