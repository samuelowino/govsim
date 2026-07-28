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
        let file: ContiguousArray<CChar> = "govsimdb".utf8CString
        var dbFile: UnsafePointer<CChar>?
        file.withUnsafeBufferPointer { ptr in
            dbFile = ptr.baseAddress
        }
        var db: OpaquePointer?
        let dbOpenFlag: CInt = SQLITE_OPEN_CREATE
        
        let vfsModule: ContiguousArray<CChar> = "".utf8CString
        var vfsModulePtr: UnsafePointer<CChar>?
        vfsModule.withUnsafeBufferPointer { prt in
            vfsModulePtr = prt.baseAddress
        }
        let openState = sqlite3_open_v2(&dbFile, &db, dbOpenFlag, vfsModulePtr)

        let errmsgPtr: UnsafePointer<CChar> = sqlite3_errmsg(db)
        let errmsg: String = String(cString: errmsgPtr)
        print("sqlite_error \(errmsg)")
        try #require(openState == SQLITE_OK)
    }
}

