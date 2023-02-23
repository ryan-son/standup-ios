//
//  StandupsList.swift
//  Standups
//
//  Created by Geonhee on 2023/02/10.
//

import Combine
import Dependencies
import IdentifiedCollections
import SwiftUI
import SwiftUINavigation

@MainActor
final class StandupsListModel: ObservableObject {
  @Published var destination: Destination? {
    didSet { self.bind() }
  }
  @Published var standups: IdentifiedArrayOf<Standup>

  private var destinationCancellable: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []

  @Dependency(\.dataManager) var dataManager
  @Dependency(\.mainQueue) var mainQueue

  enum Destination {
    case add(EditStandupModel)
    case detail(StandupDetailModel)
  }

  init(
    destination: Destination? = nil
  ) {
    self.destination = destination
    self.standups = []

    do {
      self.standups = try JSONDecoder().decode(
        IdentifiedArray.self,
        from: self.dataManager.load(.standups)
      )
    } catch {

    }

    self.$standups
      .dropFirst()
      .debounce(for: .seconds(1), scheduler: self.mainQueue)
      .sink { [weak self] standups in
        do {
          try self?.dataManager.save(
            JSONEncoder().encode(standups),
            .standups
          )
        } catch {
          // TODO: alert
        }
      }
      .store(in: &self.cancellables)

    self.bind()
  }

  func addStandupButtonTapped() {
    self.destination = .add(EditStandupModel(standup: Standup(id: Standup.ID(UUID()))))
  }

  func dismissAddStandupButtonTapped() {
    self.destination = nil
  }

  func confirmAddStandupButtonTapped() {
    defer { self.destination = nil }

    guard case let .add(editStandupModel) = self.destination else { return }
    var standup = editStandupModel.standup

    standup.attendees.removeAll { attendee in
      attendee.name.allSatisfy(\.isWhitespace)
    }
    if standup.attendees.isEmpty {
      standup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
    }
    self.standups.append(standup)
  }

  func standupTapped(standup: Standup) {
    self.destination = .detail(StandupDetailModel(standup: standup))
  }

  func bind() {
    switch self.destination {
    case let .detail(standupDetailModel):
      standupDetailModel.onConfirmDeletion = { [weak self, id = standupDetailModel.standup.id] in
        guard let self else { return }

        withAnimation {
//          self.standups.removeAll { $0.id == id }
          self.standups.remove(id: id)
          self.destination = nil
        }
      }

      self.destinationCancellable = standupDetailModel.$standup
        .sink { [weak self] standup in
          guard let self else { return }
//          guard let index = self.standups.firstIndex(where: { $0.id == standup.id }) else { return }
//          try await apiService.save(...)
//          self.standups[index] = standup
          self.standups[id: standup.id] = standup
        }

    case .add, .none:
      break
    }
  }
}

struct StandupsList: View {
  @ObservedObject var model: StandupsListModel

  var body: some View {
    NavigationStack {
      List {
        ForEach(self.model.standups) { standup in
          Button {
            self.model.standupTapped(standup: standup)
          } label: {
            CardView(standup: standup)
              .listRowBackground(standup.theme.mainColor)
          }
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
      ) { $model in
        NavigationStack {
          EditStandupView(model: model)
            .navigationTitle("New standup")
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                  self.model.dismissAddStandupButtonTapped()
                }
              }
              ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                  self.model.confirmAddStandupButtonTapped()
                }
              }
            }
        }
      }
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StandupsListModel.Destination.detail
      ) { $detailModel in
          StandupDetailView(model: detailModel)
        }
    }
  }
}

struct StandupsList_Previews: PreviewProvider {
  static var previews: some View {
    StandupsList(
      model: StandupsListModel(
//        destination: .add(
//          EditStandupModel(
//            focus: .attendee(Standup.mock.attendees[3].id),
//            standup: .mock
//          )
//        ),
      )
    )
  }
}
