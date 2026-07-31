//
//  SimEventValidationTests.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
import Testing
import Foundation
@testable import govsim
struct SimEventValidationTests {
    @Test func shouldValidateEventTest() throws {
        let invalidEvent = SimEvent(name: "", source: .POLICY, crisisScore: 43.55)
        let invalidEvent2 = SimEvent(
            id: UUID(), name: " ",
            source: .METRIC_CHANGE,
            affected: [UUID(uuidString: "f84a4e99-4f41-4168-82d4-8c7ceeddcd86")!],
            triggers: [],
            crisisScore: 55.22,
            policies: [],
            timestamp: Date())
        try #require(invalidEvent == nil, "Event validation failed, should return nil")
        try #require(invalidEvent2 == nil, "Event validation failed, should return nil")
        let validEvent = SimEvent(name: "Health Policy Change (Reduce Bed Capacity)", source: .POLICY, crisisScore: 0.9)
        try #require(validEvent != nil, "Validation Failed, rejected a valid event")
    }
}
