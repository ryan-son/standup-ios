//
//  StandupsList.swift
//  Standups
//
//  Created by Geonhee on 2023/02/10.
//

import SwiftUI

final class StandupsListModel: ObservableObject {
  
}

struct StandupsList: View {
  var body: some View {
    NavigationStack {
      List {
        
      }
      .navigationTitle("Daily Standups")
    }
  }
}

struct StandupsList_Previews: PreviewProvider {
  static var previews: some View {
    StandupsList()
  }
}
