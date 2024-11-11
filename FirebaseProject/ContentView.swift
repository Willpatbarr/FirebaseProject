//
//  ContentView.swift
//  FirebaseProject
//
//  Created by William Barr on 10/23/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

struct User: Identifiable {
    var id: String
    var name: String
    var age: Int
}


struct ContentView: View {
        @State private var users: [User] = []
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: FormScreen()) {
                        Text("Add User")
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                    Button(action: clearData) {
                        Text("Clear Data")
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                }
                
                Text("Items In Database")
                    .font(.title)
                
                List(users) { user in
                    VStack(alignment: .leading) {
                        Text("name: \(user.name)")
                        Text("Age: \(user.age)")
                    }
                }
                .onAppear(perform: fetchData)
            }
        }
    }
    func clearData() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("error fetching data: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for document in snapshot.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("error deleting document: \(error)")
                    } else {
                        print("document \(document.documentID) deleted successfully")
                    }
                }
            }
            self.users.removeAll()
        }
    }
    
    func fetchData() {
        print("fetch started")
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("error fetching data: \(error)")
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? ""
                    let age = data["age"] as? Int ?? 0
                    let user = User(id: id, name: name, age: age)
                    self.users.append(user)
                }
            }
        }
    }
    
    
    
    
}

struct FormScreen: View {
    @State private var name: String = ""
    @State private var age: String = ""
    var body: some View {
        VStack {
            
            Text("enter your details here")
            
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Age", text: $age)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button(action: saveData) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    func saveData() {
        let db = Firestore.firestore()
        db.collection("users").addDocument(data: [
            "name": name,
            "age": Int(age) ?? 0
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("document added with ID \(db.collection("users").document().documentID)")
            }
        }
        name = ""
        age = ""
    }
}







#Preview {
    ContentView()
}
