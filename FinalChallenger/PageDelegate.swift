//
//  PageDelegate.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 15/07/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import SwiftUI

struct PageDelegate: View {
    @ObservedObject var session: FirebaseSession
    
    var body: some View {
        //Text("Hello, World!")
        VStack {
            if session.session != nil {
                HomePage().environmentObject(session)
            } else {
                LoginView(session: session)
            }
        }
        
    
    }
}

struct PageDelegate_Previews: PreviewProvider {
    static var previews: some View {
        PageDelegate(session: FirebaseSession())
    }
}
