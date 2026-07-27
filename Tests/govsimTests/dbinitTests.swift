//
//  dbinitTests.swift
//  govsim
//
//  Created by Samuel Owino on 27/07/2026.
//
import Testing
import CSQLite
@testable import govsim
@MainActor
struct GovSimDBInitTest {
    @Test func shouldInitDatabase() async throws {
        let initState = sqlite3_initialize()
        try #require(initState == 0)
    }
}

