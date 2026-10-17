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

/// App 写入 App Group 的整学期课表快照 key（对应 Dart 侧 `WidgetService.iOSScheduleSnapshotKey`）。
private let scheduleSnapshotKey = "flutter.schedule"

/// 一次 timeline 最多生成的 entry 数，避免异常数据把时间线撑爆。
private let maxTimelineEntries = 48

// MARK: - 快照模型（由 Dart 侧 WidgetScheduleSnapshot 序列化）

/// 一节课程。
private struct CourseSnapshot: Decodable {
    let name: String
    let room: String
    let teachers: [String]
    /// 1 = 周一 … 7 = 周日，与 Dart `DateTime.weekday` 一致。
    let weekday: Int
    let startUnit: Int
    let endUnit: Int
    /// 上课周次，例如 [1, 2, 3, 5] 表示第 1、2、3、5 周。
    let weeks: [Int]
    /// 用于挑选作息表的校区名。
    let campus: String
}

/// 某个校区在某个季节（如 `10/01~04/30`）的节次起止时间。
private struct TableSnapshot: Decodable {
    let campus: String
    let range: String
    let start: [String]
    let end: [String]
}

/// 整学期课表快照。
private struct ScheduleSnapshot: Decodable {
    let semesterStart: String?
    let semesterEnd: String?
    /// 一周从哪天开始：1 = 周一，7 = 周日。
    let weekStartDay: Int
    /// 节次查不到校区时退回的校区（与 Dart 侧一致，为草堂）。
    let defaultCampus: String?
    let tables: [TableSnapshot]
    let courses: [CourseSnapshot]
}

private enum WidgetStorage {
    static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: widgetGroupId)
    }

    static func loadSnapshot() -> ScheduleSnapshot? {
        guard
            let raw = sharedDefaults()?.string(forKey: scheduleSnapshotKey),
            let data = raw.data(using: .utf8)
        else {
            return nil
        }

        return try? JSONDecoder().decode(ScheduleSnapshot.self, from: data)
    }
}

// MARK: - 课表换算

/// 把整学期快照换算成任意一天的课表。
///
/// 这里是 Dart 侧 `WeekStartUtils` 与 `TimeService` 的等价实现。放在小组件里算，
/// 是为了让显示内容能随时间自己变化，而不用等 App 或后台任务来刷新数据。
private struct ScheduleCalculator {
    let snapshot: ScheduleSnapshot
    private let calendar = Calendar.current
    private let defaultCampus: String

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(snapshot: ScheduleSnapshot) {
        self.snapshot = snapshot
        self.defaultCampus = snapshot.defaultCampus ?? ""
    }

    var semesterStartDate: Date? {
        guard let raw = snapshot.semesterStart else { return nil }
        return ScheduleCalculator.dateFormatter.date(from: raw)
    }

    /// 与 Dart `DateTime.weekday` 一致：1 = 周一 … 7 = 周日。
    func weekday(of date: Date) -> Int {
        let raw = calendar.component(.weekday, from: date) // 1 = 周日 … 7 = 周六
        return ((raw + 5) % 7) + 1
    }

    /// 与 Dart `WeekStartUtils.getWeekStart` 等价。
    func weekStart(of date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let normalized = snapshot.weekStartDay == 1 ? 1 : 7
        let daysSince = ((weekday(of: date) - normalized) % 7 + 7) % 7
        return calendar.date(byAdding: .day, value: -daysSince, to: startOfDay) ?? startOfDay
    }

    /// 与 Dart `WeekStartUtils.getWeekIndexByStartTime` 等价；没有学期起点时返回 nil。
    func weekIndex(on date: Date) -> Int? {
        guard let start = semesterStartDate else { return nil }
        let days = calendar.dateComponents(
            [.day],
            from: weekStart(of: start),
            to: weekStart(of: date)
        ).day ?? 0
        return days / 7 + 1
    }

    /// 某天的课程：先按周次和星期筛选，再合并同名同节次的课程并排序。
    func courses(on date: Date) -> [Course] {
        guard let week = weekIndex(on: date) else { return [] }

        let target = weekday(of: date)
        let matched = snapshot.courses.filter { course in
            course.weekday == target && course.weeks.contains(week)
        }

        return merge(matched, on: date)
    }

    func entry(at date: Date) -> CombinedCourseEntry {
        let today = calendar.startOfDay(for: date)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let todayCourses = courses(on: today).filter { !hasEnded($0, on: today, at: date) }

        return CombinedCourseEntry(
            date: date,
            todayTitle: "今日课表",
            todayDateString: weekLabel(on: today),
            todayCourses: todayCourses,
            recentTitle: "近日课表",
            recentTodayDateString: dayLabel(on: today),
            recentTomorrowDateString: dayLabel(on: tomorrow),
            recentTodayCourses: todayCourses,
            recentTomorrowCourses: courses(on: tomorrow)
        )
    }

