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
        textView.autocapitalizationType = .none
        textView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                       NSAttributedString.Key.foregroundColor: UIColor.red]
        textView.keyboardDismissMode = .interactive
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .white
        textView.font = MarkdownStyles.fontCollection.body
        textView.textColor = MarkdownStyles.colorCollection.body

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

    public private(set) var attributedString: NSAttributedString? {
        didSet {
            // check tor same value is there to prevent creating a cycle -> DO NOT TOUCH IT
            guard attributedString != oldValue else { return }
            textView.attributedText = attributedString
            delegate?.richEditorTextViewDidChangeText(self)
        }
    }

    // MARK: - TextView selected options

    /// should only be updated by delegate method
    /// Every time the attributed string s set on textView (so on every change) the selected state is reset. Therefore a reference of last cursor position is needed
    lazy private var currentSelectedRange: NSRange = NSRange(location: attributedString?.length ?? 0, length: 0) {
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

    /// Use for setting the new (updated) string in text view. It also adjusts/preserves the current cursor/selection state. Do not directly change attributedText on text view.
    /// - Parameters:
    ///   - string: updated string that replaces the current string in text view
    ///   - newRange: updated cursor/selected range based on changes made on new attributed string. Default value is preserving previous state -> currentSelectedRange.
    func updateTextField(with string: NSAttributedString, newRange: NSRange? = nil) {
        let currentRange = currentSelectedRange
        attributedString = string
        textView.selectedRange = newRange ?? currentRange
    }

}

// MARK: - Selection functions

extension RichEditorTextView {

    /// Toggles bold attribute in the current selected range of the attributedString in textView
    func toggleBold() {
        guard headingIsActive == false else { return }
        boldIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        AttributedStringTool.toggleTrait(.traitBold, to: mutableString, in: currentSelectedRange)
        updateTextField(with: mutableString)
    }

    /// Toggles italic attribute in the current selected range of the attributedString in textView
    func toggleItalic() {
        guard headingIsActive == false else { return }
        italicIsActive.toggle()
        let mutableString = NSMutableAttributedString(attributedString:  textView.attributedText)
        AttributedStringTool.toggleTrait(.traitItalic, to: mutableString, in: currentSelectedRange)
        updateTextField(with: mutableString)
    }

    /// Toggles list attribute in the current selected range of the attributedString in textView
    func toggleList() {
        guard let attributedString = attributedString else { return }
        listIsActive.toggle()
        let updatedString = selectList(listIsActive, range: currentSelectedRange, string: attributedString)
        updateTextField(with: updatedString.string, newRange: updatedString.range)
    }

    /// Toggles heading attribute in the current selected range of the attributedString in textView
    func toggleHeading() {
        guard let attributedString = attributedString else { return }
        headingIsActive.toggle()


        // let cleanString = selectList(false, range: currentSelectedRange, string: attributedString)

        let newAttributedString = selectHeading(headingIsActive, range: currentSelectedRange, string: attributedString)
        updateTextField(with: newAttributedString.string, newRange: newAttributedString.range)
    }


    /// Adds heading parameters or removes them on selected range. It also removes list attributes if needed.
    /// - Parameters:
    ///   - selected: state to determine if heading attributes should should be added or removed
    ///   - range: range to remove or apply the heading to
    ///   - string: string to apply the heading to on corresponding range
    ///   - cleanString: if other attributes (list ones) should also be removed
    /// - Returns: returns an updated string with updated range that those changes were made on
    private func selectHeading(_ selected: Bool, range: NSRange, string: NSAttributedString, cleanString: Bool = true) -> (string: NSMutableAttributedString, range: NSRange) {

        var mutableString = NSMutableAttributedString(attributedString:  string)
        var range = range

        if cleanString {
            // first remove/clean string selection of any list paragraphs if there are any and updates the current range
            let cleanString = selectList(false, range: range, string: mutableString, cleanString: false)
            mutableString = cleanString.string
            range = cleanString.range
        }

        // create new string with new attributes (heading or base base attributes depends on selected state) at specific range
        let selectedParagraphs = mutableString.paragraphsOfRange(range: range)
        let attributes = selected ? headingAttributes : baseAttributes
        mutableString.setAttributesToRanges(attributes: attributes, ranges: selectedParagraphs)
        return (mutableString, range)
    }

