//
//  Announcer_Timetable.swift
//  Announcer_Timetable
//
//  Created by Ayaan Jain on 3/3/23.
//

import WidgetKit
import SwiftUI
import Intents
import Chopper

struct Provider: IntentTimelineProvider { //Dummy data placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

//Allow user to see what the widget would look like before they inst
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct Announcer_TimetableEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.gray.gradient)
        }
    }
}

struct Announcer_Timetable: Widget {
    let kind: String = "Announcer_Timetable"

    var body: some WidgetConfiguration {
        HStack{
            
        }
    }
}

struct Announcer_Timetable_Previews: PreviewProvider {
    static var previews: some View {
        Announcer_TimetableEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
