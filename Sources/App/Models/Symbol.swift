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
    
    static let nameKey = "name"
    
    init(row: Row) throws {
        name = try row.get(Symbol.nameKey)
    }
    
    init(name: String) {
        self.name = name
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Symbol.nameKey, name)
        return row
    }
}

// MARK: Fluent Preparation

extension Symbol: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Symbol.nameKey)
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
        try json.set(Symbol.idKey, id)
        try json.set(Symbol.nameKey, name)
        return json
    }
}

// MARK: HTTP

extension Symbol: ResponseRepresentable { }
