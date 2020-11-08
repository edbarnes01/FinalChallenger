//
//  Session.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 15/07/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

extension QueryDocumentSnapshot {

    func prepareForDecoding() -> [String: Any] {
        var data = self.data()
        data["id"] = self.documentID

        return data
    }
}

extension DocumentSnapshot {
    func prepareDocForDecoding() -> [String: Any] {
        var data = self.data()
        data!["id"] = self.documentID

        return data!
    }
}

struct friend: Equatable, Codable {
    var uid: String
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case username, uid = "objectID"
    }
    
    
}

struct User {
    var uid: String
    var email: String?
    var username: String?
    var friends = [friend]()
    
    
    init(uid: String, email: String?, username: String?) {
        self.uid = uid
        self.email = email
        self.username = username
    }
}

struct league: Equatable {
    var uid: String
    var name: String
}

class FirebaseSession: ObservableObject {


    @Published var session: User?
    @Published var isLoggedIn: Bool?
    @Published var leagueData = [league]()
    @Published var matchDays = [matchDay]()
    @Published var pendingChallenges = [challenge]()
    @Published var activeChallenges = [challenge]()

    let db = Firestore.firestore()
    let users = Firestore.firestore().collection("usernames")
    

    init() {
        self.logOut()
        self.listen()
        
    }
    
