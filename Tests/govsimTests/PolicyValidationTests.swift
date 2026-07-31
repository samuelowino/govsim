//
//  PolicyValidationTests.swift
//  govsim
//
//  Created by Samuel Owino on 01/08/2026.
//
import Testing
import Foundation
@testable import govsim
struct PolicyValidationTests {
    @Test func shouldValidatePoliciesTest() throws {
        let invalidPolicy = SimPolicy(id: UUID(uuidString: "c461edbb-1195-4721-a902-755a0e707a91")!,
                                      name: "", desc: "", effects: [:])
        try #require(invalidPolicy == nil, "Policy validation failed, invalid policy accepted")
        let invalidPolicy2 = SimPolicy(name: " ", desc: "", effects: [:])
        try #require(invalidPolicy2 == nil, "Policy validation failed, invalid policy accepted")
        let validPolicy = SimPolicy(name: "Minimum Wage Increase to 2 shillings", desc: "Increased Minimum Wage", effects: [Metric(name: "Worker Satisfaction")! : 0.07])
        try #require(validPolicy != nil, "Policy validation failed, a valid policy was rejected")
    }
}
