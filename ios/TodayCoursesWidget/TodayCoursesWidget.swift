//
//  TodayCoursesWidget.swift
//  TodayCoursesWidget
//
//  Created by Lumaris.
//

import SwiftUI
import WidgetKit
import Foundation

private let widgetGroupId = "group.com.example.iosClubApp.widget"

private enum WidgetStorage {
    static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: widgetGroupId)
    }

    static func decodeCourses(forKey key: String) -> [Course] {
        guard
            let courseString = sharedDefaults()?.string(forKey: key),
            let courseData = courseString.data(using: .utf8),
            let rawCourses = try? JSONSerialization.jsonObject(with: courseData) as? [[String: Any]]
        else {
            return []
        }

        return rawCourses.compactMap(Course.fromJson)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CourseEntry {
        CourseEntry(
            date: Date(),
            title: "今日课表",
            courses: [
                Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "张老师"),
                Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "李老师")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        let title = "今日课表"
        let dateStr = WidgetStorage.sharedDefaults()?.string(forKey: "flutter.date") ?? ""
        let courses = WidgetStorage.decodeCourses(forKey: "flutter.courses")

        let entry = CourseEntry(date: Date(), title: title, dateString: dateStr, courses: courses)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let location: String
    let teacher: String
    
    static func fromJson(_ json: [String: Any]) -> Course? {
        guard let title = json["title"] as? String,
              let time = json["time"] as? String,
              let location = json["location"] as? String,
              let teacher = json["teacher"] as? String else {
            return nil
        }
        
        return Course(title: title, time: time, location: location, teacher: teacher)
    }
}

struct CourseEntry: TimelineEntry {
    let date: Date
    let title: String
    let dateString: String
    let courses: [Course]
    
    init(date: Date, title: String, dateString: String = "", courses: [Course] = []) {
        self.date = date
        self.title = title
        self.dateString = dateString
        self.courses = courses
    }
}

struct TodayCoursesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    private var maxVisibleCourses: Int {
        2
    }

    private var visibleCourses: [Course] {
        Array(entry.courses.prefix(maxVisibleCourses))
    }

    private var hiddenCoursesCount: Int {
        max(entry.courses.count - visibleCourses.count, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if !entry.dateString.isEmpty {
                        Text(entry.dateString)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                Spacer()
            }
            
            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(height: 1)
            
            if entry.courses.isEmpty {
                VStack(alignment: .center, spacing: 6) {
                    Text("今天没有课程")
                        .font(.system(size: 16, weight: .semibold))
                        .fontWeight(.semibold)
                    
                    Text("享受你的自由时光吧！")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(visibleCourses) { course in
                        CourseRowView(course: course)
                    }

                    if hiddenCoursesCount > 0 {
                        Text("还有\(hiddenCoursesCount)节课程")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(10)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(ultraCompactPeriodText(from: course.time))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(ultraCompactStartTime(from: course.time))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(course.location)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.vertical, 1)
    }

    private func ultraCompactPeriodText(from source: String) -> String {
        if let range = source.range(of: #"第\d+-\d+节"#, options: .regularExpression) {
            return String(source[range]).replacingOccurrences(of: "第", with: "")
        }
        return source
    }

    private func ultraCompactStartTime(from source: String) -> String {
        if let range = source.range(of: #"\d{2}:\d{2}"#, options: .regularExpression) {
            return String(source[range])
        }
        return source
    }
}

struct TodayCoursesWidget: Widget {
    let kind: String = "TodayCoursesWidgetSmall"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayCoursesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日课表")
        .description("查看今天的课程安排")
        .supportedFamilies([.systemSmall])
    }
}

struct TodayCoursesWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayCoursesWidgetEntryView(
            entry: CourseEntry(
                date: Date(),
                title: "今日课表",
                dateString: "第12周 周三",
                courses: [
                    Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "教学楼A101"),
                    Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "教学楼B205"),
                    Course(title: "计算机科学", time: "第5-6节 14:00-15:30", location: "实验楼C301", teacher: "实验楼C301")
                ]
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
