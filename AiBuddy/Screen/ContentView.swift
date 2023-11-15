//
//  ContentView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    // MARK: - Properties
    
    // Login Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    // Refresh Manager for homescreen
    @StateObject private var refreshManager = RefreshManager()
    
    // MARK: - Body
    
    var body: some View {
        
        // If the user is logged in, present HomeScreen
        if logStatus {
            HomeScreen(viewModel: HomeScreenViewModel(), refreshManager: refreshManager)
        } else {
        // If user is not logged in, present LoginScreen
            LoginScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
