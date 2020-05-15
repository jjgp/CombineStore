//
//  LoginView.swift
//  TicTacToe
//
//  Created by Jason Prasad on 5/14/20.
//  Copyright © 2020 Jason Prasad. All rights reserved.
//

import CombineStore
import SwiftUI

private func accumulator(state: inout Int?, action: AppActions) -> Int? {
    state
}

struct LoginView: View {
    let store = Store(accumulator: accumulator(state:action:),
                      initialState: 1,
                      environment: AppEnvironment())

    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            Form {
                StoreProvider(store) { store in
                    Section(header: Text(
                        """
              To login use any email and "password" for the password. If your email contains the \
              characters "2fa" you will be taken to a two-factor flow, and on that screen you can \
              use "1234" for the code.
              """
                        )
                    ) {
                        EmptyView()
                    }
                    Section(header: Text("Email")) {
                        TextField("blob@pointfree.co", text: self.$email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                    }
                    Section(header: Text("Password")) {
                        SecureField("••••••••", text: self.$password)
                    }
                }
                Text(verbatim: "\(store)")
                StoreProvider { (store: Store<AppState, AppActions>) in
                    Text(verbatim: "\(store)")
                }
            }
        }
        .navigationBarTitle("Login")
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
