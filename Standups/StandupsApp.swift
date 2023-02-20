//
//  StandupsApp.swift
//  Standups
//
//  Created by Geonhee on 2023/02/08.
//

import SwiftUI

@main
struct StandupsApp: App {
  var body: some Scene {
    WindowGroup {
      StandupsList(
        model: StandupsListModel(
//          destination: .detail(
//            StandupDetailModel(
//              destination: .record(RecordMeetingModel(standup: standup)),
//              standup: standup
//            )
//          )
        )
      )
    }
  }
}
