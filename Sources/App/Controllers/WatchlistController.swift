//
//  WatchlistController.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/17/17.
//
//

import Vapor
import HTTP
import FluentProvider

// Controller for interactions with Watchlist Table
final class WatchlistController: ResourceRepresentable {
    
    static let watchlistPath = "watchlist"
    
    // 'GET' on '/watchlist' return all watchlist objects
    func index(req: Request) throws -> ResponseRepresentable {
        return try Watchlist.all().makeJSON()
    }
    
    // Specific 'GET' on '/watchlist/1245' return individual watchlist object
    func show(req: Request, watchlist: Watchlist) throws -> ResponseRepresentable {
        return watchlist
    }
    
    func makeResource() -> Resource<Watchlist> {
        return Resource(
            index: index,
            show: show
        )
    }
}

extension Droplet {
    func setupWatchlistRoutes() throws {
        // Get all watchlists for user
        get(UserController.userPath, User.parameter, WatchlistController.watchlistPath) { req in
            let user = try req.parameters.next(User.self)
            let watchlistsAll = try user.watchlists.all()
            let watchlistJSONs = try watchlistsAll.map { try $0.makeJSON() }
            return JSON(watchlistJSONs)
        }
        
        // Get individual watchlist for user
        get(UserController.userPath, User.parameter, WatchlistController.watchlistPath, Watchlist.parameter) { req in
            let watchlist = try req.parameters.next(Watchlist.self)
            return watchlist
        }
        
        // Creating Watchlist
        post(UserController.userPath, User.parameter, WatchlistController.watchlistPath) { req in
            let user = try req.parameters.next(User.self)
            
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let list = try Watchlist(json: json)
            list.userId = user.id
            try list.save()
            return user
        }
        
        // Delete Watchlist
        delete(UserController.userPath, User.parameter, WatchlistController.watchlistPath, Watchlist.parameter) { req in
            let user = try req.parameters.next(User.self)
            let watchlist = try req.parameters.next(Watchlist.self)
            
            let symbols = try watchlist.symbols().all()
            for symbol in symbols {
                // Delete Pivot
                let pivotToDelete = try Pivot<Watchlist, Symbol>.makeQuery().and({ andGroup in
                    try andGroup.filter("watchlist_id", watchlist.id)
                    try andGroup.filter("symbol_id", symbol.id)
                })
                
                try pivotToDelete.delete()
                
                // If not pivots left, delete symbol
                if try Pivot<Watchlist, Symbol>.makeQuery().filter("symbol_id", symbol.id).all().count == 0 {
                    try symbol.delete()
                }
            }
            
            try watchlist.delete()
            
            return user
        }
    }
}

extension Request {
    /// Create a Watchlist from the JSON body
    func watchlist() throws -> Watchlist {
        guard let json = json else { throw Abort.badRequest }
        return try Watchlist(json: json)
    }
}

// This will allow it to be passed by type.
extension WatchlistController: EmptyInitializable { }
