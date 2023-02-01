//
//  TCATestApp.swift
//  TCATest
//
//  Created by Mykhaylo Levchuk on 31/01/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCATestApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView(store: .init(initialState: Feature.State.init(), reducer: Feature()))
            TestView(store: .init(
                initialState: SearchFeature.State.init(name: ""),
                reducer: SearchFeature()._printChanges()
            ))
        }
    }
}
