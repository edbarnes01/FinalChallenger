//
//  UserPage.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 08/08/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import SwiftUI

struct UserPage: View {
    var logOut: () -> Void
    var body: some View {
        GeometryReader { geo in
            NavigationView {
            ZStack(alignment: .top) {
                
                VStack {
                    EmptyView()
                }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.green]), startPoint: .top, endPoint: .bottom).opacity(1))
                
                
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            self.logOut()
                        }) {
                            Text("Log Out")
                        }
                        .foregroundColor(Color.red)
                    .padding(10)
                        .background(Color.white)
                        Text("HI")
                        NavigationLink(destination: friendsPage()){
                            userFriends()
                                .accentColor(Color.black)
                        }
                    }.padding(.top, 80)
                }.edgesIgnoringSafeArea(.all)
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
    }
}

struct userFriends: View {
    var body: some View {
        Text("Friends")
            .padding(8)
            .frame(width: 140, height: 100)
            //.padding(.bottom, 30)
            .padding(10)
        .background(Color.gray)
            .cornerRadius(5)
        .shadow(radius: 8)
    }
}

struct userInfo: View {
    var body: some View {
        Text("this is points")
            .padding(8)
            .frame(width: 140, height: 100)
            //.padding(.bottom, 30)
            .padding(10)
        .background(Color.gray)
            .cornerRadius(5)
        .shadow(radius: 8)
    }
}
struct friendsPage: View {
    
    var body: some View {
        VStack {
            Text("Friends")
                .font(.largeTitle)
            Divider()
            Spacer()
            Text("List of friends")
            Spacer()
        }
    }
}
struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
        UserPage(logOut: {print("logout")})
        //friendsPage()
    }
}
