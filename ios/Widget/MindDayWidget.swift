//
//  MindDayWidget.swift
//  Widget
//
//  Created by Aleksandr Martseniuk on 04.11.2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MindEntry {
        MindEntry(emoji: "No data", text: "No data", date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (MindEntry) -> ()) {
        let entry: MindEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            let userDefaults = UserDefaults(suiteName: "group.kekable")
            let emoji = userDefaults?.string(forKey: "mind_emoji") ?? "No emoji"
            let text = userDefaults?.string(forKey: "mind_text") ?? "No text"
            entry = MindEntry(
                emoji: emoji, 
                text: text, 
                date: Date()
            )
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { mindEntry in
            let timeline = Timeline(entries: [mindEntry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct MindEntry: TimelineEntry {
    let emoji: String
    let text: String
    let date: Date
}

struct MindDayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.emoji).font(.largeTitle)
            Text(entry.text)
        }
    }
}

struct MindDayWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MindDayWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MindDayWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
