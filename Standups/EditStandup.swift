//
//  EditStandup.swift
//  Standups
//
//  Created by Geonhee on 2023/02/14.
//

import SwiftUI
import SwiftUINavigation

final class EditStandupModel: ObservableObject {
  @Published var focus: EditStandupView.Field?
  @Published var standup: Standup
  
  init(
    focus: EditStandupView.Field? = .title,
    standup: Standup
  ) {
    self.focus = .title
    self.standup = standup

    if self.standup.attendees.isEmpty {
      self.standup.attendees.append(
        Attendee(id: Attendee.ID(UUID()), name: "")
      )
    }
  }
  
  func deleteAttendees(atOffsets indices: IndexSet) {
    self.standup.attendees.remove(atOffsets: indices)
    
    if self.standup.attendees.isEmpty {
      self.standup.attendees.append(
        Attendee(id: Attendee.ID(UUID()), name: "")
      )
    }
    self.focus = .attendee(self.standup.attendees[indices.first!].id)
  }
  
  func addAttendeeButtonTapped() {
    let attendee = Attendee(id: Attendee.ID(UUID()), name: "")
    self.standup.attendees.append(attendee)
    self.focus = .attendee(attendee.id)
  }
}

struct EditStandupView: View {
  enum Field: Hashable {
    case attendee(Attendee.ID)
    case title
  }

  @FocusState var focus: Field?
  @ObservedObject var model: EditStandupModel

  var body: some View {
    Form {
      Section {
        TextField("Title", text: self.$model.standup.title)
          .focused(self.$focus, equals: .title)
        HStack {
          Slider(value: self.$model.standup.duration.seconds, in: 5...30, step: 1) {
            Text("Length")
          }
          Spacer()
          Text(self.model.standup.duration.formatted(.units()))
        }
        ThemePicker(selection: self.$model.standup.theme)
      } header: {
        Text("Standup Info")
      }
      Section {
        ForEach(self.$model.standup.attendees) { $attendee in
          TextField("Name", text: $attendee.name)
            .focused(self.$focus, equals: .attendee(attendee.id))
        }
        .onDelete { indices in
          self.model.deleteAttendees(atOffsets: indices)
        }

        Button("New attendee") {
          self.model.addAttendeeButtonTapped()
        }
      } header: {
        Text("Attendees")
      }
    }
    .bind(self.$model.focus, to: self.$focus)
  }
}

struct ThemePicker: View {
  @Binding var selection: Theme

  var body: some View {
    Picker("Theme", selection: $selection) {
      ForEach(Theme.allCases) { theme in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(theme.mainColor)
          Label(theme.name, systemImage: "paintpalette")
            .padding(4)
        }
        .foregroundColor(theme.accentColor)
        .fixedSize(horizontal: false, vertical: true)
        .tag(theme)
      }
    }
  }
}

extension Duration {
  fileprivate var seconds: Double {
    get { Double(self.components.seconds / 60 ) }
    set { self = .seconds(newValue * 60) }
  }
}

struct EditStandup_Previews: PreviewProvider {
  static var previews: some View {
    WithState(initialValue: Standup.mock) { $standup in
      EditStandupView(model: EditStandupModel(standup: .mock))
    }
  }
}
