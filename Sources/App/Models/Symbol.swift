//
//  Symbol.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/15/17.
//
//

import Foundation
import FluentProvider

final class Symbol: Model {
    let storage = Storage()
    
    var name: String
    var watchlistId: Identifier?
    
    static let nameKey = "name"
    static let watchlistIdKey = "watchlist_id"
    
    init(row: Row) throws {
        name = try row.get(Symbol.nameKey)
        watchlistId = try row.get(Symbol.watchlistIdKey)
    }
    
    init(name: String) {
        self.name = name
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Symbol.nameKey, name)
        try row.set(Symbol.watchlistIdKey, watchlistId)
        return row
    }
}

extension Symbol {
    var owner: Parent<Symbol, Watchlist> {
        return parent(id: watchlistId)
    }
}

// MARK: Fluent Preparation

extension Symbol: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Symbol.nameKey)
            builder.parent(Watchlist.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Symbol: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Symbol.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Symbol.nameKey, name)
        return json
    }
}

// MARK: HTTP

extension Symbol: ResponseRepresentable { }
