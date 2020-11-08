//
//  LeaguePage.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 12/07/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import SwiftUI

struct joinLeague: View {
    @EnvironmentObject var session: FirebaseSession
    @State var leaguePin = ""
    @State var alert = false
    @State var msg = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text("Ask the host of the league you're trying to join to send you the pin code in order to join the league. Once you have it, submit it below to join !")
                    .padding(8)
                    .frame(width: 290)
                    .padding(10)
                
                TextField("League pin", text: $leaguePin)
                .background(Color.white)
                .padding(10)
                .background(Color.white)
                .cornerRadius(6)
                .frame(width: 200, height: 10)
                .padding(10)
                    .shadow(radius: 10)
                
                Button(action: {
                    if !self.leaguePin.isEmpty {
                        self.session.joinLeague(pin: self.leaguePin) { (error, des)  in
                            if (error != nil) {
                                print("Error joining league")
                                self.msg = des
                                self.alert.toggle()
                            } else {
                                print("Successfull")
                            }
                        }
                    } else {
                        self.msg = "Enter a pin to join a league!"
                        self.alert.toggle()
                    }
                    
                }) {
                    Text("Join")
                }
                
                .modifier(primaryButton())
                .padding(20)
                }
            
                
        .background(Color.gray)
        .cornerRadius(5)
            .shadow(radius: 8)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Okay")))
            }
        }
    }
}

struct leagueCreated: View {
    var pin: String
    let hostClose: () -> Void
    
    var body: some View {
        VStack {
            Text("League created successfully!")
                .padding(8)
                .frame(width: 290)
            Text("Pin to join league:")
                .padding(8)
                .frame(width: 290)
            Text(self.pin)
                .font(.largeTitle)
                .padding(8)
            Button(action: {
                self.hostClose()
            }) {
                Text("Done")
            }.modifier(primaryButton())
        }
    }
}

struct createLeague: View {
    let hostClose: () -> Void
    @State var leagueCreatedShow = false
    @State var leagueName = ""
    @State var leaguePin = ""
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        VStack {
            if leaguePin == "" {
                Text("League Name")
                VStack {
                    TextField("", text: self.$leagueName)
                        .frame(height: 40)
                        .padding(.leading, 10)
                        .background(Color.white)
                }
                    .foregroundColor(Color.black)
                        .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                        .shadow(radius: 2)
                .padding()
                HStack {
                    Spacer()
                    
                    Text("Cancel")
                    .onTapGesture {
                       self.hostClose()
                    }
                    .foregroundColor(Color.white)
                    .padding(10)
                    .background(Color.red)
                    .cornerRadius(8)
                    
                    Text("Create")
                    .onTapGesture {
                        self.session.createLeague(name: self.leagueName) { (error, pin)  in
                            if (error != nil) {
                                print("there is an error")
                            } else {
                                self.leaguePin = pin
                            }
                        }
                    }
                
                    .foregroundColor(Color.white)
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                    Spacer()
                }
            } else {
                leagueCreated(pin: leaguePin, hostClose: hostClose)
            }
            
        }
        .frame(width: UIScreen.screenWidth - 20, height: 700)
        .background(Color.white)
    }
}

struct hostLeague: View {
    
    @State var showCreate = false
    var body: some View {
        ZStack {
            VStack {
                Text("Host your own league, invite your friends and set challenges for them!")
                            .padding(8)
                            .frame(width: 290)
                            .padding(10)
                        
                        Button(action: {
                            self.showCreate.toggle()
                        }) {
                            Text("Host")
                        }
                        
                        .modifier(primaryButton())
                        .padding(20)
                }
                .background(Color.gray)
                .cornerRadius(5)
            .shadow(radius: 8)
            
            if self.showCreate {
                createLeague(hostClose: {self.showCreate.toggle()})
                    
            }
        }
        
    }
}

struct leagueActions: View {
    
    @State var league = false
    @State private var tabSelection = 1
    
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                VStack {
                    EmptyView()
                }
                
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.green]), startPoint: .top, endPoint: .bottom).opacity(1))
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    if !self.league {
                        VStack {
                            Picker("", selection: self.$tabSelection) {
                                Text("Host")
                                .tag(0)
                                Text("Join")
                                .tag(1)
                            }.pickerStyle(SegmentedPickerStyle())
                                .frame(width: 300)
                            .padding(2)
                                .background(Color.white)
                            .cornerRadius(8)
                            VStack {
                                if self.tabSelection == 0 {
                                    hostLeague()
                                    .padding(.top, 20)
                                } else if self.tabSelection == 1 {
                                    joinLeague()
                                        .padding(.top, 20)
                                }
                            }
                        }
                    } else {
                        Text("hello")
                    }
                    Spacer()
                }.padding(.top, 20)
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct leagueRow: View {
    var leagueData : league
    
    var body: some View {
        HStack{
            Text(leagueData.name)
            .padding(.leading, 15)
            Spacer()
            Image(systemName: "arrow.right")
                .padding(.trailing, 10)
            Divider()
        }.frame(height: 50)
            .background(Color.white.opacity(0.9))
            .onTapGesture {
                print(self.leagueData.name + "tapped")
            }
    }
    
}

struct leaguesView: View {
    @EnvironmentObject var session: FirebaseSession
    var testLeagues = returnTestLeagues()
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .some(UIColor.init(red: 108 / 255, green: 136 / 255, blue: 148 / 255, alpha: 1))
        UISegmentedControl.appearance().tintColor = .some(UIColor.white)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                VStack {
                    EmptyView()
                }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.green]), startPoint: .top, endPoint: .bottom).opacity(1))
                
                VStack {
                    if !self.session.leagueData.isEmpty {
                        ForEach(self.session.leagueData , id: \.uid) {item in
                            leagueRow(leagueData: item)
                        }
                    } else {
                        Text("Join a league!")
                    }
                        
                }.background(Color.white)
                .padding(.top, 80)
                
            }.edgesIgnoringSafeArea(.all)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct actualLeaguesView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                VStack {
                    EmptyView()
                }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.green]), startPoint: .top, endPoint: .bottom).opacity(1))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("HI")
                }.padding(.top, 80)
                
            }.edgesIgnoringSafeArea(.all)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}


struct LeaguePage_Previews: PreviewProvider {
    static var previews: some View {
        leagueActions()
    }
}
