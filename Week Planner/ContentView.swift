//
//  ContentView.swift
//  Week Plan
//
//  Created by Henrik Scharm on 4/24/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
//        ScrollView() {
            Home()
//        }
    
    }

   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
