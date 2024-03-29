//
//  ViewController.swift
//  Markdown
//
//  Created by Petra Cackov on 01/03/2022.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var editingView: RichEditorTextView!
    @IBOutlet weak var bottomButtonsConstraint: NSLayoutConstraint!

    private lazy var editorButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var boldButton: UIButton = {
        let button = UIButton()
        button.setTitle("B", for: .normal)
        button.addTarget(self, action: #selector(boldButtonPress), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var italicButton: UIButton = {
        let button = UIButton()
        button.setTitle("I", for: .normal)
        button.addTarget(self, action: #selector(italicButtonPress), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var header: UIButton = {
        let button = UIButton()
        button.setTitle("H1", for: .normal)
        button.addTarget(self, action: #selector(headingButtonPress), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var list: UIButton = {
        let button = UIButton()
        button.setTitle("*", for: .normal)
        button.addTarget(self, action: #selector(listButtonPress), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var markdownTestButton: UIButton = {
        let button = UIButton()
        button.setTitle("M", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var closeKeyboardButton: UIButton = {
        let button = UIButton()
        button.setTitle("⌨", for: .normal)
        button.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    private lazy var markdown: String = markdown4
    private var markdown4: String { "Heading \n normal text \n nor mal*text*line 2 sho uld be some long line" }
    private var markdown0: String { "\n- First **item** \n still first item still first item still first item still first item still first item still first item still first item still first item still first item  \n- Second item" }
    private var markdown1: String { "# nooormal line \n\n kjdg \n laihg \n \n- First **item** \n still first item \n- Second item \n \n \n- Indented item \n    - Indented item \n- Fourth item \n\n normal line" }
    private var markdown2: String { "empty line \n - first line \n still **first line** \n- second line \n\nThird normal line" }
    private var markdown3: String { "# heding\n hello \n - **hello hello hello hello \nhello hello hello hello hello**\n- **,kk _boldItaliwc_**\n\n**hello** \n _italic_ **,kk _boldItalic_** www.google.com" }
    private var markdown5: String { "# heding\n hello \n - **hello hello hello hello \nhello hello hello hello hello**\n- **,kk _boldItaliwc_**\n\n**hello** \n _italic_ **,kk _boldItalic_** www.google.com👚" }
    private var markdown6: String { "**b **hello**hello \n **_italic👚_ **,kk _boldItalic👚_** 👚" }
    private var markdown7: String { "hello👚 \n _italic👚_ **bold👚**" }
    private var markdown8: String { "**https://google.com**" }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupEditor()
        KeyboardManager.sharedInstance.willChangeFrameDelegate = self
        [markdownTestButton, boldButton, italicButton, header, list, closeKeyboardButton].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
    }

    private func setupEditor() {
        let attributedString = MarkdownGenerator.attributedString(fromMarkdown: markdown) ?? NSAttributedString(string: "")
        editingView.delegate = self
        editingView.updateTextField(with: attributedString)
    }

    // MARK: - Button actions


    @objc private func boldButtonPress() {
        editingView.toggleBold()
    }

    @objc private func italicButtonPress() {
        editingView.toggleItalic()
    }

    @objc private func headingButtonPress() {
        editingView.toggleHeading()
    }
    @objc private func listButtonPress() {
        editingView.toggleList()

    }

    @objc private func buttonAction() {
        guard let attributedString = editingView.attributedString else { return }
        editingView.markdownStringLabel.text = MarkdownGenerator.markdown(fromAttributedString: attributedString)
        editingView.layoutIfNeeded()
    }

    @objc private func closeKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - RichEditorTextViewDelegate

extension ViewController: RichEditorTextViewDelegate {

    func richEditorTextView(_ sender: RichEditorTextView, didChangeBoldSelection isSelected: Bool) {
        boldButton.backgroundColor = isSelected ? .gray : .white
    }

    func richEditorTextView(_ sender: RichEditorTextView, didChangeItalicSelection isSelected: Bool) {
        italicButton.backgroundColor = isSelected ? .gray : .white
    }

    func richEditorTextView(_ sender: RichEditorTextView, didChangeListSelection isSelected: Bool) {
        list.backgroundColor = isSelected ? .gray : .white
    }

    func richEditorTextView(_ sender: RichEditorTextView, didChangeHeadingSelection isSelected: Bool) {
        header.backgroundColor = isSelected ? .gray : .white
    }


}

// MARK: - KeyboardManagerWillChangeFrameDelegate

extension ViewController: KeyboardManagerWillChangeFrameDelegate {
    func keyboardManagerWillChangeKeyboardFrame(sender: KeyboardManager, from startFrame: CGRect, to endFrame: CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.bottomButtonsConstraint.constant = endFrame.origin.y > startFrame.origin.y ? -(self.buttonsStackView?.bounds.height ?? 0) : endFrame.height
            self.view.layoutIfNeeded()
        }
    }
}
