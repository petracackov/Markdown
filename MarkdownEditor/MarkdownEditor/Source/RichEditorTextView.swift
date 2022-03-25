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
    func richEditorTextViewDidPasteText(_ sender: RichEditorTextView)
    func richEditorTextViewDidChangeText(_ sender: RichEditorTextView)
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
        textView.onPasteAction = { [weak self] in
            guard let self = self else { return }
            self.delegate?.richEditorTextViewDidPasteText(self)
        }
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


    public private(set) var attributedString: NSAttributedString? {
        didSet {
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
            guard attributedString != oldValue else { return }
            textView.attributedText = attributedString
            delegate?.richEditorTextViewDidChangeText(self)
        }
    }

    // MARK: - TextView selected options

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
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
            guard oldValue != boldIsActive else { return }
            delegate?.richEditorTextView(self, didChangeBoldSelection: boldIsActive)
        }
    }

    private var italicIsActive: Bool = false {
        didSet {
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
            guard oldValue != italicIsActive else { return }
            delegate?.richEditorTextView(self, didChangeItalicSelection: italicIsActive)
        }
    }

    private var listIsActive: Bool = false {
        didSet {
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
            guard oldValue != listIsActive else { return }
            delegate?.richEditorTextView(self, didChangeListSelection: listIsActive)
        }
    }

    private var headingIsActive: Bool = false {
        didSet {
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
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

    func updateTextField(with string: NSAttributedString) {
        let currentRange = currentSelectedRange
        attributedString = string
        textView.selectedRange = currentRange
    }

}

// MARK: - Selection functions

extension RichEditorTextView {

    func selectBold() {
        guard headingIsActive == false else { return }
        boldIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        AttributedStringTool.toggleTrait(.traitBold, to: mutableString, in: currentSelectedRange)
        updateTextField(with: mutableString)
    }

    func selectItalic() {
        guard headingIsActive == false else { return }
        italicIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        AttributedStringTool.toggleTrait(.traitItalic, to: mutableString, in: currentSelectedRange)
        updateTextField(with: mutableString)
    }

    func selectList() {
        listIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)

        // To prevent wrong strings in specific range, ranges must be sorted from the greatest to the smallest. The string will be modified in for loop from the bigger range location to the smallest. That is because that the changes on the specific range do not change the string in the smaller range
        let selectedParagraphs = textView.attributedText.paragraphsOfRange(range: currentSelectedRange).sorted { $0.location > $1.location }

        let paragraphStyle = listIsActive ? MarkdownStyles.listParagraphStyle : MarkdownStyles.paragraphStyles.body

        selectedParagraphs.forEach { paragraphRange in

            var paragraphString = NSMutableAttributedString(attributedString: mutableString.attributedSubstring(from: paragraphRange))

            if listIsActive, !stringHasPrefix(paragraphString) {
                // append prefix to the current paragraph string if it does not yet exist
                let prefixWithParagraphString = NSMutableAttributedString(attributedString: MarkdownStyles.prefixWithSpace)
                prefixWithParagraphString.append(paragraphString)
                paragraphString = prefixWithParagraphString

            } else if !listIsActive, stringHasPrefix(paragraphString) {
                // remove prefix from the current paragraph if it exists
                paragraphString.replaceCharacters(in: NSRange(location: 0, length: MarkdownStyles.prefixWithSpace.length), with: "")
            }

            // add correct paragraph style -> indent to the new string
            paragraphString.addAttribute(for: .paragraphStyle, value: paragraphStyle)

            // replace the old string with the new one -> should not mess with other paragraphStrings ranges since ranges are adjusted from bigger to smaller
            mutableString.replaceCharacters(in: paragraphRange, with: paragraphString)
        }

        updateTextField(with: mutableString)
    }

    func selectHeading() {

        headingIsActive.toggle()

        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        let selectedParagraphs = textView.attributedText.paragraphsOfRange(range: currentSelectedRange)
        let attributes = headingIsActive ? headingAttributes : baseAttributes
        mutableString.addAttributesToRanges(attributes: attributes, ranges: selectedParagraphs)

        if headingIsActive {
            listIsActive = false
            italicIsActive = false
            boldIsActive = false
        }

        updateTextField(with: mutableString)
    }
}

private extension RichEditorTextView {

    private func updateSelectedState(forRange range: NSRange) {
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
            AttributedStringTool.addTrait(.traitBold, to: attributedNewString, in: attributedNewString.fullRange)
        }

        if italicIsActive {
            AttributedStringTool.addTrait(.traitItalic, to: attributedNewString, in: attributedNewString.fullRange)
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

        self.attributedString = updateStringWithLinkAttributes(mutableText)
        textView.selectedRange = currentRange

    }

    private func updateStringWithLinkAttributes(_ string: NSAttributedString) -> NSAttributedString {

        let mutableText = NSMutableAttributedString(attributedString: string)
        mutableText.addAttribute(for: .foregroundColor, value: MarkdownStyles.colorCollection.body)

        let linkRanges = AttributedStringTool.detectedURLRanges(in: string)
        linkRanges.forEach { mutableText.addAttribute(.foregroundColor, value: MarkdownStyles.colorCollection.link, range: $0) }

        return mutableText
    }
}

private extension RichEditorTextView {



    func stringHasPrefix(_ string: NSAttributedString) -> Bool {
        let prefixLength = MarkdownStyles.prefixWithSpace.length
        return string.prefix(length: prefixLength).string == MarkdownStyles.prefixWithSpace.string
    }

    func isBeginningOfParagraph(range: NSRange) -> Bool {
        guard range.length == 0 else { return false }
        let allParagraphRangesLocations = textView.attributedText.paragraphRanges()
        return allParagraphRangesLocations.contains(where: { ($0.location == range.location) || ($0.length + $0.location == range.location) })
    }

}



extension RichEditorTextView: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
    }

    public func textViewDidChange(_ textView: UITextView) {
        // Will never be called because shouldChangeTextIn returns false and handles text changes manually
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        currentSelectedRange = textView.selectedRange
        updateSelectedState(forRange: textView.selectedRange)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        updateString(with: text, at: range)
        return false
    }

//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldEndEditing")
//    }
//
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldBeginEditing")
//    }
//
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

    var onPasteAction: (() -> Void)?

    override func paste(_ sender: Any?) {
        super.paste(sender)

        onPasteAction?()
    }
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
