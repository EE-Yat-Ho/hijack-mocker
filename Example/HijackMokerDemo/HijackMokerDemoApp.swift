//
//  HijackMokerDemoApp.swift
//  HijackMokerDemo
//
//  Created by 영호 박 on 8/1/24.
//

import SwiftUI
import HijackMoker

@main
struct HijackMokerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                HijackMokerToggle()
                PoketMonList()
            }
        }
    }
}

struct StaticMethods {
    static func useHijackMoker() -> Bool {
#if DEBUG
        true
#else
        false
#endif
    }
}

