//
//  Prospect.swift
//  HotProspects
//
//  Created by Edwin Przeźwiecki Jr. on 17/02/2023.
//

import SwiftUI

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    let saveKey = "SavedData"
    /// Challenge 2:
    let savePath = FileManager.documentsDirectory.appendingPathExtension("HotProspects")
    
//    init() {
//        if let data = UserDefaults.standard.data(forKey: saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                people = decoded
//                return
//            }
//        }
//
//        people = []
//    }
    
    /// Challenge 2:
    init() {
        do {
            let data = try Data(contentsOf: savePath)
            people = try JSONDecoder().decode([Prospect].self, from: data)
            return
        } catch {
            print(error.localizedDescription)
        }
        
        people = []
    }
    
//    private func save() {
//        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: saveKey)
//        }
//    }
    
    /// Challenge 2:
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            do {
                try encoded.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}

/// Challenge 3:
class Prospect: Identifiable, Codable, Comparable {
    
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    
    static func <(lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.name < rhs.name
    }
    
    static func ==(lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.id == rhs.id
    }
}
