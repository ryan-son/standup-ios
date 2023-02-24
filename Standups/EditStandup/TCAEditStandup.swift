//
//  TCAEditStandup.swift
//  Standups
//
//  Created by Geonhee on 2023/02/25.
//

import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

// MARK: - Refactored

struct EditStandupFeature: ReducerProtocol {

  struct State: Equatable {
    @BindingState var focus: TCAEditStandupView.Field?
    @BindingState var standup: Standup
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case deleteAttendees(atOffsets: IndexSet)
    case addAttendeeButtonTapped
  }

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none

      case let .deleteAttendees(indices):
        state.standup.attendees.remove(atOffsets: indices)

        if state.standup.attendees.isEmpty {
          state.standup.attendees.append(
            Attendee(id: Attendee.ID(UUID()), name: "")
          )
        }
        let index = min(indices.first!, state.standup.attendees.count - 1)
        state.focus = .attendee(state.standup.attendees[index].id)
        return .none

      case .addAttendeeButtonTapped:
        let attendee = Attendee(id: Attendee.ID(UUID()), name: "")
        state.standup.attendees.append(attendee)
        state.focus = .attendee(attendee.id)
        return .none
      }
    }
  }
}

struct TCAEditStandupView: View {

  enum Field: Hashable {
    case attendee(Attendee.ID)
    case title
  }

  let store: StoreOf<EditStandupFeature>
  @FocusState var focus: Field?

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section {
          TextField("Title", text: viewStore.binding(\.$standup.title))
            .focused(self.$focus, equals: .title)
          HStack {
            Slider(
              value: viewStore.binding(\.$standup.duration.seconds),
              in: 5...30,
              step: 1
            ) {
              Text("Length")
            }
            Spacer()
            Text(viewStore.standup.duration.formatted(.units()))
          }
          ThemePicker(selection: viewStore.binding(\.$standup.theme))
        } header: {
          Text("Standup Info")
        }
        Section {
          ForEach(viewStore.binding(\.$standup.attendees)) { $attendee in
            TextField("Name", text: $attendee.name)
              .focused(self.$focus, equals: .attendee(attendee.id))
          }
          .onDelete { indices in
            viewStore.send(.deleteAttendees(atOffsets: indices))
          }

          Button("New attendee") {
            viewStore.send(.addAttendeeButtonTapped)
          }
        } header: {
          Text("Attendees")
        }
      }
      .bind(viewStore.binding(\.$focus), to: self.$focus)
    }
  }
}
