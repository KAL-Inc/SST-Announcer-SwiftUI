//
//  ScheduleProvider.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

public protocol ScheduleProvider: Identifiable, Equatable {
    associatedtype Block: TimeBlock

    var subjects: [Block] { get set }
    var subjectClasses: [SubjectClass] { get set }
    var timeRange: Range<Int> { get }
    var startDate: Date { get set }
    var repetitions: Int { get set }

    mutating func deleteClass(subClass: SubjectClass)
}

// MARK: Progress
public extension ScheduleProvider {
    /// The progress of the loading, as a ``LoadProgress``
    var loadProgress: LoadProgress {
        if loadedSubjects == 0 { return .unloaded }
        if loadedSubjects == subjects.count { return .loaded }
        return .loading
    }

    /// The number of loaded subjects
    var loadedSubjects: Int {
        subjects.filter({ $0.displayName != nil }).count
    }

    /// The decimal representing the proportion of loaded subjects
    var loadAmount: Double {
        Double(loadedSubjects) / Double(subjects.count)
    }

    /// If the subject is unreadable, or does not have a class
    var invalidSuggestions: Int {
        subjects.invalidSuggestions
    }

    /// Returns the subjects matching a day and a week. If the week is even, it uses the even timetable.
    /// If it is odd, it uses the odd timetable.
    func subjectsMatching(day: DayOfWeek, week: Int) -> [Block] {
        return subjects.filter { subject in
            subject.day.day == day && subject.day.week.matches(weekNo: week)
        }
    }
}

// MARK: Class actions
public extension ScheduleProvider {
    /// Update the values of the `subjectClass` of the ``subjects``, where the ids match.
    mutating func updateClass(subClass: SubjectClass) {
        guard let firstIndex = subjectClasses.firstIndex(where: { $0.id == subClass.id }) else { return }

        subjectClasses[firstIndex] = subClass
        for index in (0..<subjects.count).filter({ subjects[$0].displaySubjectClass?.id == subClass.id }) {
            subjects[index].displaySubjectClass = subClass
        }
    }

    /// Removes unused classes
    mutating func trimUnusedClasses() {
        let subjects = subjects
        self.subjectClasses.removeAll { elem in
            !subjects.contains(where: { $0.displaySubjectClass == elem })
        }
    }

    /// Sorts subjects by day, then time
    mutating func sortClasses() {
        self.subjects.sort { first, second in
            // check if the week is different
            if first.day.week != second.day.week {
                let firstIndex = Week.allCases.firstIndex(of: first.day.week)!
                let secondIndex = Week.allCases.firstIndex(of: second.day.week)!
                return firstIndex < secondIndex
            }
            // week is the same, check if day is different
            if first.day.day != second.day.day {
                let firstIndex = DayOfWeek.allCases.firstIndex(of: first.day.day)!
                let secondIndex = DayOfWeek.allCases.firstIndex(of: second.day.day)!
                return firstIndex < secondIndex
            }
            // day and week are the same, sort by time (we go by start of subject)
            return first.timeBlocks.lowerBound < second.timeBlocks.lowerBound
        }
    }

    /// Gets the color for a given subject name
    func colorFor(name: String) -> Color {
        let defaultColors: [[String]: Color] = [
            // core subjects
            ["cl", "hcl", "tl", "htl", "ml"]: .purple,
            ["math"]: .orange,
            ["english", "el"]: .cyan,

            // science
            [
                "science", "sci",
                "phy", "physics",
                "bio", "biology",
                "chem", "chemistry"
            ]: .red,

            // humanities
            ["ss", "social studies"]: .green,
            [
                "geography", "ch(ge)", "ge", "geog",
                "history", "hist"
            ]: .brown,

            // non-graded
            ["s&w"]: .pink,
            ["break"]: .init(white: 0.9),

            // AS
            ["comp", "computing"]: .mint,
            ["electronics", "elec"]: .gray,
            ["biotech", "biot", "bt"]: .indigo,
            ["ds", "design studies"]: .init(white: 0.5)
        ]

        let lowerName = name.lowercased()

        for (names, color) in defaultColors where names.contains(where: { possibleName in
            if possibleName.count <= 2 { // so that "Elec" isn't matched to "EL"
                return lowerName == possibleName
            } else {
                return lowerName.contains(possibleName)
            }
        }) {
            return color
        }

        return .accentColor
    }
}
