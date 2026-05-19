import WidgetKit
import SwiftUI
import Intents

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
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        
        let todayDateString = "\(dateFormatter.string(from: today)) \(weekdayFormatter.string(from: today))"
        let tomorrowDateString = "\(dateFormatter.string(from: tomorrow)) \(weekdayFormatter.string(from: tomorrow))"
        
        return CourseEntry(
            date: today,
            title: "近日课表",
            todayDateString: todayDateString,
            tomorrowDateString: tomorrowDateString,
            todayCourses: [
                Course(title: "高等数学", time: "第1-2节 08:00-09:30", location: "教学楼A101", teacher: "教学楼A101"),
                Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼B205", teacher: "教学楼B205")
            ],
            tomorrowCourses: [
                Course(title: "计算机科学", time: "第1-2节 08:00-09:30", location: "实验楼C301", teacher: "实验楼C301"),
                Course(title: "物理学", time: "第3-4节 10:00-11:30", location: "教学楼D405", teacher: "教学楼D405")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        let title = "近日课表"
        let sharedDefaults = WidgetStorage.sharedDefaults()
        let todayStr = sharedDefaults?.string(forKey: "flutter.tomorrow.date") ?? getCurrentDateString()
        let tomorrowStr = sharedDefaults?.string(forKey: "flutter.tomorrow.tomorrowDate") ?? getTomorrowDateString()
        let todayCourses = WidgetStorage.decodeCourses(forKey: "flutter.tomorrow.courses")
        let tomorrowCourses = WidgetStorage.decodeCourses(forKey: "flutter.tomorrow.tomorrowCourses")

        let entry = CourseEntry(date: Date(), title: title, todayDateString: todayStr, tomorrowDateString: tomorrowStr, todayCourses: todayCourses, tomorrowCourses: tomorrowCourses)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        return formatter.string(from: Date())
    }
    
    private func getTomorrowDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatter.string(from: tomorrow)
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
    let todayDateString: String
    let tomorrowDateString: String
    let todayCourses: [Course]
    let tomorrowCourses: [Course]

    init(date: Date, title: String, todayDateString: String = "", tomorrowDateString: String = "", todayCourses: [Course] = [], tomorrowCourses: [Course] = []) {
        self.date = date
        self.title = title
        self.todayDateString = todayDateString
        self.tomorrowDateString = tomorrowDateString
        self.todayCourses = todayCourses
        self.tomorrowCourses = tomorrowCourses
    }
}

func extractDateInfo(from dateString: String) -> (day: String, weekday: String) {
    let components = dateString.split(separator: " ")
    var day = "27"
    var weekday = "星期一"

    if components.count >= 1 {
        let dateComponent = String(components[0])
        if let range = dateComponent.range(of: "\\d+", options: .regularExpression) {
            day = String(dateComponent[range])
        }
    }

    if components.count >= 2 {
        weekday = String(components[1])
    }

    return (day, weekday)
}

struct TomorrowCoursesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    let accentColor = Color(.systemBlue)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.title)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }

            HStack(spacing: 10) {
                DayColumnView(
                    title: "今天",
                    dateText: entry.todayDateString,
                    courses: entry.todayCourses,
                    accentColor: accentColor,
                    maxVisibleCourses: family == .systemLarge ? 3 : 2
                )

                DayColumnView(
                    title: "明天",
                    dateText: entry.tomorrowDateString,
                    courses: entry.tomorrowCourses,
                    accentColor: accentColor,
                    maxVisibleCourses: family == .systemLarge ? 3 : 2
                )
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        // 添加点击交互，点击后打开应用
        .widgetURL(URL(string: "iosclubapp://courses"))
    }
}

struct DayColumnView: View {
    let title: String
    let dateText: String
    let courses: [Course]
    let accentColor: Color
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
                    .foregroundColor(accentColor)

                Text(dateText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if !courses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(visibleCourses) { course in
                        CourseRowView(course: course, accentColor: accentColor)
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

struct CourseRowView: View {
    let course: Course
    let accentColor: Color

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
                    .fontWeight(.semibold)
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
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("享受自由时光")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct TomorrowCoursesWidget: Widget {
    let kind: String = "TomorrowCoursesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TomorrowCoursesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("近日课表")
        .description("查看今天和明天的课程安排")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
