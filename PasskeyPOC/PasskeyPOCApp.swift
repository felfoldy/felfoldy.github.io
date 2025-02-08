//
//  PasskeyPOCApp.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-13.
//

import SwiftUI
import SwiftPyConsole

@main
struct PasskeyPOCApp: App {
    init() {
        SwiftPyConsole.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
