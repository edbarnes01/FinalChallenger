//
//  HomePage.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 11/07/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import SwiftUI

enum JoinLeagueError: Error {
    case leagueNotFound
}
    
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
    static let screenWidthN = UIScreen.main.nativeBounds.width
    static let screenHeightN = UIScreen.main.nativeBounds.height
    static let screen = UIScreen.main.fixedCoordinateSpace.bounds
}



struct primaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .foregroundColor(Color.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color.init(UIColor.init(red: 108 / 255, green: 136 / 255, blue: 148 / 255, alpha: 1)), Color.init(UIColor.init(red: 126 / 255, green: 156 / 255, blue: 168 / 255, alpha: 1))]), startPoint: .center, endPoint: .bottom))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 0.2)
            )
            .shadow(color: Color.white, radius: 2, x: 0, y: 0)
            .font(.title)
    }
}


struct HomePage: View {
    @State var inLeague = false
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        VStack {
            MasterView().environmentObject(session)
        }
       
    }
}


struct MasterView: View {
    @EnvironmentObject var session: FirebaseSession
    @State var tabSelection = 2
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .some(UIColor.init(red: 108 / 255, green: 136 / 255, blue: 148 / 255, alpha: 1))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if self.tabSelection != 10 {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                        .onTapGesture {
                                self.tabSelection = 10
                        }
                        .padding(.trailing, 20)
                        
                }.frame(width: UIScreen.screenWidth, height: 60)
            
            } else {
                Rectangle()
                .background(Color.white)
                .frame(width: UIScreen.screenWidth, height: 60)
            }
            
            
            //Spacer()
            VStack {
                if self.tabSelection == 0 {
                    Text("query test")
                        .onTapGesture {
                            self.session.queryTest()
                    }
                } else if self.tabSelection == 1 {
                    actualLeaguesView()
                } else if self.tabSelection == 2 {
                    challengeSingle().environmentObject(session)
                } else if self.tabSelection == 10 {
                    UserPage(logOut: {self.session.logOut()})
                }
            }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight - 160)
                .animation(.linear(duration: 0.1))
            
            VStack {
                Picker("", selection: self.$tabSelection) {
                    Text("Home")
                    .tag(0)
                    Text("Leagues")
                    .tag(1)
                    Text("Challenges")
                    .tag(2)
                }.pickerStyle(SegmentedPickerStyle())
            }
            .frame(width: 300, height: 50)
            .background(Color.white)
            .cornerRadius(8)
            
        }.edgesIgnoringSafeArea(.vertical)
    }
}

struct challengeSingle: View {
    @EnvironmentObject var session: FirebaseSession
    
    @State var tabSelection = 0
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .some(UIColor.init(red: 108 / 255, green: 136 / 255, blue: 148 / 255, alpha: 1))
        
        UISegmentedControl.appearance().tintColor = .some(UIColor.white)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {
                    VStack {
                        
                        HStack {
                            Picker("", selection: self.$tabSelection) {
                                Text("Pending")
                                .tag(0)
                                Text("Active")
                                .tag(1)

                            }.pickerStyle(SegmentedPickerStyle())
                                .frame(width: 300)
                            .padding(2)
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            Image(systemName: "plus")
                        }
                            VStack {
                                if self.tabSelection == 0 {
                                    pendingChallenges()
                                } else if self.tabSelection == 1 {
                                    Text("Active")
                                    newChallengeSet()
                                }
                                
                                    
                            }.background(Color.white)
                            Spacer()
                        
                        
                    }
                    .padding(.top, 30)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.green]), startPoint: .top, endPoint: .bottom).opacity(1))
            }.navigationBarTitle(Text("Title"), displayMode: .inline)
        }
    }
}

