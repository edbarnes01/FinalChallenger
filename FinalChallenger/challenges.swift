//
//  challenges.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 31/08/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import Foundation
import SwiftUI
import AlgoliaSearchClient



class challengeObserve: ObservableObject {
    @Published var Challenge: challenge
    
    init(Challenge: challenge){
        self.Challenge = Challenge
    }
}

struct chooseChallengeView: View {
    var matchData: match
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                   firstGoalscorerGet(matchData: matchData)
                    over1_5Goals(matchData: matchData)
                }.listStyle(GroupedListStyle())
            }
        }//.navigationBarTitle("No")
        //.navigationBarHidden(true)

    }
}

struct optionBox: View {
    
    let clicked : () -> Void
    
    var text: String
    
    var body: some View {
        Text(text)
        .background(Color.white)
        .foregroundColor(Color.black)
        .onTapGesture {
            self.clicked()
        }
    }
}

struct friendListItem: View {
    @EnvironmentObject var session: FirebaseSession
    var Friend: friend
    @State var added = false
    
    var body: some View {
        HStack {
            Text(Friend.username)
            Spacer()
            if (self.session.session?.friends.contains(Friend))! {
                Text("Friends")
                    .foregroundColor(Color.gray)
            } else {
                if added {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.blue)
                        
                } else {
                    Image(systemName: "plus")
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            self.session.addFriend(uid: self.Friend.uid, name: self.Friend.username) { (res) in
                                if res == true {
                                    self.added = true
                                    self.session.getFriends()
                                }
                                
                            }
                    }
                }
            }
            
        }.frame(width: 200)
    }
}

struct addFriendView: View {
    @State var friends = [friend]()
    var hostClose: () -> Void
    @State var searchString = ""
    
    var body: some View {
        let searchBinding = Binding(
            get: { self.searchString },
            set: {
                setFriendSearchSettings()
                self.searchString = $0
                if !self.searchString.isEmpty {
                index.search(query: Query(self.searchString)) { result in
                    if case .success( _) = result {
                        
                        do {
                            let data = try result.get()
                            if data.nbHits == 0 {
                                self.friends.removeAll()
                                print("I have not found that username")
                            } else {
                                print("I have found that username")
                                for hit in data.hits {
                                    let jsonObj = hit.object.object()
                                    let jsonData = try? JSONSerialization.data(withJSONObject:jsonObj!)
                                    let decoder = JSONDecoder()
                                    do {
                                        
                                        let Friend = try decoder.decode(friend.self, from: jsonData!)
                                        if !self.friends.contains(Friend) {
                                            self.friends.append(Friend)
                                        }
                                        
                                    } catch {
                                        print(error)
                                        
                                    }
                                    
                                }
                            }
                                
                        } catch {
                            print("error")
                        }
                    } else {
                        print("Unsuccessful search")
                    }
                }
                print(self.searchString)
            }
        }
        )
        return VStack {
            GeometryReader { geometry in
            
            VStack {
                TextField("Search", text: searchBinding)
                //.padding(.leading, 20)
                    .frame(width: 180)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                if self.friends.isEmpty{
                    Text("Search for new friends")
                } else {
                    ForEach(self.friends, id: \.uid) { friendObj in
                        friendListItem(Friend: friendObj)
                    }
                }
                
            }
            
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            
            ZStack {
                Image(systemName: "xmark.circle.fill")
                    //.position(x: geometry.safeAreaInsets.leading, y: geometry.safeAreaInsets.top)
                .offset(x: -6, y: -6)
                
                }.onTapGesture {
                        self.hostClose()
                }
        }
        }.frame(width: 300, height: 400)
        .padding(20)
        .background(Color.white)
        .cornerRadius(8)
        
        
 
        
    }
}

struct challengeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var session: FirebaseSession
    @EnvironmentObject var Challenge: challengeObserve
    //var Challenge: challenge
    let close: () -> Void
    @State var showFriendSearch = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(Challenge.Challenge.name)
                }
                friendsList(add: {self.showFriendSearch.toggle()})
                Text("Get friends")
                    .onTapGesture {
                        self.session.getFriends()
                }
                HStack {
                    Text("Cancel")
                        .onTapGesture {
                            self.close()
                    }
                    Text("Send")
                }
            }
        .disabled(showFriendSearch)
            .blur(radius: self.showFriendSearch ?  3 : 0)
            .navigationBarTitle("No")
            .navigationBarHidden(true)
            if showFriendSearch {
                addFriendView(hostClose: {self.showFriendSearch.toggle()})
            }
        }.onAppear(perform: getFriends)
        
    }
    private func getFriends() {
        self.session.getFriends()
    }
}

