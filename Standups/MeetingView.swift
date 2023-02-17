//
//  MeetingView.swift
//  Standups
//
//  Created by Geonhee on 2023/02/17.
//

import SwiftUI

struct MeetingView: View {
  let meeting: Meeting
  let standup: Standup

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Divider()
          .padding(.bottom)
        Text("Attendees")
          .font(.headline)
        ForEach(self.standup.attendees) { attendee in
          Text(attendee.name)
        }
        Text("Transcript")
          .font(.headline)
          .padding(.top)
        Text(self.meeting.transcript)
      }
    }
    .navigationTitle(
      Text(self.meeting.date, style: .date)
    )
    .padding()
  }
}

struct MeetingView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      MeetingView(meeting: Standup.mock.meetings.first!, standup: .mock)
    }
  }
}
