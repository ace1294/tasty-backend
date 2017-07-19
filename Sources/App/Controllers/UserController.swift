//
//  UserController.swift
//  tasty-backend
//
//  Created by Jason Dimitriou on 7/17/17.
//
//

import Vapor
import HTTP

// Controller for interactions with User Table
final class UserController: ResourceRepresentable {
    
    static let userPath = "user"
    static let facebookUserIdPath = "facebookUserId"
    
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
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show
        )
    }
}

extension Droplet {
    
    func setupUserRoutes() throws {
        get(UserController.userPath, UserController.facebookUserIdPath, String.parameter) { req in
            let facebookId = try req.parameters.next(String.self)
            let user = try User.makeQuery().filter(User.facebookIDKey, facebookId).first()
            
            if let u = user {
                return u
            }
            else {
                return Response(status: .noContent)
            }
        }
    }
}

extension Request {
    // Create a user from the JSON body
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable { }
