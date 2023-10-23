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
    var body: some View {
        if logStatus {
            //MARK: Your Home View
            HomeScreen(viewModel: HomeScreenViewModel())
        } else {
            LoginScreen()
        }
    }
    
    @ViewBuilder
    func DemoHome() -> some View {
//        NavigationStack {
//            Text("Logged In")
//            Button("Crash") {
//              print(nilString!)
//            }
//                .navigationTitle("Multi-Login")
//                .toolbar {
//                    ToolbarItem {
//                        Button("Logout") {
//                            try? Auth.auth().signOut()
//                            GIDSignIn.sharedInstance.signOut()
//                            withAnimation(.easeInOut) {
//                                logStatus = false
//                            }
//                        }
//                    }
//                }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//import SwiftUI
//import CoreData
//
//
//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
////    @FetchRequest(
////        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
////        animation: .default)
////    private var items: FetchedResults<Item>
////
//    var body: some View {
//        NavigationView {
////            List {
////                ForEach(items) { item in
////                    NavigationLink {
////                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
////                    } label: {
////                        Text(item.timestamp!, formatter: itemFormatter)
////                    }
////                }
////                .onDelete(perform: deleteItems)
////            }
////            .toolbar {
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    EditButton()
////                }
////                ToolbarItem {
////                    Button(action: addItem) {
////                        Label("Add Item", systemImage: "plus")
////                    }
////                }
////            }
//            Text("Select an item")
//        }
//    }
//
////    private func addItem() {
////        withAnimation {
////            let newItem = Item(context: viewContext)
////            newItem.timestamp = Date()
////
////            do {
////                try viewContext.save()
////            } catch {
////                Replace this implementation with code to handle the error appropriately.
////                fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
////                let nsError = error as NSError
////                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
////            }
////        }
////    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
////            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
////                Replace this implementation with code to handle the error appropriately.
////                fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
