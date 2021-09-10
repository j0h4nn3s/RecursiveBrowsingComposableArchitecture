//
//  BrowserView.swift
//  RecursiveComposable
//
//  Created by Johannes Hubert on 09.09.21.
//

import SwiftUI
import ComposableArchitecture

struct FolderView: View {
    let store: Store<FolderState, FolderAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if let content = viewStore.state.content {
                List(content) { item in
                    NavigationLink(
                        destination: IfLetStore(
                            self.store.scope(
                                state: \.selection.value,
                                action: FolderAction.subFolder
                            ),
                            then: FolderView.init),
                        tag: item.id,
                        selection: viewStore.binding(get: \.selection.value?.item.id, send: FolderAction.navigateTo),
                        label: {
                            Text(item.title)
                        })
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView(store: .init(initialState: .init(item: .init(id: .init(), title: "folder"), content: nil), reducer: folderReducer, environment: .init(contentProvider: .init())))
    }
}
