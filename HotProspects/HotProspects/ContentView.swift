//
//  ContentView.swift
//  HotProspects
//
//  Created by Emmanuel Leicher on 27/02/2022.
//

import SwiftUI





struct ContentView: View {
    @StateObject var prospects = Prospects()

    
    var body: some View {
        
        TabView{
            ProspectView(filter: .none)
                .tabItem
            {
                Label("Everyone", systemImage : "person.3")
                
            }
            
            ProspectView(filter: .contacted)
                .tabItem
            {
                Label("contacted", systemImage : "checkmark.circle")
            }
            ProspectView(filter: .uncontacted)
                .tabItem{
                    Label("notContacted", systemImage : "questionmark.diamond")
                    
                }
            MeView()
                .tabItem{
                    Label("notContacted", systemImage : "questionmark.diamond")
                    
                }
        }
        .environmentObject(prospects)
    }
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
