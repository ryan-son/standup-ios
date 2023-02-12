//
//  StandupsList.swift
//  Standups
//
//  Created by Geonhee on 2023/02/10.
//

import SwiftUINavigation
import SwiftUI

final class StandupsListModel: ObservableObject {
  @Published var destination: Destination?
  @Published var standups: [Standup]

  enum Destination {
    case add(Standup)
  }

  init(
    destination: Destination? = nil,
    standups: [Standup] = []
  ) {
    self.standups = standups
  }

  func addStandupButtonTapped() {
    self.destination = .add(Standup(id: Standup.ID(UUID())))
  }
}

struct StandupsList: View {
  @ObservedObject var model: StandupsListModel

  var body: some View {
    NavigationStack {
      List {
        ForEach(self.model.standups) { standup in
          CardView(standup: standup)
            .listRowBackground(standup.theme.mainColor)
        }
      }
      .toolbar {
        Button {
          self.model.addStandupButtonTapped()
        } label: {
          Image(systemName: "plus")
        }

      }
      .navigationTitle("Daily Standups")
      .sheet(
        unwrapping: self.$model.destination,
        case: /StandupsListModel.Destination.add
      ) { $standup in
          let _
        }
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
        .labelStyle(.trailingIcon)
      }
      .font(.caption)
    }
    .padding()
    .foregroundColor(self.standup.theme.accentColor)
  }
}

struct TrailingIconLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.title
      configuration.icon
    }
  }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
  static var trailingIcon: Self { Self() }
}

@MainActor
struct StandupsList_Previews: PreviewProvider {
  static var previews: some View {
    StandupsList(
      model: StandupsListModel(
        standups: [
          .mock
        ]
      )
    )
  }
}
