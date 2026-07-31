//
//  Metric.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
/**
 
 Metric represents the code data point of all the variables in the simulation.
 The exact state of the simulation at a particular instance is determine by evaluating one or more metrics.
 
 Metrics have the following properties:
 - name: the user readable name of the metric for example: ICU units, GDP and so on.
 - identifier UUID : A unique identifier for the metric
 - score : (1...0) A weighted value the determines the health of the metric: positive trends emerge when a metric nears the value 1
 - relation_identifiers: [ UUID]: List of identifiers that point to other metrics which directly or indirectly influnce this metric.
 - absolute value (number): A number that can be displayed to the user to provide context over the state of the simulation; can be a dollar amount, population size etc
 - description (text): A description of the current state of the metric: should be a derived value not a persistence unit
 - level:  (primary/secondary metric) enumeration : determined by a program wide enum: this field allows the simulation to grade the importance of each metric by determining whether it's
        a critical metric (primary) or a non-critical metric (secondary)
 **/
import Foundation
struct Metric: Identifiable, Sendable, Hashable {
    let id: UUID
    let name: String
    let score: Double
    let related: [UUID]
    let displayNumber: Double
    let description: String
    let level: MetricLevel
    init?(id: UUID,
          name: String,
          score: Double,
          related: [UUID],
          displayNumber: Double,
          level: MetricLevel,
          desc: String = "") {
        guard score <= 1 && score >= 0 else {
            let err: ValidationError = .modelError(model: "Metric", field: "Score", "Score must be between 1 and 0")
            err.logErr()
            return nil
        }
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "Metric", field: "Name", "Name must not be blank")
            err.logErr()
            return nil
        }
        self.id = id
        self.name = name
        self.score = score
        self.related = related
        self.displayNumber = displayNumber
        self.description = desc
        self.level = level
    }
    // Quick init
    // Secondary initialization constructor for creating new metrics
    init?(name: String,
          initialScore: Double = 0,
          related: [UUID] = [],
          level: MetricLevel = .PRIMARY,
          desc: String = "") {
        guard initialScore <= 1 && initialScore >= 0 else {
            let err: ValidationError = .modelError(model: "Metric", field: "Score", "Score must be between 1 and 0")
            err.logErr()
            return nil
        }
        guard !name.isEmpty && !name.elementsEqual(" ") else {
            let err: ValidationError = .modelError(model: "Metric", field: "Name", "Name must not be blank")
            err.logErr()
            return nil
        }
        self.id = UUID()
        self.name = name
        self.score = initialScore
        self.related = related
        self.displayNumber = 0.0
        self.description = desc
        self.level = level
    }
}
