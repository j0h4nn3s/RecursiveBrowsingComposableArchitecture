//
//  ContentView.swift
//  RecursiveComposable
//
//  Created by Johannes Hubert on 09.09.21.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: Store<RootState, RootAction>
    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            NavigationView {
                FolderView(store: self.store.scope(state: \.rootFolder, action: RootAction.rootFolder))
                    .navigationTitle("Root")
                    .onAppear(perform: {
                        viewStore.send(.onAppear)
                    })
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: .init(initialState: .init(rootFolder: .init(item: .init(id: .init(), title: "root"), content: nil)), reducer: rootReducer, environment: .init(contentProvider: .init())))
    }
}
