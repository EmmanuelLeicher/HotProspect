//
//  ProspectView.swift
//  HotProspects
//
//  Created by Emmanuel Leicher on 09/03/2022.
//

import SwiftUI
import CodeScanner
import UserNotifications



struct ProspectView: View {
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    
    
    enum FiltredTypes {
        case contacted, none, uncontacted
    }
    
    let filter : FiltredTypes
    
    var title: String {
        
        
        switch filter {
        case .none :
            return "Everyone"
            
        case .contacted :
            return "Contacted people"
        case .uncontacted :
            return "Uncontacted people"
            
            
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAdress = details[1]
            prospects.add(person)

        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    
    var filteredProspect: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter {
                $0.isContacted }
        case .uncontacted:
            return prospects.people.filter {
                !$0.isContacted
            }
        }
    }
    
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAdress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.second = 10
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }

    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspect) {
                    prospect in
                    VStack(alignment : .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAdress)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            }
                        label: {
                            Label("Mark contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                        }.tint(.blue)
                        }
                        else {
                            Button {
                                prospects.toggle(prospect)
                            }
                        label: {
                            Label("Mark uncontacted", systemImage: "person.crop.circle.badge.xmark")
                        }
                        .tint(.green)
                        }
                        Button {
                            addNotification(for: prospect)
                        } label: {
                            Label("Remind Me", systemImage: "bell")
                        }
                        .tint(.orange)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    isShowingScanner = true
                    
                } label: {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            }.sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            }
        }
    }
}

struct ProspectView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectView(filter: .none)
            .environmentObject(Prospects())
    }
}
