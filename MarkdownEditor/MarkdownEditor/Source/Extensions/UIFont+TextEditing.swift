//
//  UIFont+TextEditing.swift
//  GIDMarkdown
//
//  Created by Petra Cackov on 15/03/2022.
//

import UIKit

extension UIFont {

    func hasTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        let traits = fontDescriptor.symbolicTraits
        return traits.contains(trait)
    }

    func addingTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        guard !traits.contains(trait) else { return self }
        traits.insert(trait)

        guard let newDescriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }

    func removingTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(trait) else { return self }
        traits.remove(trait)

        guard let newDescriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }

}