struct friendChallengeItem: View {
    @EnvironmentObject var session: FirebaseSession
    @EnvironmentObject var Challenge: challengeObserve
    
    var Friend: friend
    @State var sent = false
    var body: some View {
        HStack {
            Text(Friend.username)
            Spacer()
            if sent {
                Text("Sent")
                .foregroundColor(Color.gray)
            } else {
                Text("Challenge")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        //let user = self.session.session
                        //print(user!)
                        let player1 = player(id: self.session.session!.uid, name: self.session.session!.username!)
                        let player2 = player(id: self.Friend.uid, name: self.Friend.username)
                        self.session.createChallenge(Challenge: challenge(id: UUID(), name: self.Challenge.Challenge.name, pending: true, receivePlayer: player2, sendPlayer: player1, Match: self.Challenge.Challenge.Match)) { (err, res) in
                            if res == true {
                                self.sent = true
                            }
                        }
                }
            }
            
        }
    }
}

struct friendsListHeader: View {
    var add: () -> Void
    var body: some View {
        HStack{
            EmptyView()
            Text("Friends")
            Image(systemName: "person.badge.plus")
                .onTapGesture {
                    self.add()
            }
        }
    }
}
struct friendsList: View {
    @EnvironmentObject var session: FirebaseSession
    var add: () -> Void
    var body: some View {
        VStack {
            Section(header: friendsListHeader(add: {self.add()})) {
                List {
                    if !(self.session.session?.friends.isEmpty)! {
                        ForEach((self.session.session?.friends)!, id: \.uid) { friendObj in
                            friendChallengeItem(Friend: friendObj)
                        }
                    }
                    //Text("Friends")
                }
            }
           
        }
        
    }
}

struct over1_5Goals: View {
    var matchData : match
    @State var showConfirm = false
    @State var showOptions = false
    @State var msg = ""
    @State var confirmChallenge = false
    @State var selection = 0
    
    var body: some View {
        Section(header: customHeader(hideShow: {self.showOptions.toggle()}, text: "Over 1.5 Goals", open: self.showOptions)) {
            if showOptions {
                VStack {
                    NavigationLink(destination: challengeView(close: {self.confirmChallenge = false}).environmentObject(challengeObserve(Challenge: challenge(id: UUID(), name: self.msg, pending: true, receivePlayer: player(id: "", name: ""), sendPlayer: player(id: "", name: ""), Match: self.matchData))), isActive: self.$confirmChallenge,
                    label: { EmptyView() })
                    HStack{
                        
                        
                        optionBox(clicked: {
                            self.msg = "Under 1.5 Goals"
                            self.showConfirm.toggle()
                        }, text: "Under")
                        
                        Divider()
                        
                        optionBox(clicked: {
                            self.msg = "Over 1.5 Goals"
                            self.showConfirm.toggle()
                        }, text: "Over")
                        
                    }
                    EmptyView()
                    
                }.animation(.none)
                    .alert(isPresented: $showConfirm) {
                        Alert(title: Text("Confirm"), message: Text("You think that this will happen in this match: \n\n" + self.msg), primaryButton: .destructive(Text("Confirm"), action: {
                            self.confirmChallenge = true
                        }), secondaryButton: .cancel())
                }
                
            }
            
        }
    }
}

func firstGoalscorerGet(matchData: match) -> firstGoalscorerView {
    return firstGoalscorerView(matchData: matchData)
}

struct firstGoalscorerView: View {
    var matchData : match
    @State var showOptions = false
    var body: some View {
        
        Section(header: customHeader(hideShow: {self.showOptions.toggle()}, text: "First Goalscorer", open: self.showOptions)) {
            if showOptions {
                VStack {
                    Text("First goalscorer options")
                }.animation(.none)
            }
        }
    }
}

struct challenges_Previews: PreviewProvider {
    static var previews: some View {
        //HomePage().environmentObject(FirebaseSession())
        //MasterView().environmentObject(FirebaseSession())
        //chooseChallengeView(matchData: testMatch)
        addFriendView {
            print("Friend")
        }
    }
}


