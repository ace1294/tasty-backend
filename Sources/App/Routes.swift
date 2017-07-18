import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
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
            
            let symbol = try Symbol(json: json)
            symbol.watchlistId = watchlist.id
            try symbol.save()
            return symbol
        }
        
        try resource("posts", PostController.self)
        try resource("user", UserController.self)
        try resource("watchlist", WatchlistController.self)
    }
}
