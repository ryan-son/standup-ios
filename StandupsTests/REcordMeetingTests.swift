//
//  REcordMeetingTests.swift
//  StandupsTests
//
//  Created by Geonhee on 2023/02/21.
//

import Clocks
import Dependencies
import XCTest

@testable import Standups

@MainActor
class RecordMeetingTests: XCTestCase {
  func testTimer() async {
    await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      var standup = Standup.mock
      standup.duration = .seconds(6)
      let recordModel = RecordMeetingModel(
  //      clock: ImmediateClock(),
        standup: standup
      )
      let expectation = self.expectation(description: "onMeetingFinished")
      recordModel.onMeetingFinished = { _ in expectation.fulfill() }

      await recordModel.task()
      self.wait(for: [expectation], timeout: 0)
      XCTAssertEqual(recordModel.secondsElapsed, 6)
      XCTAssertEqual(recordModel.dismiss, true)
    }
  }
}
