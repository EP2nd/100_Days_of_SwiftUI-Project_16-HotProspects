//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Edwin Przeźwiecki Jr. on 17/02/2023.
//

import CodeScanner
import SwiftUI
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

struct ProspectsView: View {
    
    @State private var isShowingScanner = false
    /// Challenge 3:
    @State private var showingConfirmation = false
    @AppStorage("sorting") private var isSortedAlphabetically = false
    
    /// Challenge 3:
    @State private var exampleNames = ["Andy", "Steve", "Peter", "John", "Edward", "William"]
    
    let filter: FilterType
    
    var title: String {
        
        switch filter {
            
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        
        switch filter {
            
        /// Challenge 3:
        case .none:
            return isSortedAlphabetically ? prospects.people.sorted() : prospects.people.reversed()
        case .contacted:
            return isSortedAlphabetically ? prospects.people.filter { $0.isContacted }.sorted() : prospects.people.filter { $0.isContacted }.reversed()
        case .uncontacted:
            return isSortedAlphabetically ? prospects.people.filter { !$0.isContacted }.sorted() : prospects.people.filter { !$0.isContacted }.reversed()
        }
    }
    
    @EnvironmentObject var prospects: Prospects
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    /// Challenge 1:
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Uncontaced", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(.blue)
                            } else {
                                Button {
                                    prospects.toggle(prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                                }
                                .tint(.green)
                                
                                Button {
                                    addNotification(for: prospect)
                                } label: {
                                    Label("Remind Me", systemImage: "bell")
                                }
                                .tint(.orange)
                            }
                        }
                        
                        /// Challenge 1:
                        Spacer()
                        
                        if filter == .none {
                            Label("", systemImage: prospect.isContacted ? "checkmark.circle" : "questionmark.diamond")
                        }
                    }
                }
            }
                .navigationTitle(title)
                .toolbar {
                    /// Challenge 3:
                    Button {
                        showingConfirmation = true
                    } label: {
                        Label("Sort", systemImage: "slider.horizontal.3")
                    }
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                /// Challenge 3:
                .sheet(isPresented: $isShowingScanner) {
                    if let randomName = exampleNames.randomElement() {
                        CodeScannerView(codeTypes: [.qr], simulatedData: "\(randomName)\ndonotrespond@whydoyoucare.com", completion: handleScan)
                    }
                }
                /// Challenge 3:
                .confirmationDialog("Sorting options", isPresented: $showingConfirmation) {
                    Button("Name") { isSortedAlphabetically = true }
                    Button("Most recent") { isSortedAlphabetically = false }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Sort by:")
                }
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
            person.emailAddress = details[1]
            
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
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
                        print("D'oh.")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
