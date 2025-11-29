//
//  wpaApp.swift
//  wpa
//
//  Created by huynh on 26/11/25.
//

import SwiftUI
import SwiftData

@main
struct wpaApp: App {
    @State private var pipe = Pipe(type: .straightHorizontal, rotation: 1) // ✅ @State ở parent view
    @State private var flowing = true

    var body: some Scene {
        WindowGroup {
            PipeDemoView()
        }
    }
}
