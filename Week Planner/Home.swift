//
//  Home.swift
//  trainingPlan
//
//  Created by Henrik "Henr1k" on 4/17/23.
//

import SwiftUI
import CoreData
import WidgetKit

let tasksView = TaskList()

struct Home: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name),
    ]) var exercises: FetchedResults<Exercise>
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .top) {
                CustomColor.background
                    .ignoresSafeArea()
                VStack() {
                    Text("Week Planner")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(CustomColor.title)
                        .padding(.leading, 5)
                        .padding(.top, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WeekPlannerArea()
                    Divider()
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                    
                    Text("Tasks")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(CustomColor.title)
                        .padding(.leading, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TaskArea()
                }
                .padding(.leading,5)
                .padding(.trailing,5)
            }
            .toolbar {
                ToolbarItemGroup() {
                    NavigationLink(destination: tasksView) {
                        Text("Manage Tasks")
                        Image(systemName: "chevron.right")
                        
                        
                    }
                }
            }
        }
        .tint(CustomColor.highlight)
    }
    
    func allExercisesUsed() -> Bool {
        for exercise in exercises {
            if exercise.isUsed == false {
                return false
            }
        }
        return true
        
    }
    
    @ViewBuilder
    func WeekPlannerArea() -> some View {
        VStack(spacing: 15) {
            ForEach(days, id: \.self) { day in
                VStack() {
                    HStack() {
                        Text(day.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor((Date().dayOfWeek()!) == day.name ? CustomColor.highlight : CustomColor.day)
                            .frame(maxWidth: 100, alignment: .leading)
                            .padding(.leading, 10)
                        if ((exercises.firstIndex(where: { $0.day == day.name })) != nil) {
                            let i = exercises.firstIndex(where: { $0.day == day.name })!
                            HStack() {
                                VStack() {
                                    Text(exercises[i].name ?? "")
                                        .font(.system(size: 15))
                                        .foregroundColor((Date().dayOfWeek()!) == day.name ? CustomColor.highlight : CustomColor.task)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                Button(action: {
                                    exercises[i].day = ""
                                    exercises[i].isUsed = false
                                    //                                    saveContext()
                                    PersistenceController.shared.saveCoreData()
                                } ) {
                                    Image(systemName: "minus.circle.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(CustomColor.highlight)
                                        .clipShape(Circle())
                                    
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(CustomColor.background))
                            .onDrop(of: [.url], isTargeted: .constant(false)) {
                                providers in
                                if let first = providers.first {
                                    let _ = first.loadObject(ofClass: URL.self) {
                                        value, error in
                                        guard let draggedExerciseID = value else { return }
                                        let j = exercises.firstIndex(where: { $0.id?.uuidString == draggedExerciseID.path})!
                                        
                                        exercises[i].isUsed = false
                                        exercises[i].day = ""
                                        
                                        exercises[j].isUsed = true
                                        exercises[j].day = day.name
                                        //                                        saveContext()
                                        PersistenceController.shared.saveCoreData()
                                    }
                                }
                                return false
                            }
                            .onDrag {
                                return .init(contentsOf: URL(string: exercises[i].id!.uuidString))!
                            }
                        } else {
                            VStack() {
                                Text("Drop task here")
                                    .font(.system(size: 16))
                                    .foregroundColor(CustomColor.task)
                            }
                            
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(CustomColor.background))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [3]))
                            )
                            
                            .onDrop(of: [.url], isTargeted: .constant(false)) {
                                providers in
                                if let first = providers.first {
                                    let _ = first.loadObject(ofClass: URL.self) {
                                        value, error in
                                        guard let draggedExerciseID = value else { return }
                                        let i = exercises.firstIndex(where: { $0.id?.uuidString == draggedExerciseID.path})!
                                        exercises[i].isUsed = true
                                        exercises[i].day = day.name
                                        //                                        saveContext()
                                        PersistenceController.shared.saveCoreData()
                                        
                                    }
                                }
                                return false
                            }
                        }
                    }
                }
                
            }
            .padding(.bottom, 10)
            
        }
    }
    
    @ViewBuilder
    func TaskArea() -> some View {
        if exercises.count < 1 {
            Text("No tasks have been saved yet")
                .font(.system(size: 20))
                .foregroundColor(CustomColor.muted)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 25)
            
        } else if exercises.count > 0 && allExercisesUsed() {
            Text("All tasks have been assigned")
                .font(.system(size: 20))
                .foregroundColor(CustomColor.muted)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 25)
            
        } else {
            VStack() {
                ScrollView(.horizontal) {
                    HStack() {
                        ForEach(exercises) { exercise in
                            HStack(alignment: .center) {
                                if exercise.isUsed == false {
                                    Text(exercise.name ?? "Not found")
                                        .font(.system(size: 16))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(CustomColor.highlight)
                                        }
                                    
                                        .foregroundColor(CustomColor.background)
                                        .onDrag {
                                            return .init(contentsOf: URL(string: exercise.id!.uuidString))!
                                            
                                        }
                                }
                            }.padding(.trailing, 5)
                        }
                    }
                    .padding(.bottom, 15)
                }
            }
        }
    }
    
    struct Home_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

