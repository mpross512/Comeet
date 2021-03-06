//
//  UserAuthenticator.swift
//  Comeet
//
//  Created by Michael Ross on 7/10/20.
//  Copyright © 2020 Ice Cream Loaf. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class UserHandler : ObservableObject {
    
    static private var singleton: UserHandler?
    
    @Published private var signedIn: Bool = false
    
    private var uid: String
    
    private var profilePicReference: StorageReference
    private var imageURL: URL?
    
    public var user: User
    
    init(_ signedIn: Bool) {
        self.signedIn = signedIn
        uid = Auth.auth().currentUser?.uid ?? "default"
        profilePicReference = Constants.Database.profilePicsRef.child("\(uid).jpeg")
        user = User()
        refreshUserData()
    }
    
    static func getUserHandler() -> UserHandler {
        
        if singleton == nil {
            singleton = UserHandler(Auth.auth().currentUser != nil)
        }
        return singleton!
        
    }
    
    func refreshUserData() {
        refresh()
        Firestore.firestore().collection("Users").document(uid).getDocument { (document, error) in
            if let document = document {
                
                let decoder = JSONDecoder()

                let data = document.data()
                 //Serialize the Dictionary into a JSON Data representation, then decode it using the Decoder().
                 if let data = try?  JSONSerialization.data(withJSONObject: data!, options: []) {
                    do {
                        self.user = try decoder.decode(User.self, from: data)
                    } catch {
                        print(error)
                    }
                }
            } else {
                print("Firestore Error: \(error!)")
            }
        }
        
        self.user.uid = uid
    }
    
    func refresh() {
        signedIn = Auth.auth().currentUser != nil
        uid = Auth.auth().currentUser?.uid ?? "default"
        profilePicReference = Constants.Database.profilePicsRef.child("\(uid).jpeg")
        profilePicReference.downloadURL { (url, error) in
            if let e = error {
                print(e)
            } else {
                self.imageURL = url!
            }
        }
        
        print("Refreshing.... User ID is \(Auth.auth().currentUser?.uid ?? "nil")")
    }
    
    func isSignedIn() -> Bool {
        return signedIn
    }
    
    func getImageURL() -> URL? {
        profilePicReference = Constants.Database.profilePicsRef.child("\(uid).jpeg")
        if let imageURL = imageURL {
            print("Returned URL: \(imageURL)")
        }
        return imageURL
    }
    
    func getUID() -> String {
        return uid
    }
    
}
