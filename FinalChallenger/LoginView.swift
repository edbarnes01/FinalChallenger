//
//  LoginView.swift
//  FinalChallenger
//
//  Created by Ed Barnes on 11/07/2020.
//  Copyright © 2020 Ed Barnes. All rights reserved.
//

import SwiftUI
import AlgoliaSearchClient

enum UIDSearch: Error {
    case userNotFound
}

let strictSettings = Settings()
.set(\.searchableAttributes, to: ["username"])
.set(\.typoTolerance, to: false)

let uidSearchSettings = Settings()
.set(\.searchableAttributes, to: ["objectID"])
.set(\.typoTolerance, to: false)

let friendSearchSettings = Settings()
.set(\.searchableAttributes, to: ["username"])
.set(\.typoTolerance, to: true)

func setStrictSettings() {
    index.setSettings(strictSettings) { result in
      switch result {
      case .failure(let error):
        print("Error when applying settings: \(error)")
      case .success:
        print("Success")
      }
    }
}

func setFriendSearchSettings() {
    index.setSettings(friendSearchSettings) { result in
      switch result {
      case .failure(let error):
        print("Error when applying settings: \(error)")
      case .success:
        print("Success")
      }
    }
}

func setUidSearchSettings() {
    index.setSettings(uidSearchSettings) { result in
      switch result {
      case .failure(let error):
        print("Error when applying settings: \(error)")
      case .success:
        print("Success")
      }
    }
}


func searchUID(uid: String, completion: @escaping (Error?, Bool) -> Void) {
    setUidSearchSettings()
    
    index.search(query: Query(uid)) { result in
        if case .success( _) = result {
        print("Successful search")
            do {
                let data = try result.get()
                if data.nbHits == 0 {
                    
                    completion(UIDSearch.userNotFound, false)
                } else {
                    completion(nil, true)
                }
                    
            } catch {
                print("error")
            }
        } else {
            print("Unsuccessful search")
        }
    }
}

struct LoginView: View {
    @State var msg = ""
    @State var alert = false
    @State var email = ""
    @State private var password = ""
    @State var signup = false
    @ObservedObject var session: FirebaseSession
    
    var body: some View {
        ZStack {
            VStack {
                Text("Challenger!")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                    .padding(.top, 60)
                
                Text("Login")
                    .font(.largeTitle)
                    .padding(.vertical, 30)
                HStack {
                    Spacer()
                    
                    VStack {
                        
                        VStack {
                            TextField("Email", text: $email)
                                .frame(height: 40)
                                .padding(.leading, 10)
                                .background(Color.white)
                        }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                        .disableAutocorrection(true)
                            .foregroundColor(Color.black)
                                .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                                .shadow(radius: 2)
                        .padding()
                        
                        VStack {
                            SecureField("Password", text: $password)
                                .frame(height: 40)
                                .padding(.leading, 10)
                                .background(Color.white)
                        }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                        .disableAutocorrection(true)
                        .foregroundColor(Color.black)
                            .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                            .shadow(radius: 2)
                        .padding()
                        
                        
                        VStack {
                            Text("fill")
                                .onTapGesture {
                                    self.email = returnExampleUser("email", 0)
                                    self.password = returnExampleUser("password", 0)
                            }
                            Text("fill 2")
                                .onTapGesture {
                                    self.email = returnExampleUser("email", 1)
                                    self.password = returnExampleUser("password", 1)
                            }
                            Button(action: {
                                print("Login")
                                self.session.logIn(email: self.email, password: self.password) { (res, err) in
                                    if err != nil {
                                        self.msg = err!.localizedDescription
                                        self.alert.toggle()
                                        
                                    } else {
                                        //self.session.setDisplay(uid: (self.session.session?.uid)!, displayName: self.userName)
                                    }
                                }
                            }) {
                                Text("Login")
                            }
                            .modifier(primaryButton())
                            
                            Text("Create account")
                                .onTapGesture {
                                    self.signup.toggle()
                            }.padding(.top, 16)
                                .font(.system(size: 12))
                            
                            Text("Forgot password?")
                            .onTapGesture {
                                    print("forgot password")
                            }.padding(.top, 16)
                            .font(.system(size: 12))
        
                        }.padding(.top, 30)
                    }.frame(width: 280)
                    Spacer()
                }
                Spacer()
            }.frame(width: 300, height: 630)
            .background(Color.gray)
            .cornerRadius(20)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Okay")))
            }
            if self.signup {
                signUp(hostClose: {self.signup.toggle()}, session: self.session)
            }
        }
    }
}

