//
//  MetricValidationTests.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
import Testing
import Foundation
@testable import govsim
struct MetricValidationTests {
    @Test func shouldValidateMetricFieldsTest() throws {
        let invalidMetric: Metric? = Metric(
            id: UUID(),
            name: "", // name must not be blank
            score: 5, // score range is limited to 1..0
            related: [], displayNumber: Double.pi, level: .PRIMARY)
        try #require(invalidMetric == nil, "Metric validation failed, invalid fields accepted")
        let validMetic: Metric? = Metric(name: "Life Expectancy", initialScore: 0.7)
        try #require(validMetic != nil, "Valid metric should pass validation")
    }
}