    func logIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
        //self.leagueListen()
    }
    
    func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func updateUsername(username: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { (error) in
            if (error != nil) {
                print((error?.localizedDescription)!)
            }
        }
    }
    
    func getUsername(uid: String) {
        let playerRef = db.collection("playerData").document(session!.uid)
            playerRef.getDocument { (document, error) in
                let playerData = document?.data()
                let username = playerData!["username"] as! String
                self.session?.username = username
        }
    }
    
    func listen() {
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.session = User(uid: user.uid, email: user.email, username: user.displayName)
                self.getUsername(uid: user.uid)
                self.isLoggedIn = true
                //print((self.session?.email)! + "has logged in")
                //print(user.displayName)
                //print((self.session?.username!)!)
                //self.leagueListen()
                self.challengesListen()
                self.queryTest()
                self.matchPull()
                self.getFriends()
                
                //self.userNameListen()
                //self.messageListen()
                
                
            } else {
                print("not logged in")
                self.isLoggedIn = false
                self.session = nil
            }
        }
    }
    
    func challengesListen() {
        let playerRef = db.collection("playerData").document(session!.uid)
        playerRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let data = snapshot?.data()
                
                if (data!["challenges"] != nil) {
                    let challenges = data!["challenges"] as! NSArray
                    print("listened")
                    self.pendChallengePull(challenges: challenges)
                    self.activeChallengesPull(challenges: challenges)
                    
                }
            }
        }
    }
    
    func pendChallengePull(challenges: NSArray){
        let pendChallengesRef = db.collection("pendingChallenges")//.document(uid)
        
        for i in challenges {
            pendChallengesRef.document(i as! String).getDocument { (document, error) in
                
                let res = Result {
                    try document!.data(as: challenge.self)
                }
                switch res {
                case .success(let Challenge):
                    if let Challenge = Challenge {
                        if !self.pendingChallenges.contains(Challenge) {
                            self.pendingChallenges.append(Challenge)
                        }
                    } else {
                        print("Doc no existe")
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    func activeChallengesPull(challenges: NSArray) {
        let pendChallengesRef = db.collection("activeChallenges")
        
        for i in challenges {
            pendChallengesRef.document(i as! String).getDocument { (document, error) in
                
                let res = Result {
                    try document!.data(as: challenge.self)
                }
                switch res {
                case .success(let Challenge):
                    if let Challenge = Challenge {
                        if !self.activeChallenges.contains(Challenge) {
                            self.activeChallenges.append(Challenge)
                        }
                        if let index = self.pendingChallenges.firstIndex(of: Challenge) {
                            self.pendingChallenges.remove(at: index)
                        }
                    } else {
                        print("Doc no existe")
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    /*
    func leagueListen() {
        print("this is the document name")
        print(session!.uid)
        let playerRef = db.collection("playerData").document(session!.uid)
        playerRef.addSnapshotListener { snapshot, error in
        if let error = error {
            print("Error getting documents: \(error)")
        } else {
            let data = snapshot?.data()
            if (data!["leagues"] != nil) {
                let leagues = data!["leagues"] as! NSArray
                self.leaguePull(leagues: leagues)
                print(leagues as Any)
            } else {
                
            }
            
            }
        }
    }
    
    */
    
    func matchPull() {
        if !self.matchDays.isEmpty {
            self.matchDays.removeAll()
        }
        db.collection("matches").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let matchDL = document.prepareForDecoding()
                    let jsonData = try? JSONSerialization.data(withJSONObject:matchDL)
                    let decoder = JSONDecoder()
                    do {
                        let matchdayData = try decoder.decode(matchDay.self, from: jsonData!)
                        self.matchDays.append(matchdayData)
                    } catch {
                        print(error)
                    }
                }
            }
            print(self.matchDays)
        }
        
    }
    
    func leaguePull(leagues: NSArray){
        let leagueRef = db.collection("leagues")//.document(uid)
        print(leagues)
        for i in leagues {
            leagueRef.document(i as! String).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if !self.leagueData.contains(league(uid: i as! String, name: data?["name"] as! String)) {
                        self.leagueData.append(league(uid: i as! String, name: data?["name"] as! String))
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
    }

    
    func logOut() {
        try! Auth.auth().signOut()
    }
    
    func createLeague(name: String, completion: (Error?, String) -> Void) {
        let leaguePin = randomString(length: 6)
        let leagueRef = self.db.collection("leagues").document()
        
        leagueRef.setData([
            "name": name,
            "pin" : leaguePin,
            "admin" : String(self.session!.uid),
            "players" : [String(self.session!.uid)]
            ])
        
        let playerRef = db.collection("playerData").document(session!.uid)
        playerRef.updateData([
            "leagues" : FieldValue.arrayUnion([leagueRef.documentID])
        ])
        
        completion(nil, leaguePin)
    }
    
    func createPlayerData(uid: String, username: String){
        let playerRef = self.db.collection("playerData").document(uid)
        playerRef.setData([
            "friends" : [],
            "leagues" : [],
            "challenges" : [],
            "username" : username
        ])
    }
    
    func addPlayerToLeague(league: String) {
        let leagueRef = self.db.collection("leagues").document(league)
        return leagueRef.updateData([
            "players" : FieldValue.arrayUnion([session!.uid])
        ])
    }
    
    func addLeagueToPlayer(league: String) {
        let playerRef = db.collection("playerData").document(session!.uid)
        return playerRef.updateData([
            "leagues" : FieldValue.arrayUnion([league])
        ])
    }
    
    func addFriend(uid: String, name: String, completion: (Bool) -> Void) {
        let playerRef = self.db.collection("playerData").document(self.session!.uid)
        let friendData = [
            "username" : name,
            "uid" : uid
        ]
        completion(true)
        return playerRef.updateData([
            "friends" : FieldValue.arrayUnion([friendData])
        ])
        
    }
    
    func queryTest() {
        let matchRef = self.db.collection("matches").whereField("fxtures", arrayContains: "sr:match:23203817")
        matchRef.getDocuments() {(snap, err) in
            if err != nil {
                print("error in getting docs")
                print((err?.localizedDescription)!)
            } else {
                for document in snap!.documents {
                    print(document.data())
                }
            }
        }
    }
    
    func addChallengeRef(challengeRef: String) {
        let playerRef = self.db.collection("playerData").document(self.session!.uid)
        return playerRef.updateData([
            "challenges" : FieldValue.arrayUnion([challengeRef])
        ])
    }
    
    func createChallenge(Challenge: challenge, completion: @escaping (Error?, Bool) -> Void) {
        
        let challengeRef = db.collection("pendingChallenges").document(Challenge.id.uuidString)
        do {
            try challengeRef.setData(from: Challenge)
        } catch let error {
            print("Error uploading challenge: \(error)")
        }
        addChallengeRef(challengeRef: Challenge.id.uuidString)
        completion(nil, true)
        
    }
    
    func acceptChallenge(Challenge: challenge) {
        let challengeRef = db.collection("pendingChallenges").document(Challenge.id.uuidString)
        return challengeRef.updateData([
            "pending" : FieldValue.arrayUnion([false])
        ])
        /*
        let challengeRef = db.collection("pendingChallenges").document(Challenge.id.uuidString)
        challengeRef.delete()
        let newChallengeRef = db.collection("activeChallenges").document(Challenge.id.uuidString)
        do {
            try newChallengeRef.setData(from: Challenge)
        } catch let error {
            print("Error activating challenge: \(error)")
        }
        */
    }
    
    func removeFriend(Friend: friend) {
        let playerRef = self.db.collection("playerData").document(self.session!.uid)
        return playerRef.updateData([
            "friends" : FieldValue.arrayRemove([Friend])
        ])
    }
    
    func getFriends() {
        let playerRef = db.collection("playerData").document(session!.uid)
        self.session?.friends.removeAll()
        playerRef.getDocument { (document, error) in
            let userData = document?.data()
            let friends = userData!["friends"] as! NSArray
            
            if !(friends.count < 1) {
                for i in friends {
                    //print(i)
                    let friendData = i as! Dictionary<String, String>
                    print(friendData["username"]!)
                    let Friend = friend(uid: friendData["uid"]!, username: friendData["username"]!)
                    searchUID(uid: Friend.uid) { (err, res) in
                        if (err != nil) {
                            if let index = self.session?.friends.firstIndex(of: Friend) {
                                self.session?.friends.remove(at: index)
                                self.removeFriend(Friend: Friend)
                            }
                            
                        } else {
                            if !((self.session?.friends.contains(Friend))!){
                                self.session?.friends.append(Friend)
                            }
                        }
                    }
                    
                    
                    
                }
                
            }
            
        }
    }
    
    func joinLeague(pin: String, completion: @escaping (Error?, String) -> Void) {
        
        db.collection("leagues").whereField("pin", isEqualTo: pin)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error joining league: \(err)")
                    completion(err, "Connection error occurred.")
                    
                    
                } else {
                    print(querySnapshot?.documents ?? "empty")
                    if querySnapshot!.documents.isEmpty {
                        completion(JoinLeagueError.leagueNotFound, "League not found.")
                    } else {
                        for document in querySnapshot!.documents {
                            
                            print("\(document.documentID) => \(document.data())")
                            let data = document.data()
                            if data["players"] != nil {
                                let players = data["players"] as! NSArray
                                if !players.contains(self.session!.uid) {
                                    self.addLeagueToPlayer(league: document.documentID)
                                    self.addPlayerToLeague(league: document.documentID)
                                }
                            }
                            
                        }
                    }
                }
        }
        //CHXr1N
    }
    
}

typealias JoinLeagueCallback = (Error?) -> Void


