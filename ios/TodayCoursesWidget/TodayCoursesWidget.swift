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
        CombinedCourseEntry(
            date: Date(),
            todayTitle: "今日课表",
            todayDateString: "第12周 周三",
            todayCourses: [
                Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "张老师"),
                Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "李老师")
            ],
            recentTitle: "近日课表",
            recentTodayDateString: "05月20日 周三",
            recentTomorrowDateString: "05月21日 周四",
            recentTodayCourses: [
                Course(title: "城乡规划分析方法", time: "第3-4节 10:10-12:00", location: "南阶108", teacher: "南阶108"),
                Course(title: "大学体育4", time: "第7-8节 14:30-16:20", location: "雁塔田径场", teacher: "雁塔田径场")
            ],
            recentTomorrowCourses: [
                Course(title: "建筑结构 I", time: "第1-2节 08:00-09:50", location: "西阶301", teacher: "西阶301"),
                Course(title: "习近平新时代中...", time: "第3-4节 10:10-12:00", location: "东阶201", teacher: "东阶201")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        let sharedDefaults = WidgetStorage.sharedDefaults()
        let entry = CombinedCourseEntry(
            date: Date(),
            todayTitle: "今日课表",
            todayDateString: sharedDefaults?.string(forKey: "flutter.date") ?? "",
            todayCourses: WidgetStorage.decodeCourses(forKey: "flutter.courses"),
            recentTitle: "近日课表",
            recentTodayDateString: sharedDefaults?.string(forKey: "flutter.tomorrow.date") ?? "",
            recentTomorrowDateString: sharedDefaults?.string(forKey: "flutter.tomorrow.tomorrowDate") ?? "",
            recentTodayCourses: WidgetStorage.decodeCourses(forKey: "flutter.tomorrow.courses"),
            recentTomorrowCourses: WidgetStorage.decodeCourses(forKey: "flutter.tomorrow.tomorrowCourses")
        )
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

typealias CourseEntry = CombinedCourseEntry

struct CombinedCourseEntry: TimelineEntry {
    let date: Date
    let todayTitle: String
    let todayDateString: String
    let todayCourses: [Course]
    let recentTitle: String
    let recentTodayDateString: String
    let recentTomorrowDateString: String
    let recentTodayCourses: [Course]
    let recentTomorrowCourses: [Course]

    init(
        date: Date,
        todayTitle: String = "",
        todayDateString: String = "",
        todayCourses: [Course] = [],
        recentTitle: String = "",
        recentTodayDateString: String = "",
        recentTomorrowDateString: String = "",
        recentTodayCourses: [Course] = [],
        recentTomorrowCourses: [Course] = []
    ) {
        self.date = date
        self.todayTitle = todayTitle
        self.todayDateString = todayDateString
        self.todayCourses = todayCourses
        self.recentTitle = recentTitle
        self.recentTodayDateString = recentTodayDateString
        self.recentTomorrowDateString = recentTomorrowDateString
        self.recentTodayCourses = recentTodayCourses
        self.recentTomorrowCourses = recentTomorrowCourses
    }
}

struct ScheduleWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                TodayCoursesCompactView(entry: entry)
            default:
                RecentCoursesView(entry: entry, family: family)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(URL(string: "iosclubapp://courses"))
    }
}

struct TodayCoursesCompactView: View {
    let entry: CombinedCourseEntry

    private var maxVisibleCourses: Int {
        2
    }

    private var visibleCourses: [Course] {
        Array(entry.todayCourses.prefix(maxVisibleCourses))
    }

    private var hiddenCoursesCount: Int {
        max(entry.todayCourses.count - visibleCourses.count, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.todayTitle)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if !entry.todayDateString.isEmpty {
                        Text(entry.todayDateString)
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
            
            if entry.todayCourses.isEmpty {
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
                        TodayCourseRowView(course: course)
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
    }
}

struct TodayCourseRowView: View {
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

struct RecentCoursesView: View {
    let entry: CombinedCourseEntry
    let family: WidgetFamily

    private var maxVisibleCourses: Int {
        family == .systemLarge ? 3 : 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.recentTitle)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }

            HStack(spacing: 10) {
                RecentDayColumnView(
                    title: "今天",
                    dateText: entry.recentTodayDateString,
                    courses: entry.recentTodayCourses,
                    maxVisibleCourses: maxVisibleCourses
                )

                RecentDayColumnView(
                    title: "明天",
                    dateText: entry.recentTomorrowDateString,
                    courses: entry.recentTomorrowCourses,
                    maxVisibleCourses: maxVisibleCourses
                )
            }
        }
        .padding(12)
    }
}

struct RecentDayColumnView: View {
    let title: String
    let dateText: String
    let courses: [Course]
    let maxVisibleCourses: Int

    private var visibleCourses: [Course] {
        Array(courses.prefix(maxVisibleCourses))
    }

    private var hiddenCoursesCount: Int {
        max(courses.count - visibleCourses.count, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(.systemBlue))

                Text(dateText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if !courses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(visibleCourses) { course in
                        RecentCourseRowView(course: course)
                    }

                    if hiddenCoursesCount > 0 {
                        Text("还有\(hiddenCoursesCount)节")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                EmptyCoursesView(text: "\(title)无课程")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct RecentCourseRowView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(compactTimeRange(from: course.time))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .monospacedDigit()
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Text(course.location)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.bottom, 2)
    }

    private func compactTimeRange(from source: String) -> String {
        if let range = source.range(of: #"\d{2}:\d{2}-\d{2}:\d{2}"#, options: .regularExpression) {
            return String(source[range])
        }
        return source
    }
}

struct EmptyCoursesView: View {
    let text: String

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 18))
                .foregroundColor(.secondary)

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .multilineTextAlignment(.center)

            Text("享受自由时光")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("课表")
        .description("小尺寸显示今日课表，中大尺寸显示近日课表")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleWidgetEntryView(
                entry: CombinedCourseEntry(
                    date: Date(),
                    todayTitle: "今日课表",
                    todayDateString: "第12周 周三",
                    todayCourses: [
                        Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼#123", teacher: "Lumaris"),
                        Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼#123", teacher: "Lumaris"),
                        Course(title: "计算机科学", time: "第5-6节 14:00-15:30", location: "实验楼#101", teacher: "Lumaris")
                    ],
                    recentTitle: "近日课表",
                    recentTodayDateString: "05月20日 周三",
                    recentTomorrowDateString: "05月21日 周四",
                    recentTodayCourses: [
                        Course(title: "计算力学", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris")
                    ],
                    recentTomorrowCourses: [
                        Course(title: "Lumaris开发", time: "第1-2节 08:00-09:50", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "数据结构", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris")
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            ScheduleWidgetEntryView(
                entry: CombinedCourseEntry(
                    date: Date(),
                    todayTitle: "今日课表",
                    todayDateString: "第12周 周三",
                    todayCourses: [
                        Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼#123", teacher: "Lumaris"),
                        Course(title: "计算机科学", time: "第5-6节 14:00-15:30", location: "实验楼#101", teacher: "Lumaris")
                    ],
                    recentTitle: "近日课表",
                    recentTodayDateString: "05月20日 周三",
                    recentTomorrowDateString: "05月21日 周四",
                    recentTodayCourses: [
                        Course(title: "计算力学", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris")
                    ],
                    recentTomorrowCourses: [
                        Course(title: "Lumaris开发", time: "第1-2节 08:00-09:50", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "数据结构", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris")
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
