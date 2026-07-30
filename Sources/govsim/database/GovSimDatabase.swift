//
//  GovSimDatabase.swift
//  govsim
//
//  Created by Samuel Owino on 31/07/2026.
//
import CSQLite
struct GovSimDatabase {
    func getDatabase(flags: CInt) async throws -> Result<OpaquePointer?,Error> {
        var db: OpaquePointer?
        let name = "govsimdb"
        let open_state = name.withCString { namePtr in
            sqlite3_open_v2(namePtr, &db, flags, nil)
        }
        if open_state == SQLITE_OK {
            return .success(db)
        } else {
            if let errmsg = sqlite3_errmsg(db) {
                return .failure(SQLiteError.openFailedError(msg: String(cString: errmsg)))
            } else {
                return .failure(SQLiteError.openFailedError(msg: "Failed to open db connection, unknown error: code [\(open_state)]"))
            }
        }
    }
}
