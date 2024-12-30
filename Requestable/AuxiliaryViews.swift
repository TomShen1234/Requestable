//
//  AuxiliaryViews.swift
//  Requestable
//
//  Created by Tom Shen on 2024/12/26.
//

import SwiftUI

/// A simple helper that displays key-value pairs of a `[String: String]` dictionary
struct DictionaryForEachListContent: View {
    var dictionary: [String: String]
    var onClick: (String) -> Void
    
    var body: some View {
        ForEach(Array(dictionary.keys), id: \.self) { key in
            Button {
                onClick(key)
            } label: {
                HStack {
                    Text(key)
                    Spacer()
                    let value = dictionary[key]
                    Text(value ?? "")
                }
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }
}

