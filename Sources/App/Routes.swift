import Vapor


extension Droplet {
    func setupRoutes() throws {
        try resource("user", UserController.self)
        try resource("watchlist", WatchlistController.self)
        try resource("symbol", SymbolController.self)
        
        try setupUserRoutes()
        try setupWatchlistRoutes()
        try setupSymbolRoutes()
        
        // Creating Watchlist
        get("hello") { req in
            return "welcome to the tasty backend"
        }
        
    }
}
