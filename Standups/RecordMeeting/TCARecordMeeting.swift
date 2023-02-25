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

  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
  }

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      default:
        return .none
      }
    }
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
