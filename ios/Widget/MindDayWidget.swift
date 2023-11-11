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
        MindEntry(
            text: "😃 🌟 🐾 🍕 🎈 🌸 🚀 🌊 🌮 🎉", 
            date: Date()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MindEntry) -> ()) {
        let entry: MindEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            let userDefaults = UserDefaults(suiteName: "group.kekable")
            let mindsJSONs = userDefaults?.stringArray(forKey: "mind_today_widget_today_minds") ?? []
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let minds = mindsJSONs.compactMap { mindString -> Mind? in
                guard let mindData = mindString.data(using: .utf8) else {
                    return nil
                }
                return try? decoder.decode(Mind.self, from: mindData) 
            }
            
            entry = MindEntry( 
                text: minds.map { $0.emoji.description }.joined(separator: " "), 
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
    let text: String
    let date: Date
}

struct MindDayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.text.isEmpty {
            Text("No data for today...")
        } else {
            Text(entry.text)
                .font(.system(size: 48))
                .multilineTextAlignment(.center)
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
        .configurationDisplayName("Today minds")
        .description("This is an example widget.")
    }
}
