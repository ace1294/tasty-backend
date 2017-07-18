import Vapor
import FluentProvider

extension Droplet {
    func setupRoutes() throws {
        try resource("user", UserController.self)
        try resource("watchlist", WatchlistController.self)
        
        // Creating Watchlist
        post("user", User.parameter, "watchlist") { req in
            let user = try req.parameters.next(User.self)
            
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let list = try Watchlist(json: json)
            list.userId = user.id
            try list.save()
            return list
        }
        
        // Adding symbol to watchlist
        post("user", User.parameter, "watchlist", Watchlist.parameter, "symbol") { req in
            let watchlist = try req.parameters.next(Watchlist.self)
            
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            var newSymbol = try Symbol(json: json)
            
            // Check if symbol name already exists in database, only save newSymbol if there isn't one
            if let databaseSymbol = try Symbol.makeQuery().filter("name", newSymbol.name).first() {
                newSymbol = databaseSymbol
            }
            else {
                try newSymbol.save()
            }

            
            try watchlist.symbols().add(newSymbol)
            
            try watchlist.save()
            return newSymbol
        }
        
        // Delete Symbol
        delete("user", User.parameter, "watchlist", Watchlist.parameter, "symbol", Symbol.parameter) { req in
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
            
            
            return Response(status: .ok)
        }
        
        // Delete Watchlist
        delete("user", User.parameter, "watchlist", Watchlist.parameter) { req in
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
            
            return Response(status: .ok)
        }
    }
}
