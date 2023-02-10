//
//  Models.swift
//  Standups
//
//  Created by Geonhee on 2023/02/10.
//

import SwiftUI

struct Standup: Equatable, Identifiable, Codable {
  let id: UUID
  var attendees: [Attendee] = []
  var duration = Duration.seconds(60 * 5)
  var meetings: [Meeting] = []
  var theme: Theme = .bubblegum
  var title = ""

  var durationPerAttendee: Duration {
    return self.duration / self.attendees.count
  }
}

struct Attendee: Equatable, Identifiable, Codable {
  let id: UUID
  let name: String
}

struct Meeting: Equatable, Identifiable, Codable {
  let id: UUID
  let date: Date
}

enum Theme:
  String,
  CaseIterable,
  Equatable,
  Hashable,
  Identifiable,
  Codable
{
  case bubblegum
  case buttercup
  case indigo
  case lavender
  case magenta
  case navy
  case orange
  case oxblood
  case periwinkle
  case poppy
  case purple
  case seafoam
  case sky
  case tan
  case teal
  case yellow

  var id: Self { self }

  var accentColor: Color {
    switch self {
      case
        .bubblegum,
      .buttercup,
      .lavender,
      .orange,
      .periwinkle,
      .poppy,
      .seafoam,
      .sky,
      .tan,
      .teal,
      .yellow:
      return .black

      case
        .indigo,
        .magenta,
        .navy,
        .oxblood,
        .purple:
      return .white
    }

    var mainColor: Color { Color(self.rawValue) }

    var name: String { self.rawValue.capitalized }
  }
}
