//
//  Error++.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
import Foundation
extension Error {
    func printErr() {
        print("Simulation Error: \(self.localizedDescription)")
    }
    func logErr() {
        // TODO: Persist error logs into sqlite or log file for analysis and debugging
        print("Simulation Error: \(self.localizedDescription)")
    }
}
enum SQLiteError: Error {
    case openFailedError(msg: String)
}
enum ValidationError: Error {
    case modelError(model: String, field: String, _ msg: String)
}
