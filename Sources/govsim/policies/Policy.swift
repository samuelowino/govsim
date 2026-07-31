//
//  Policy.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
// Represents a policy change made by a participant in the simulation.
// Policies are user driven events that have the ability to
// influence the state of the simulation through a chnage in the simulation metrics
//
// Policy Fields
// - identifier UUID
// - name
// - description
// - affected_metric_identifiers: (dictionary) [metric: score_change (+/- 0.01)]
import Foundation
struct SimPolicy: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let affectedMetrics: [Metric:Double]
    init?(
        id: UUID,
        name: String,
        desc: String,
        effects: [Metric:Double]
    ) {
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "SimPolicy", field: "name", "Validation failed, name cannot be blank or empty")
            err.logErr()
            return nil
        }
        guard !effects.isEmpty else {
            let err: ValidationError = .modelError(model: "SimPolicy", field: "Affected Metrics Dictionary", "Validation failed, affected metrics cannot be empty, include affected metrics and degree of change")
            err.logErr()
            return nil
        }
        self.id = id
        self.name = name
        self.description = desc
        self.affectedMetrics = effects
    }
    init?(
        name: String,
        desc: String,
        effects: [Metric:Double]
    ) {
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "SimPolicy", field: "name", "Validation failed, name cannot be blank or empty")
            err.logErr()
            return nil
        }
        guard !effects.isEmpty else {
            let err: ValidationError = .modelError(model: "SimPolicy", field: "Affected Metrics Dictionary", "Validation failed, affected metrics cannot be empty, include affected metrics and degree of change")
            err.logErr()
            return nil
        }
        self.id = UUID()
        self.name = name
        self.description = desc
        self.affectedMetrics = effects
    }
}
