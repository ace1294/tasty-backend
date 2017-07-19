//
//  WatchList.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/15/17.
//
//

import Foundation
import FluentProvider

final class Watchlist: Model {
    let storage = Storage()
    
    var name: String
    var userId: Identifier?
    
    static let nameKey = "name"
    static let userIdKey = "user_id"
    static let symbolsKey = "symbols"
    
    init(row: Row) throws {
        name = try row.get(Watchlist.nameKey)
        userId = try row.get(Watchlist.userIdKey)
    }
    
    init(name: String) {
        self.name = name
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Watchlist.nameKey, name)
        try row.set(Watchlist.userIdKey, userId)
        return row
    }
}

extension Watchlist {
    var owner: Parent<Watchlist, User> {
        return parent(id: userId)
    }
    
    func symbols() throws -> Siblings<Watchlist, Symbol, Pivot<Watchlist, Symbol>> {
        return siblings()
    }
}

// MARK: Fluent Preparation

extension Watchlist: Preparation {
    // Prepare table in db
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Watchlist.nameKey)
            builder.parent(User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Watchlist: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Watchlist.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Watchlist.idKey, id)
        try json.set(Watchlist.nameKey, name)
        
        let symbolsAll = try symbols().all()
        let symbolJSONs = try symbolsAll.map { try $0.makeJSON() }
        let symbolsNode = JSON(symbolJSONs)
        try json.set(Watchlist.symbolsKey, symbolsNode)
        
        return json
    }
}

// MARK: HTTP

extension Watchlist: ResponseRepresentable { }
