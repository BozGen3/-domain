import SwiftUI

struct MailboxView: View {
    @StateObject private var mailViewModel = MailViewModel()
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    @State private var showingComposeSheet = false
    @State private var showingNewFolderSheet = false
    
    var body: some View {
        NavigationView {
            #if os(iOS)
            sidebar
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button(action: { showingComposeSheet = true }) {
                            Image(systemName: "square.and.pencil")
                        }
                        
                        Menu {
                            Button(action: { showingNewFolderSheet = true }) {
                                Label("New Folder", systemImage: "folder.badge.plus")
                            }
                            
                            Button(role: .destructive, action: signOut) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            #else
            HSplitView {
                sidebar
                    .frame(minWidth: 200, maxWidth: .infinity)
                EmptyView()
            }
            .toolbar {
                ToolbarItemGroup {
                    Button(action: { showingComposeSheet = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    Button(action: { showingNewFolderSheet = true }) {
                        Image(systemName: "folder.badge.plus")
                    }
                    
                    Button(role: .destructive, action: signOut) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showingComposeSheet) {
            ComposeEmailView(mailViewModel: mailViewModel)
        }
        .sheet(isPresented: $showingNewFolderSheet) {
            NewFolderView(mailViewModel: mailViewModel)
        }
    }
    
    var sidebar: some View {
        List {
            Section("Mailboxes") {
                ForEach(MailboxType.allCases) { mailbox in
                    NavigationLink(destination: EmailListView(mailbox: mailbox)) {
                        Label(mailbox.rawValue, systemImage: mailbox.icon)
                    }
                }
            }
            
            Section("Custom Folders") {
                ForEach(mailViewModel.customFolders) { folder in
                    NavigationLink(destination: EmailListView(customFolder: folder)) {
                        Label(folder.name, systemImage: "folder")
                    }
                    .contextMenu {
                        Button(role: .destructive, action: { 
                            mailViewModel.deleteFolder(folder) 
                        }) {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    private func signOut() {
        mailViewModel.signOut()
        isFirstLaunch = true
    }
}

enum MailboxType: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case sent = "Sent"
    case drafts = "Drafts"
    case trash = "Trash"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return "tray"
        case .sent: return "paperplane"
        case .drafts: return "doc"
        case .trash: return "trash"
        }
    }
} 