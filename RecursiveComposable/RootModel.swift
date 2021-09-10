//
//  RootModel.swift
//  RecursiveComposable
//
//  Created by Johannes Hubert on 09.09.21.
//

import Foundation
import ComposableArchitecture

struct RootState: Equatable {
    var rootFolder: FolderState
    var loaded: Bool = false
}

enum RootAction {
    case onAppear
    case rootFolder(FolderAction)
    case rootContentLoaded(IdentifiedArrayOf<Item>)
}

struct RootEnvironment {
    let contentProvider: ContentProvider
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
    folderReducer.pullback(state: \RootState.rootFolder, action: /RootAction.rootFolder, environment: { .init(contentProvider: $0.contentProvider) }),
    .init { state, action, environment in
        switch action {
        case .onAppear:
            guard !state.loaded else {
                return .none
            }
            state.loaded = true
            return environment.contentProvider.load(for: state.rootFolder.item.id)
                .receive(on: DispatchQueue.main)
                .map {.rootContentLoaded($0) }
                .eraseToEffect()
        case .rootContentLoaded(let items):
            state.rootFolder.content = items
            return .none
        case .rootFolder:
            return .none
        }
    }
)