    /// 生成从 [now] 起的时间线：每节课下课、以及每天零点会切换显示内容。
    ///
    /// 这些 entry 由 WidgetKit 按时切换，不需要 App 在前台，也不需要后台任务被调度。
    func entries(from now: Date) -> [CombinedCourseEntry] {
        timelineDates(from: now).map { entry(at: $0) }
    }

    // MARK: - 时间线

    private func timelineDates(from now: Date) -> [Date] {
        let today = calendar.startOfDay(for: now)
        guard
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today),
            let dayAfterTomorrow = calendar.date(byAdding: .day, value: 1, to: tomorrow)
        else {
            return [now]
        }

        var dates: Set<Date> = [now]
        for course in courses(on: today) {
            if let end = endMoment(of: course, on: today), end > now {
                dates.insert(end)
            }
        }

        // 零点换日：今天/明天的课表整体前移
        dates.insert(tomorrow)
        for course in courses(on: tomorrow) {
            if let end = endMoment(of: course, on: tomorrow) {
                dates.insert(end)
            }
        }
        dates.insert(dayAfterTomorrow)

        return dates.sorted().prefix(maxTimelineEntries).map { $0 }
    }

    private func hasEnded(_ course: Course, on day: Date, at moment: Date) -> Bool {
        guard let end = endMoment(of: course, on: day) else { return false }
        return moment >= end
    }

    private func endMoment(of course: Course, on day: Date) -> Date? {
        let parts = course.endTime.split(separator: ":")
        guard
            parts.count >= 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1])
        else {
            return nil
        }

        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }

    // MARK: - 展示文案

    private func weekLabel(on date: Date) -> String {
        guard let week = weekIndex(on: date), week > 0 else { return "" }
        return "第\(week)周 周\(weekdayName(for: date))"
    }

    private func dayLabel(on date: Date) -> String {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return String(format: "%02d月%02d日 周", month, day) + weekdayName(for: date)
    }

    private func weekdayName(for date: Date) -> String {
        let names = ["一", "二", "三", "四", "五", "六", "日"]
        let index = weekday(of: date) - 1
        guard index >= 0 && index < names.count else { return "" }
        return names[index]
    }

    // MARK: - 课程合并与节次时间

    /// 与 Dart `CourseModel.mergeSameNameCourses` 等价：同名且同节次的课程合并授课教师。
    private func merge(_ courses: [CourseSnapshot], on date: Date) -> [Course] {
        var result: [Course] = []
        var used = [Bool](repeating: false, count: courses.count)

        for index in courses.indices where !used[index] {
            let current = courses[index]
            var teachers = current.teachers
            used[index] = true

            for other in courses.indices where other > index && !used[other] {
                let candidate = courses[other]
                guard
                    candidate.name == current.name,
                    candidate.startUnit == current.startUnit,
                    candidate.endUnit == current.endUnit
                else {
                    continue
                }

                for teacher in candidate.teachers where !teachers.contains(teacher) {
                    teachers.append(teacher)
                }
                used[other] = true
            }

            result.append(makeCourse(current, teachers: teachers, on: date))
        }

        return result.sorted { $0.startUnit < $1.startUnit }
    }

    private func makeCourse(
        _ snapshot: CourseSnapshot,
        teachers: [String],
        on date: Date
    ) -> Course {
        let period = periodTimes(
            campus: snapshot.campus,
            startUnit: snapshot.startUnit,
            endUnit: snapshot.endUnit,
            on: date
        )

        let timeText = period.start.isEmpty && period.end.isEmpty
            ? ""
            : "第\(snapshot.startUnit)-\(snapshot.endUnit)节 \(period.start)-\(period.end)"

        return Course(
            title: snapshot.name,
            time: timeText,
            location: snapshot.room,
            teacher: teachers.joined(separator: ", "),
            startUnit: snapshot.startUnit,
            endUnit: snapshot.endUnit,
            startTime: period.start,
            endTime: period.end
        )
    }

    /// 与 Dart `TimeService.getStartAndEndForCampus` 等价：查不到时退回默认校区（草堂）。
    private func periodTimes(
        campus: String,
        startUnit: Int,
        endUnit: Int,
        on date: Date
    ) -> (start: String, end: String) {
        let table = resolveTable(campus: campus, on: date)
        let fallback = campus == defaultCampus ? nil : resolveTable(campus: defaultCampus, on: date)

        return (
            start: lookup(table?.start, startUnit) ?? lookup(fallback?.start, startUnit) ?? "",
            end: lookup(table?.end, endUnit) ?? lookup(fallback?.end, endUnit) ?? ""
        )
    }

    private func resolveTable(campus: String, on date: Date) -> TableSnapshot? {
        let candidates = snapshot.tables.filter { $0.campus == campus }
        guard !candidates.isEmpty else { return nil }

        return candidates.first { covers($0.range, date: date) } ?? candidates.first
    }

    /// 与 Dart `ScheduleTable.coversDate` 等价：空区间或非法区间都视为全年适用。
    private func covers(_ range: String, date: Date) -> Bool {
        guard let bounds = ScheduleCalculator.parseRange(range) else { return true }

        let today = calendar.component(.month, from: date) * 100 + calendar.component(.day, from: date)
        let from = bounds[0] * 100 + bounds[1]
        let to = bounds[2] * 100 + bounds[3]

        // from > to 说明区间跨年，例如 10/01~04/30
        return from <= to
            ? today >= from && today <= to
            : today >= from || today <= to
    }

    private static func parseRange(_ text: String) -> [Int]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^(\d{1,2})/(\d{1,2})\s*~\s*(\d{1,2})/(\d{1,2})$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let full = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard
            let match = regex.firstMatch(in: trimmed, range: full),
            match.numberOfRanges == 5
        else {
            return nil
        }

        var values: [Int] = []
        for index in 1...4 {
            guard
                let range = Range(match.range(at: index), in: trimmed),
                let value = Int(trimmed[range])
            else {
                return nil
            }
            values.append(value)
        }

        return values
    }

    /// 与 Dart `TimeService._lookup` 等价：越界返回 nil，表里的空串原样返回。
    private func lookup(_ times: [String]?, _ index: Int) -> String? {
        guard let times, index >= 0, index < times.count else { return nil }
        return times[index]
    }
}

