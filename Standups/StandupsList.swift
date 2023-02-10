//
//  StandupsList.swift
//  Standups
//
//  Created by Geonhee on 2023/02/10.
//

import SwiftUI

final class StandupsListModel: ObservableObject {
  @Published var standups: [Standup]

  init(standups: [Standup] = []) {
    self.standups = standups
  }
}

struct StandupsList: View {
  @ObservedObject var model: StandupsListModel

  var body: some View {
    NavigationStack {
      List {
        ForEach(self.model.standups) { standup in
          CardView(standup: standup)
        }
      }
      .navigationTitle("Daily Standups")
    }
  }
}

struct CardView: View {
  let standup: Standup

  var body: some View {
    VStack(alignment: .leading) {
      Text(self.standup.title)
        .font(.headline)
      Spacer()
      HStack {
        Label(
          "\(self.standup.attendees.count)",
          systemImage: "person.3"
        )
        Spacer()
        Label(
          self.standup.duration.formatted(.units()),
          systemImage: "clock"
        )
        .labelStyle(.titleAndIcon)
      }
      .font(.caption)
    }
    .padding()
    .foregroundColor(self.standup.theme.accentColor)
  }
}

struct StandupsList_Previews: PreviewProvider {
  static var previews: some View {
    StandupsList(model: StandupsListModel())
  }
}
