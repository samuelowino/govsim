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
}
enum SQLiteError: Error {
    case openFailedError(msg: String)
}
