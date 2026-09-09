//
//  ContentView.swift
//  ios-kbtu
//
//  Created by Aktanberdi Ybyraiym on 09.09.2026.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ios_kbtuDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(ios_kbtuDocument()))
}
