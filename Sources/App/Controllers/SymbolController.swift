//
//  SymbolController
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/19/17.
//
//

import Vapor
import HTTP
import FluentProvider

// Controller for interactions with Symbol Table
final class SymbolController: ResourceRepresentable {
    
    static let symbolPath = "symbol"
    
    // 'GET' on '/symbol' return all symbol objects
    func index(req: Request) throws -> ResponseRepresentable {
        return try Symbol.all().makeJSON()
    }
    
    // Specific 'GET' on '/symbol/1245' return individual symbol object
    func show(req: Request, symbol: Symbol) throws -> ResponseRepresentable {
        return symbol
    }
    
    func makeResource() -> Resource<Symbol> {
        return Resource(
            index: index,
            show: show
        )
    }
}

extension Droplet {
    func setupSymbolRoutes() throws {
        // Adding symbol to watchlist
        post(UserController.userPath, User.parameter, WatchlistController.watchlistPath, Watchlist.parameter, SymbolController.symbolPath) { req in
            let user = try req.parameters.next(User.self)
            let watchlist = try req.parameters.next(Watchlist.self)
            
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            var newSymbol = try Symbol(json: json)
            
            // Check if symbol name already exists in database, only save newSymbol if there isn't one
            if let databaseSymbol = try Symbol.makeQuery().filter(Symbol.nameKey, newSymbol.name).first() {
                newSymbol = databaseSymbol
            }
            else {
                try newSymbol.save()
            }
            
            
            try watchlist.symbols().add(newSymbol)
            
            try watchlist.save()
            return user
        }
        
        // Delete Symbol
        delete(UserController.userPath, User.parameter, WatchlistController.watchlistPath, Watchlist.parameter, SymbolController.symbolPath, Symbol.parameter) { req in
            let user = try req.parameters.next(User.self)
            let watchlist = try req.parameters.next(Watchlist.self)
            let symbol  = try req.parameters.next(Symbol.self)
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
            
            
            return user
        }
    }
}

extension Request {
    // Create a symbol from the JSON body
    func symbol() throws -> Symbol {
        guard let json = json else { throw Abort.badRequest }
        return try Symbol(json: json)
    }
}

extension SymbolController: EmptyInitializable { }
