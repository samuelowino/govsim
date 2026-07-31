//
//  SimEvent.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
// Represents any simulation event, regardless of the event source
// SimEvent contains the following fields
//
//  - identifier : UUID : a unique identifier for each event
//  - name : the name of the event
//  - event_source: enumeration: the source of the event
//  - affected_metric_identifiers: [UUID] : a list of affected metrics: sim core should trigger updates to affected metrics
//  - trigger_metric_identifiers: [UUID] : a list of metrics that have triggered this event: empty of event source is not a metric
//  - crisis_score : (1...0) : a number denoting how much disruptive this event may be to the simulation
//  - policy_identifiers: [UUID] : a list of policies that may be responsibel for this event: empty of event source is not a policy
//  - event_time_stamp : a timestamp that denotes when this event was triggered
//
import Foundation
struct SimEvent: Identifiable, Sendable {
    let id: UUID
    let name: String
    let source: SimEventSource
    let affectedMetrics: [UUID]
    let triggerMetrics: [UUID]
    let crisisScore: Double
    let policies: [UUID]
    let timestamp: Date
    init?(
        id: UUID,
        name: String,
        source: SimEventSource,
        affected: [UUID],
        triggers: [UUID],
        crisisScore: Double,
        policies: [UUID],
        timestamp: Date
    ) {
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "SimEvent", field: "Name", "Validation error: name must not be blank or empty")
            err.logErr()
            return nil
        }
        guard crisisScore <= 1 && crisisScore >= 0 else {
            let err: ValidationError = .modelError(model: "SimEvent",
                                                             field: "Crisis Score",
                                                             "Validation error: crisis score must be between 1 and 0: \(crisisScore)")
            err.logErr()
            return nil
        }
        self.id = id
        self.name = name
        self.source = source
        self.affectedMetrics = affected
        self.triggerMetrics = triggers
        self.crisisScore = crisisScore
        self.policies = policies
        self.timestamp = timestamp
    }
    init?(
        name: String,
        source: SimEventSource,
        crisisScore: Double,
        affected: [UUID] = [],
        triggers: [UUID] = [],
        policies: [UUID] = [],
        timestamp: Date = Date()
    ) {
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "SimEvent", field: "Name", "Validation error: name must not be blank or empty")
            err.logErr()
            return nil
        }
        guard crisisScore <= 1 && crisisScore >= 0 else {
            let err: ValidationError = .modelError(model: "SimEvent",
                                                             field: "Crisis Score",
                                                             "Validation error: crisis score must be between 1 and 0: \(crisisScore)")
            err.logErr()
            return nil
        }
        self.id = UUID()
        self.name = name
        self.source = source
        self.affectedMetrics = affected
        self.triggerMetrics = triggers
        self.crisisScore = crisisScore
        self.policies = policies
        self.timestamp = timestamp
    }
}