    /// Adds list parameters or removes them on selected range. It also removes heading attributes if needed.
    /// - Parameters:
    ///   - selected: state to determine if list attributes should be added or removed
    ///   - range: range to remove or apply the list at
    ///   - string: string to apply the list to on corresponding range
    ///   - cleanString: if other attributes (heading one) should also be removed
    /// - Returns: returns an updated string with updated range that those changes were made on
    private func selectList(_ selected: Bool, range: NSRange, string: NSAttributedString, cleanString: Bool = true) -> (string: NSMutableAttributedString, range: NSRange) {

        let mutableString = NSMutableAttributedString(attributedString:  string)

        let paragraphStyle = selected ? MarkdownStyles.listParagraphStyle : MarkdownStyles.paragraphStyles.body

        // To prevent wrong strings in specific range, ranges must be sorted from the greatest to the smallest. The string will be modified in for loop from the bigger range location to the smallest. That is because that the changes on the specific range do not change the string in the smaller range
        var selectedParagraphs = string.paragraphsOfRange(range: range).sorted { $0.location > $1.location }

        // If there isn't any text yet append the current selected range -> 0, 0
        if selectedParagraphs.isEmpty {
            selectedParagraphs.append(range)
        }

        var updatedRange = range

        selectedParagraphs.forEach { paragraphRange in

            // String representing a paragraph
            var paragraphString = NSMutableAttributedString(attributedString: mutableString.attributedSubstring(from: paragraphRange))

            // Remove all heading styles that are in the selected range
            if MarkdownStyles.isHeading(paragraphString), cleanString {
                paragraphString = selectHeading(false, range: paragraphString.fullRange, string: paragraphString, cleanString: false).string
            }

            // append prefix to the current paragraph string if it does not yet exist
            if selected, !stringHasPrefix(paragraphString) {
                let prefixWithParagraphString = NSMutableAttributedString(attributedString: MarkdownStyles.prefixWithSpace)
                prefixWithParagraphString.append(paragraphString)
                paragraphString = prefixWithParagraphString

                // Adjust current selection/cursor position to match added prefix
                if paragraphRange.location <= updatedRange.location {
                    // prefix was added on the left of selection
                    updatedRange.location += MarkdownStyles.prefixLength
                } else if updatedRange.length > 0 {
                    // prefix fas added somewhere in the middle of selection
                    updatedRange.length += MarkdownStyles.prefixLength
                }
            // remove prefix from the current paragraph if it exists
            } else if !selected, stringHasPrefix(paragraphString) {

                if paragraphString.length <= MarkdownStyles.prefixLength  {
                    // if paragraph string only has prefix replace it with new line/ paragraph string
                    paragraphString.replaceCharacters(in: NSRange(location: 0, length: MarkdownStyles.prefixWithSpace.length), with: "\n")
                } else {
                    // replace just the prefix with empty string -> remove prefix
                    paragraphString.replaceCharacters(in: NSRange(location: 0, length: MarkdownStyles.prefixWithSpace.length), with: "")
                }

                // Adjust current selection/cursor position to match added prefix
                if paragraphRange.location < updatedRange.location {
                    // prefix was removed on the left of selection
                    updatedRange.location -= MarkdownStyles.prefixLength
                } else if updatedRange.length > 0 {
                    // prefix fas removed somewhere in the middle of selection
                    updatedRange.length -= MarkdownStyles.prefixLength
                }

            }

            // add correct paragraph style -> add indent to the new string
            paragraphString.addAttribute(for: .paragraphStyle, value: paragraphStyle)


            // replace the old string with the new one -> should not mess with other paragraphStrings ranges since ranges are adjusted from bigger to smaller
            mutableString.replaceCharacters(in: paragraphRange, with: paragraphString)
        
        }
        return (mutableString, updatedRange)

    }
}

private extension RichEditorTextView {


