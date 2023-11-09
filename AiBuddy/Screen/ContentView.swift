//
//  ContentView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var nilString: String?
    @AppStorage("log_status") var logStatus: Bool = false
    @StateObject private var refreshManager = RefreshManager()
    var body: some View {
        if logStatus {
            HomeScreen(viewModel: HomeScreenViewModel(), refreshManager: refreshManager)
        } else {
            LoginScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
