//
//  RecordMeeting.swift
//  Standups
//
//  Created by Geonhee on 2023/02/26.
//

import ComposableArchitecture
import SwiftUI

struct RecordMeetingFeature: ReducerProtocol {

  struct State: Equatable {
    @BindingState var destination: Destination?
    var standup: Standup
    var dismiss = false
    var secondsElapsed = 0
    var speakerIndex = 0
    var transcript = ""

    enum Destination: Equatable {
      case alert(AlertState<AlertAction>)
    }
    enum AlertAction: Equatable {
      case confirmSave
      case confirmDiscard
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case nextButtonTapped
    case endMeetingButtonTapped
    case alertButtonTapped(State.AlertAction?)
    case task
    case startSpeechRecognition
    case startTimer
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.speechClient) var speechClient

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none

      case .nextButtonTapped:
        guard state.speakerIndex < state.standup.attendees.count - 1 else {
    //      self.onMeetingFinished()
    //      self.dismiss = true
          state.destination = .alert(.endMeeting(needsDiscard: false))
          return .none
        }

        state.speakerIndex += 1
        state.secondsElapsed = state.speakerIndex * Int(state.standup.durationPerAttendee.components.seconds)
        return .none

      case .endMeetingButtonTapped:
        state.destination = .alert(.endMeeting(needsDiscard: true))
        return .none

      case let .alertButtonTapped(action):
        switch action {
        case .confirmSave:
          // TODO: delegate
//          state.onMeetingFinished(state.transcript)
          state.dismiss = true

        case .confirmDiscard:
          state.dismiss = true

        case nil:
          break
        }

      case .task:
        return .task {
          do {
            let authorization = await self.speechClient.requestAuthorization()

            try await withThrowingTaskGroup(of: Void.self) { group in
              if authorization == .authorized {
                group.addTask {
                  try await self.startSpeechRecognition()
                }
              }

              group.addTask {
                try await self.startTimer()
              }
              try await group.waitForAll()
            }
          } catch {
            state.destination = .alert(AlertState(title: TextState("Something went wrong.")))
          }
        }
      }
    }
  }
}

final class RecordMeetingModel1: ObservableObject {
  let standup: Standup

  @Published var destination: Destination?
  @Published var dismiss = false
  @Published var secondsElapsed = 0
  @Published var speakerIndex = 0
  private var transcript = ""

  @Dependency(\.continuousClock) var clock
  @Dependency(\.speechClient) var speechClient

  enum Destination {
    case alert(AlertState<AlertAction>)
  }
  enum AlertAction {
    case confirmSave
    case confirmDiscard
  }

  var onMeetingFinished: (String) -> Void = unimplemented("RecordMeetingModel.onMeetingFinished")

  var durationRemaining: Duration {
    return self.standup.duration - .seconds(self.secondsElapsed)
  }

  init(
    destination: Destination? = nil,
    standup: Standup
  ) {
    self.destination = destination
    self.standup = standup
  }

  var isAlertOpen: Bool {
    switch destination {
    case .alert:
      return true
    case .none:
      return false
    }
  }

  func nextButtonTapped() {

  }

  func endMeetingButtonTapped() {
    self.destination = .alert(.endMeeting(needsDiscard: true))
  }

  func alertButtonTapped(_ action: AlertAction?) {
    switch action {
    case .confirmSave:
      self.onMeetingFinished(self.transcript)
      self.dismiss = true

    case .confirmDiscard:
      self.dismiss = true

    case nil:
      break
    }
  }

  @MainActor
  func task() async {
    do {
      let authorization = await self.speechClient.requestAuthorization()

      try await withThrowingTaskGroup(of: Void.self) { group in
        if authorization == .authorized {
          group.addTask {
            try await self.startSpeechRecognition()
          }
        }

        group.addTask {
          try await self.startTimer()
        }
        try await group.waitForAll()
      }
    } catch {
      self.destination = .alert(AlertState(title: TextState("Something went wrong.")))
    }
  }

  private func startSpeechRecognition() async throws {
    for try await result in await self.speechClient.startTask(SFSpeechAudioBufferRecognitionRequest()) {
      self.transcript = result.bestTranscription.formattedString
    }
  }

  private func startTimer() async throws {
    for await _ in self.clock.timer(interval: .seconds(1)) where !self.isAlertOpen {
      self.secondsElapsed += 1

      if self.secondsElapsed.isMultiple(of: Int(self.standup.durationPerAttendee.components.seconds)) {
        if self.speakerIndex == self.standup.attendees.count - 1 {
          self.onMeetingFinished(self.transcript)
          self.dismiss = true
          break
        }
        self.speakerIndex += 1
      }
    }
  }
}

extension AlertState where Action == RecordMeetingFeature.State.AlertAction {
  static func endMeeting(needsDiscard: Bool) -> AlertState {
    return AlertState(
      title: {
        TextState("End meeting?")
      }, actions: {
        ButtonState(action: .send(.confirmSave)) { TextState("Save and end") }

        if needsDiscard {
          ButtonState(role: .destructive, action: .send(.confirmDiscard)) { TextState("discard") }
        }

        ButtonState(role: .cancel) { TextState("Resume") }
      }, message: {
        TextState("You are ending the meeting early. What would you like to do?")
      }
    )
  }
}

struct TCARecordMeetingView: View {
  let store: StoreOf<RecordMeetingFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
  }
}

struct RecordMeetingView_Previews: PreviewProvider {
  static var previews: some View {
    TCARecordMeetingView(
      store: Store(
        initialState: RecordMeetingFeature.State(),
        reducer: RecordMeetingFeature()
      )
    )
  }
}
