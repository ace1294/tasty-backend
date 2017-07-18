//
//  User.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/15/17.
//
//

import Foundation
import FluentProvider
import HTTP

final class User: Model {
    
    let storage = Storage()
    
    var name: String
    var facebookUserID: String
    
    static let nameKey = "name"
    static let facebookIDKey = "facebook_user_id"
    static let watchlistsKey = "watch_lists"
    
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        facebookUserID = try row.get(User.facebookIDKey)
    }
    
    init(name: String, facebookUserID: String) {
        self.name = name
        self.facebookUserID = facebookUserID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.facebookIDKey, facebookUserID)
        return row
    }
}

extension User {
    var watchlists: Children<User, Watchlist> {
        return children()
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
            builder.string(User.facebookIDKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(User.nameKey),
            facebookUserID: json.get(User.facebookIDKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.nameKey, name)
        try json.set(User.facebookIDKey, facebookUserID)
        let watchlistsAll = try children(type: Watchlist.self).all()
        let watchlistJSONs = try watchlistsAll.map { try $0.makeJSON() }
        let watchlistsNode = JSON(watchlistJSONs)
        try json.set(User.watchlistsKey, watchlistsNode)

        return json
    }
}

//let json = JSON()
//let watchlistsAll = try children(type: Watchlist.self).all()
//let elementsJSON = try watchlistsAll.map { try $0.makeJSON() }
//let jsonDict = try [User.nameKey: name, User.facebookIDKey: facebookUserID,
//                    User.watchlistsKey: elementsJSON.makeNode(in: json.context)] as [String : Any]
//let node = try Node(node: jsonDict)
//
//return JSON(node)


// MARK: HTTP

extension User: ResponseRepresentable { }
