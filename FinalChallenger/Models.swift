//
//  Models.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 03/08/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//



import Foundation
let testMatch = returnTestMatches()

struct match: Codable {
    
    
    var id: String
    var scheduled: String
    var teams: [team]
    var tournament: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case scheduled
        case teams
        case tournament
    }
}

struct matchDay: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }
    
    let id: String
    var fixtures: [match]?
    var noMatches: Bool?
}

struct team: Codable {
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

struct player: Codable {
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

struct option {
    var name: String
    var hashed: Int
}

struct challenge: Equatable, Codable, Identifiable {

    static func == (lhs: challenge, rhs: challenge) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
    var id: UUID
    var name: String
    var pending: Bool
    var receivePlayer: player
    var sendPlayer: player
    var Match: match
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case name
        case pending
        case receivePlayer
        case sendPlayer
        case Match = "match"
        
    }
}


struct unOvGoals {
    var Challenge: challenge
    
}
