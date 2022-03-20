//
//  Prospect.swift
//  HotProspects
//
//  Created by Emmanuel Leicher on 10/03/2022.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAdress = ""
    fileprivate(set) var isContacted = false

}


@MainActor class Prospects: ObservableObject {
    //  if we add or remove items from that array a change notification will be sent out
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"


    init() {
        
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
            
            
        }
        
        people = []
        
        
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    
    
    
    // allow to send notification when the var isContacted change
    func toggle(_ prospect : Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