    /// Called every time the cursor is moved or text is selected. It updates the current state of the attributes italic, bold, heading and list).
    /// - Parameter range: range in witch the selection is based of relative to the whole attributed string
    private func updateSelectedState(forRange range: NSRange) {

        // if range has length 0 there are no attributes there to determine what style is selected. The bigger range selects text in front or behind cursor depending on its location.
        var biggerRange = range

        // if cursor is at the beginning (and there is no text selected) of paragraph adapt the style of the character following/on the right of the current cursor position
        if attributedString?.isBeginningOfParagraph(range: range) != nil {
            biggerRange.length += 1
        // if the cursor does not select any text (length == 0), adapt the style of the character on the left side of cursor location
        } else if range.length == 0 && range.location > 0 {
            biggerRange.length += 1
            biggerRange.location -= 1
        }

        let attributedString = textView.attributedText.attributedSubstring(from: biggerRange)

        // set the selection state based on the selected range
        headingIsActive = MarkdownStyles.isHeading(attributedString)
        listIsActive = MarkdownStyles.isList(attributedString)
        boldIsActive = AttributedStringTool.allFontsContainTrait(.traitBold, attributedString: attributedString) && !headingIsActive
        italicIsActive = AttributedStringTool.allFontsContainTrait(.traitItalic, attributedString: attributedString)

        // adjust cursor location/currentSelected state if its location lands on the list prefix -> editing of the list prefix should not be allowed
        self.attributedString?.paragraphsOfRange(range: range).forEach { paragraph in
            let paragraphString = textView.attributedText.attributedSubstring(from: paragraph)

            if MarkdownStyles.isList(paragraphString) {
                let lowerBoundDifference = abs(range.location - paragraph.location)
                let upperBoundDifference = abs(range.location + range.length - paragraph.location)

                // if the cursor is somewhere where the prefix is move it after prefix
                if lowerBoundDifference < MarkdownStyles.prefixLength {
                    textView.selectedRange.location += MarkdownStyles.prefixLength - lowerBoundDifference
                    // if cursor has selected text also adjust selection length (make it so it does not select more text)
                    if range.length > 0 {
                        textView.selectedRange.length -= MarkdownStyles.prefixLength - lowerBoundDifference
                    }
                // if the selected text, the end of selection is where the prefix is adjust the selection so it ends outside of prefix
                } else if upperBoundDifference <  MarkdownStyles.prefixLength {
                    textView.selectedRange.length -= MarkdownStyles.prefixLength - upperBoundDifference
                }
            }
        }
    }

    // TODO: improve -> handle the replacing characters and adding characters differently. Currently if text with different attributes is selected the replacing string does not adapt the characters quite correctly -> edge case (select heading and part of list and press a character. We get heading with partially normal/body styled text
    /// Updates the current attributed string in textView with new string
    /// - Parameters:
    ///   - string: new string that should replace characters in current attributed string in textView
    ///   - range: range on witch the new string should replace the characters
    private func updateString(with string: String, at range: NSRange) {
        guard let attributedString = attributedString else { return }
        let wholeText = NSMutableAttributedString(attributedString: attributedString)
        let newAttributedString = NSMutableAttributedString(string: string)
        newAttributedString.setAttributes(baseAttributes)

        if boldIsActive {
            // if bold is active add bold trait to the new string
            AttributedStringTool.addTrait(.traitBold, to: newAttributedString, in: newAttributedString.fullRange)
        }

        if italicIsActive {
            // if italic is active add italic trait to the new string
            AttributedStringTool.addTrait(.traitItalic, to: newAttributedString, in: newAttributedString.fullRange)
        }

        if headingIsActive {
            // if heading is active add heading attributes to the new string
            newAttributedString.setAttributes(headingAttributes)
        }

        if listIsActive {
            // if paragraph is active (cursor is currently somewhere in the paragraph style)
            // and if string represents new line
            if string == "\n" {
                let previousRange = NSRange(location: range.location - MarkdownStyles.prefixLength, length: MarkdownStyles.prefixLength)
                let previousString = wholeText.attributedSubstring(from: previousRange)
                // and if range before current selected range has prefix remove the list styling
                // (and return from function since cursor and selection is handled in the list logic.
                if stringHasPrefix(previousString) {
                    toggleList()
                    return
                // otherwise append prefix to new string
                } else {
                    newAttributedString.append(MarkdownStyles.prefixWithSpace)
                }
            //  if deletion is triggered and cursor is in front of prefix then remove list styling and return from function
            } else if newAttributedString.length == 0, currentSelectedRange.length == 0, self.attributedString?.isBeginningOfParagraph(range: range, prefixLength: MarkdownStyles.prefixLength) != nil {
                toggleList()
                return
            }
            // add list attributes to new string
            newAttributedString.addAttributes(listAttributes)
        }

        // update existing string with new one
        wholeText.replaceCharacters(in: range, with: newAttributedString)

        var currentRange = currentSelectedRange

        // An empty string is replacing the previous character -> deletion of one character
        if newAttributedString.length == 0, currentRange.length == 0 {
            currentRange.location -= 1
        } else {
            currentRange.location += newAttributedString.length
        }
        // if text was previously selected (the length of range was not 0) after replacing characters it should not be selected anymore
        currentRange.length = 0

        // detect if string has any links and update them with special styling
        let newString = updateStringWithLinkAttributes(wholeText)
        updateTextField(with: newString, newRange: currentRange)

    }

    /// detects if any links are present in the string and adds a special styling/color to them
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

    // TODO: calculate caret position and size based on font -> nice to have
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
