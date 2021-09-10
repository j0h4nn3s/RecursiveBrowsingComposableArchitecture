//
//  RecursiveComposableApp.swift
//  RecursiveComposable
//
//  Created by Johannes Hubert on 09.09.21.
//

import SwiftUI

@main
struct RecursiveComposableApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialState: .init(rootFolder: .init(item: .init(id: .init(), title: "root"), content: nil)), reducer: rootReducer, environment: .init(contentProvider: .init())))
        }
    }
}
