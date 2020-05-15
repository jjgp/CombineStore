//
//  RootView.swift
//  TicTacToe
//
//  Created by Jason Prasad on 5/13/20.
//  Copyright © 2020 Jason Prasad. All rights reserved.
//

import CombineStore
import SwiftUI

struct AppEnvironment {
}

struct AppState {
}

enum AppActions {
}

func accumulator(state: inout AppState?, action: AppActions) -> AppState? {
    state
}

struct RootView: View {
    let store = Store(accumulator: accumulator(state:action:),
                      initialState: AppState(),
                      environment: AppEnvironment())

    var body: some View {
        StoreProvider(store) { store in
            NavigationView {
                LoginView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            Text(verbatim: "\(store)")
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
#endif
