//
//  FolderModel.swift
//  RecursiveComposable
//
//  Created by Johannes Hubert on 09.09.21.
//

import Foundation
import ComposableArchitecture
import Combine

struct FolderState: Equatable {
    var item: Item
    var content: IdentifiedArrayOf<Item>?

    var selection: Selection = .none
}

indirect enum Selection: Equatable {
    case none
    case folder(FolderState)

    var value: FolderState? {
        get {
            switch self {
            case .folder(let state):
                return state
            case .none:
                return nil
            }
        }
        set {
            if let value = newValue {
                self = .folder(value)
            } else {
                self = .none
            }
        }
    }
}

indirect enum FolderAction {
    case navigateTo(Item.ID?)
    case selectedContentLoaded(IdentifiedArrayOf<Item>)
    case subFolder(FolderAction)
}

struct FolderEnvironment {
    let contentProvider: ContentProvider
}

private struct CancelID: Hashable {}

let folderReducer = Reducer<FolderState, FolderAction, FolderEnvironment>.recurse { `self`, state, action, environment in
    switch action {
    case .navigateTo(.none):
        state.selection = .none
        return .cancel(id: CancelID())
    case let .navigateTo(.some(id)):
        guard let item = state.content?[id: id] else {
            fatalError("trying to navigate to id \(id) but content only has ids \(String(describing: state.content?.ids))")
        }
        state.selection = .folder(.init(item: item, selection: .none))
        return environment.contentProvider.load(for: id)
            .receive(on: DispatchQueue.main)
            .map {.selectedContentLoaded($0) }
            .eraseToEffect()
            .cancellable(id: CancelID())
    case let .selectedContentLoaded(items):
        guard var subState = state.selection.value else {
            return .none
        }
        subState.content = items
        state.selection = .folder(subState)
        return .none
    case .subFolder:
        return self.optional().pullback(
            state: \.selection.value,
            action: /FolderAction.subFolder,
            environment: { $0 }
        )
        .run(&state, action, environment)
    }
}

struct Item: Equatable, Identifiable {
    let id: Int
    let title: String
}

class ContentProvider {
    func load(for id: Int) -> Future<IdentifiedArrayOf<Item>, Never> {
        return .init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                promise(.success(.init(uniqueElements: [Item].dummy)))
            }
        }
    }
}

var id = 0

extension Array where Element == Item {
    static var dummy: Self {
        var items: Self = []
        for _ in 0..<3 {
            id += 1
            let item = Item(id: id, title: "folder \(id)")
            items.append(item)
        }
        return items
    }
}

extension Reducer {
    static func recurse(_ reducer: @escaping (Reducer, inout State, Action, Environment) -> Effect<Action, Never>) -> Reducer {
        var `self`: Reducer!
        self = Reducer { state, action, environment in
            reducer(self, &state, action, environment)
        }
        return self
    }
}