// MARK: - Timeline

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CourseEntry {
        Self.sampleEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CourseEntry) -> Void) {
        guard let snapshot = WidgetStorage.loadSnapshot() else {
            completion(Self.sampleEntry(at: Date()))
            return
        }

        completion(ScheduleCalculator(snapshot: snapshot).entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date()

        // App 还没写过快照：先给个空壳，一小时后再试
        guard let snapshot = WidgetStorage.loadSnapshot() else {
            let policy = TimelineReloadPolicy.after(now.addingTimeInterval(3600))
            completion(Timeline(entries: [Self.emptyEntry(at: now)], policy: policy))
            return
        }

        let calculator = ScheduleCalculator(snapshot: snapshot)
        let entries = calculator.entries(from: now)

        // 推不出周次（缺学期起点）时课表必然为空，过一小时再试，等 App 补上数据
        let policy: TimelineReloadPolicy = calculator.semesterStartDate == nil
            ? .after(now.addingTimeInterval(3600))
            : .atEnd

        completion(
            Timeline(entries: entries.isEmpty ? [Self.emptyEntry(at: now)] : entries, policy: policy)
        )
    }

    private static func emptyEntry(at date: Date) -> CombinedCourseEntry {
        CombinedCourseEntry(date: date, todayTitle: "今日课表", recentTitle: "近日课表")
    }

    private static func sampleEntry(at date: Date) -> CombinedCourseEntry {
        CombinedCourseEntry(
            date: date,
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
}

// MARK: - 视图模型

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let location: String
    let teacher: String

    /// 以下字段供时间线推算使用（判断是否已下课）。
    var startUnit: Int = 0
    var endUnit: Int = 0
    var startTime: String = ""
    var endTime: String = ""
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
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if !entry.todayDateString.isEmpty {
                        Text(entry.todayDateString)
                            .font(.system(size: 10, weight: .semibold))
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
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(8)
        // Widget 根视图若尺寸小于可用空间，WidgetKit 默认会把整块内容居中；
        // 这里撑满并顶对齐，课程变少时才不会被推到中间。
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TodayCourseRowView: View {
    let course: Course
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(ultraCompactPeriodText(from: course.time))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(ultraCompactStartTime(from: course.time))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
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
        family == .systemLarge ? 4 : 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if family == .systemLarge {
                Text(entry.recentTitle)
                    .font(.system(size: 20, weight: .bold))
            }

            HStack(spacing: 8) {
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
                    .font(.system(size: 13, weight: .bold))
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
//                        Course(title: "大学英语", time: "第3-4节 10:00-11:30", location: "教学楼#123", teacher: "Lumaris"),
//                        Course(title: "计算机科学", time: "第5-6节 14:00-15:30", location: "实验楼#101", teacher: "Lumaris")
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
                        Course(title: "数据结构", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "计算力学", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris")
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))

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
                        Course(title: "数据结构", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "计算力学", time: "第3-4节 10:10-12:00", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris"),
                        Course(title: "大学体育", time: "第7-8节 14:30-16:20", location: "实验楼#101", teacher: "Lumaris")
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
