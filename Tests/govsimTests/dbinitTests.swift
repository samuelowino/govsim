//
//  dbinitTests.swift
//  govsim
//
//  Created by Samuel Owino on 27/07/2026.
//
//  Swift Test Docs : https://developer.apple.com/documentation/testing
//
import Testing
import CSQLite
@testable import govsim
@MainActor
struct GovSimDBInitTest {
    @Test func shouldInitDatabase() async throws {
        var db: OpaquePointer?
        let dbOpenFlag: CInt = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        let openState = "govsimdb".withCString { ptr in
            sqlite3_open_v2(ptr, &db, dbOpenFlag, nil)
        }
        defer {
            if db != nil {
                let close_res = sqlite3_close_v2(db)
                if close_res == SQLITE_OK {
                    print("sqlite db closed successfully!")
                } else {
                    print("failed to close db")
                }
            }
        }
        if let errmsgPtr: UnsafePointer<CChar> = sqlite3_errmsg(db) {
            let errmsg: String = String(cString: errmsgPtr)
            print("sqlite_error \(errmsg)")
        }
        try #require(openState == SQLITE_OK)
    }
    @Test func shouldCreateDatabseObjectTest() async throws {
        let govDb = GovSimDatabase()
        let flags: CInt = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        let openResult = try await govDb.getDatabase(flags: flags)
        try #require(openResult.get() != nil, "Null sqlite object")
    }
}

