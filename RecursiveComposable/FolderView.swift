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

    struct ViewState: Equatable {
        let content: IdentifiedArrayOf<Item>?
        let selectionItemId: Item.ID?
        let item: Item

        init(state: FolderState) {
            self.item = state.item
            self.content = state.content
            self.selectionItemId = state.selection.value?.item.id
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            VStack {
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
                            selection: viewStore.binding(get: \.selectionItemId, send: FolderAction.navigateTo),
                            label: {
                                Text(item.title)
                            })
                    }
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }.navigationTitle(viewStore.item.title)
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView(store: .init(initialState: .init(item: .init(id: .init(), title: "folder"), content: nil), reducer: folderReducer, environment: .init(contentProvider: .init())))
    }
}