struct pendingChallengeItem: View {
    var Challenge: challenge
    var playerID: String
    var accept: () -> Void
    @State var accepted : Bool
    var body: some View {
        HStack {
            VStack {
                Text("\(Challenge.Match.teams[0].name) v \(Challenge.Match.teams[1].name)")
                Divider()
                Text(String(Challenge.name))
            }
            
            if Challenge.pending && Challenge.receivePlayer.id == playerID {
                Spacer()
                Text(Challenge.sendPlayer.name)
                Spacer()
                if self.accepted{
                    Button(action: {
                        print("Decline")
                    }) {
                        Text("Accepted")
                    }.disabled(true)
                } else {
                    Button(action: {
                        print("Accept")
                        self.accepted = true
                        self.accept()
                        
                    }) {
                        Text("Accept")
                    }
                    Button(action: {
                        print("Decline")
                    }) {
                        Text("Decline")
                    }
                }
                
            } else {
                Spacer()
                Text(Challenge.receivePlayer.name)
                Spacer()
                Button(action: {
                    print("Sent")
                }) {
                    Text("Sent")
                }.disabled(true)
            }
        }.background(Color.white)
        .padding(.vertical, 20)
        
    }
}

struct pendingChallenges: View {
    @EnvironmentObject var session: FirebaseSession
    init() {
        
    }
    var body: some View {
        VStack{
            if !self.session.pendingChallenges.isEmpty {
                ForEach(self.session.pendingChallenges, id: \.id) { Challenge in
                    pendingChallengeItem(Challenge: Challenge, playerID: self.session.session!.uid, accept: {self.session.acceptChallenge(Challenge: Challenge)}, accepted: false)
                        
                }
            }
            
        }.onAppear(perform: getChallenges)
    }
    private func getChallenges() {
        self.session.challengesListen()
    }
}

struct newChallengeSet: View {
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text("Refresh")
                    .onTapGesture {
                        self.session.matchPull()
                        for i in self.session.matchDays {
                            print(i)
                        }
                }
                VStack {
                    if !self.session.matchDays.isEmpty {
                        List {
                            ForEach(self.session.matchDays , id: \.id) {matchday in
                                matchDayView(matchday: matchday)
                                
                            }
                            
                        }.listStyle(GroupedListStyle())
                        
                    } else {
                        Text("Join a league!")
                    }
                        
                }
            }
                
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

struct customHeader: View {
    let hideShow: () -> Void
    var text: String
    var open: Bool
    var body: some View {
        HStack{
            Text(text)
            if open {
                Image(systemName: "chevron.down")
            } else {
                Image(systemName: "chevron.right")
            }
            Spacer()
        }.onTapGesture {
            self.hideShow()
        }
        
    }
}

struct matchDayView: View {
    var matchday: matchDay
    @State var showMatches = true
    
    var body: some View {
        
        Section(header: customHeader(hideShow: {self.showMatches.toggle()}, text: formatDate(strDate: matchday.id), open: self.showMatches)) {
            if showMatches {
                VStack {
                    if !self.matchday.fixtures!.isEmpty {
                        ForEach(self.matchday.fixtures! , id: \.id) {match in
                            
                            matchChallengeView(matchData: match)
                        }
                    }
                }.animation(.none)
            }
        }
    }
}

func formatTeamName(name: String) -> String {
    var newStr = name.replacingOccurrences(of: "FC", with: "")
    newStr = newStr.replacingOccurrences(of: "United", with: "")
    newStr = newStr.replacingOccurrences(of: "City", with: "")
    return newStr
}



struct matchChallengeView: View {
    var matchData: match
    @State private var action: Int? = 0
    
    var body: some View {
        VStack {
            NavigationLink(destination: chooseChallengeView(matchData: matchData), tag: 1, selection: $action) {
                EmptyView()
            }
            HStack {
                VStack(alignment: .leading){
                    Text(formatTeamName(name: matchData.teams[0].name))
                    Text(formatTeamName(name: matchData.teams[1].name))
                }
                Spacer()
                
                    Text("Challenge")
                        .padding(10)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 0.2)
                        )
                        .shadow(color: Color.white, radius: 2, x: 0, y: 0)
                        .onTapGesture {
                            //print("challenge")
                            self.action = 1
                    }
                
                
            }
            Divider()
        }
    }
}


    



struct activeChallenges: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Text("active challenges")
            }
                
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //HomePage().environmentObject(FirebaseSession())
        MasterView().environmentObject(FirebaseSession())
        //chooseChallengeView(matchData: testMatch)
    }
}
