//
//  WatchlistController.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/17/17.
//
//

import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class WatchlistController: ResourceRepresentable {
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(req: Request) throws -> ResponseRepresentable {
        return try Watchlist.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// create and save the post
    func create(request: Request) throws -> ResponseRepresentable {
        let watchlist = try request.watchlist()
        try watchlist.save()
        return watchlist
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(req: Request, watchlist: Watchlist) throws -> ResponseRepresentable {
        return watchlist
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(req: Request, watchlist: Watchlist) throws -> ResponseRepresentable {
        try watchlist.delete()
        return Response(status: .ok)
    }
    
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Watchlist> {
        return Resource(
            index: index,
            store: create,
            show: show,
            destroy: delete
        )
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func watchlist() throws -> Watchlist {
        guard let json = json else { throw Abort.badRequest }
        return try Watchlist(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension WatchlistController: EmptyInitializable { }
