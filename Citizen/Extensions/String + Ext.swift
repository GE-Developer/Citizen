//
//  String + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

extension String {
    var asMarkdown: AttributedString {
        (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }
}
