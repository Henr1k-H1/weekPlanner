//
//  Week_PlannerApp.swift
//  Week Planner
//
//  Created by Henrik "Henr1k" on 4/27/23.
//

import SwiftUI

@main
struct Week_PlannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