struct signUp: View {
    let hostClose: () -> Void
    @State var msg = ""
    @State var email = ""
    @State var emailCheck = ""
    @State private var password = ""
    @State private var passwordCheck = ""
    @State private var username = ""
    @State var alert = false
    @State var signedUp = false
    @State var usernameAllowed = false
    @ObservedObject var session: FirebaseSession
    
    var body: some View {
        let usernameBind = Binding<String>(
            get: {
                self.username
        }, set: {
            setStrictSettings()
            self.username = $0
            index.search(query: Query(self.username)) { result in
                if case .success( _) = result {
                print("Successful search")
                    do {
                        let data = try result.get()
                        if data.nbHits == 0 {
                            
                            print("I have not found that username")
                            self.usernameAllowed = true
                        } else {
                            print("I have found that username")
                            self.usernameAllowed = false
                        }
                            
                    } catch {
                        print("error")
                    }
                } else {
                    print("Unsuccessful search")
                }
            }
            print(self.username)
        }
        )
        
        return ZStack {
            VStack{
                VStack {
                    TextField("Email", text: $email)
                        .frame(width: 300, height: 40)
                        .padding(.leading, 10)
                        .background(Color.white)
                }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                .disableAutocorrection(true)
                .foregroundColor(Color.black)
                    .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                    .shadow(radius: 2)
                .padding(.bottom, 10)
                
                VStack {
                    TextField("Confirm Email", text: $emailCheck)
                        .frame(width: 300, height: 40)
                        .padding(.leading, 10)
                        .background(Color.white)
                }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                .disableAutocorrection(true)
                .foregroundColor(Color.black)
                    .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.bottom, 30)
                
                VStack {
                    SecureField("Password", text: $password)
                        .frame(width: 300, height: 40)
                        .padding(.leading, 10)
                        .background(Color.white)
                }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                .disableAutocorrection(true)
                .foregroundColor(Color.black)
                    .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.bottom, 10)
                
                VStack {
                    SecureField("Confirm Password", text: $passwordCheck)
                        .frame(width: 300, height: 40)
                        .padding(.leading, 10)
                        .background(Color.white)
                }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                .disableAutocorrection(true)
                .foregroundColor(Color.black)
                    .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                    .shadow(radius: 2)
                
                HStack {
                    VStack {
                        TextField("Username", text: usernameBind)
                            .frame(width: 260, height: 40)
                            .padding(.leading, 10)
                            .background(Color.white)
                    }.autocapitalization(UITextAutocapitalizationType(rawValue: 0)!)
                    .disableAutocorrection(true)
                    .foregroundColor(Color.black)
                        .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                        .shadow(radius: 2)
                    
                    if self.username.count > 0 {
                        if self.usernameAllowed == true {
                            Image(systemName: "checkmark.circle.fill")
                                .frame(width: 30, height: 40)
                                .foregroundColor(Color.green)
                        } else if self.usernameAllowed == false {
                            Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.red)
                            .frame(width: 30, height: 40)
                        }
                    } else {
                        Spacer()
                    }
                }
                
                HStack {
                    Text("fill")
                        .onTapGesture {
                            self.email = returnExampleUser("email", 1)
                            self.password = returnExampleUser("password", 1)
                            self.emailCheck = returnExampleUser("email", 1)
                            self.passwordCheck = returnExampleUser("password", 1)
                    }
                    Text("Sign up")
                        .onTapGesture {
                           
                            if self.email == self.emailCheck {
                                if self.password == self.passwordCheck {
                                    
                                            self.session.signUp(email: self.email, password: self.password) { (res, err) in
                                                if err != nil {
                                                    self.msg = err!.localizedDescription
                                                    self.alert.toggle()
                                                } else {
                                                    self.session.updateUsername(username: self.username)
                                                    self.session.createPlayerData(uid: res!.user.uid, username: self.username)
                                                    print("Signed up")
                                        }
                                    }
                                    
                                } else {
                                    self.msg = "Passwords do not match"
                                    self.alert = true
                                }
                            } else {
                                self.msg = "Emails do not match"
                                self.alert = true
                            }
                    }
                    Text("Cancel")
                        .onTapGesture {
                            self.hostClose()
                    }
                }
                
            }.frame(width: 300, height: 630)
                .background(Color.white)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Okay")))
            }
            if self.signedUp {
                VStack {
                    Text("You have succesffuly created your account!")
                    Text("Login")
                        .onTapGesture {
                            self.hostClose()
                    }
                }
            }
        }
    }
}

/*struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView( session: FirebaseSession())
    }
}*/
