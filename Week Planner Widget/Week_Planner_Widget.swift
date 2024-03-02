//
//  Week_Planner_Widget.swift
//  Week Planner Widget
//
//  Created by Henrik Scharm on 4/27/23.
//

import WidgetKit
import SwiftUI


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let items = (try? getData()) ?? []
        
        return SimpleEntry(items: items, date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        do {
            let items  = try getData()
            let entry = SimpleEntry(items: items, date: Date())
            completion(entry)
        } catch {
            print(error)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let items  = try getData()
            let entry = SimpleEntry(items: items, date: Date())
            //            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: entry.date)!
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        } catch{
            print(error)
        }
        
    }
    
    private func getData() throws -> [Exercise] {
        let context = PersistenceController.shared.container.viewContext
        
        let request = Exercise.fetchRequest()
        let result = try context.fetch(request)
        
        return result
    }
    
}

struct SimpleEntry: TimelineEntry {
    let items: [Exercise]
    let date: Date
}

struct Week_Planner_WidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        ZStack() {
            CustomColor.background
                .ignoresSafeArea()
            
            HStack() {
                TitleLogo()
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .padding(.leading, 10)
                    .padding(.trailing, 5)
                
                Divider()
                    .overlay(LinearGradient(gradient: Gradient(stops: [
                        .init(color: CustomColor.background, location: 0),
                        .init(color: CustomColor.highlight, location: 0.25),
                        .init(color: CustomColor.highlight, location: 0.75),
                        .init(color: CustomColor.background, location: 1),
                    ]), startPoint: .top, endPoint: .bottom))
                WeekPlanner()
            }
        }
        
    }
    @ViewBuilder
    func WeekPlanner() -> some View {
        VStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                HStack(spacing: 0) {
                    //                          Text(day.name.prefix(3))
                    Text(day.name)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor((Date().dayOfWeek()!) == day.name ? CustomColor.highlight : CustomColor.day)
                        .frame(maxWidth: 90, alignment: .leading)
                    if ((entry.items.firstIndex(where: { $0.day == day.name })) != nil) {
                        let i = entry.items.firstIndex(where: { $0.day == day.name })!
                        
                        Text(entry.items[i].name ?? "-")
                            .font(.system(size: 14))
                            .foregroundColor((Date().dayOfWeek()!) == day.name ? CustomColor.highlight : CustomColor.task)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else {
                        Text("-")
                            .font(.system(size: 14))
                            .foregroundColor((Date().dayOfWeek()!) == day.name ? CustomColor.highlight : CustomColor.task)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(2)
            }
        }
    }
    
    @ViewBuilder
    func TitleLogo() -> some View {
        VStack(alignment: .center ) {
            Text("Tasks")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CustomColor.day)
                .padding(.bottom, 15)
            Image(systemName: "calendar.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(CustomColor.highlight)
                .padding(5)
                .background(CustomColor.lightBackground)
                .clipShape(Circle())
        }
    }
}

struct Week_Planner_Widget: Widget {
    let kind: String = "Week_Planner_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Week_Planner_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Week Planner Widget")
        .description("Shows the days of the week together with an assigned task for each day.")
        .supportedFamilies([.systemMedium])
    }
}

struct Week_Planner_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Week_Planner_WidgetEntryView(entry: SimpleEntry(items: [], date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
