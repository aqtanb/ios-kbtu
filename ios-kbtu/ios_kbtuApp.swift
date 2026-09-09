//
//  ios_kbtuApp.swift
//  ios-kbtu
//
//  Created by Aktanberdi Ybyraiym on 09.09.2026.
//

import SwiftUI

@main
struct ios_kbtuApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ios_kbtuDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
