//
//  UserController.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/17/17.
//
//

import Vapor
import HTTP

// Controller for RESTful interactions with User Table
final class UserController: ResourceRepresentable {
    
    // 'GET' on '/user' return all user objects
    func index(req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    // 'POST' on '/user', create new User
    func create(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        try user.save()
        return user
    }    
    
    // Specific 'GET' on '/user/1245' return individual user object
    func show(req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    // 'DELETE' on 'posts/l2jd9' delete specfcic user
    func delete(req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show,
            destroy: delete
        )
    }
}

extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable { }
