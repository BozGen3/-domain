import SwiftUI

struct EmailListView: View {
    let mailbox: MailboxType?
    let customFolder: CustomFolder?
    @StateObject private var viewModel = MailViewModel()
    @State private var selectedEmails: Set<String> = []
    @State private var showingMoveSheet = false
    
    var body: some View {
        List(viewModel.emails, selection: $selectedEmails) { email in
            EmailRow(email: email)
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteEmail(email)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        showingMoveSheet = true
                    } label: {
                        Label("Move", systemImage: "folder")
                    }
                    .tint(.blue)
                }
        }
        .navigationTitle(customFolder?.name ?? mailbox?.rawValue ?? "")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    // Compose new email
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingMoveSheet) {
            MoveToPicker(viewModel: viewModel, selectedEmails: selectedEmails)
        }
    }
    
    private func deleteEmail(_ email: Email) {
        Task {
            try? await viewModel.deleteEmail(email)
        }
    }
}

struct MoveToPicker: View {
    @ObservedObject var viewModel: MailViewModel
    let selectedEmails: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(viewModel.customFolders) { folder in
                Button {
                    moveEmails(to: folder)
                } label: {
                    Label(folder.name, systemImage: "folder")
                }
            }
            .navigationTitle("Move to Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func moveEmails(to folder: CustomFolder) {
        Task {
            for emailId in selectedEmails {
                if let email = viewModel.emails.first(where: { $0.id == emailId }) {
                    try? await viewModel.moveEmail(email, to: folder)
                }
            }
            dismiss()
        }
    }
}

struct EmailRow: View {
    let email: Email
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(email.sender)
                    .font(.headline)
                Spacer()
                Text(email.date, style: .date)
                    .font(.caption)
            }
            
            Text(email.subject)
                .font(.subheadline)
            
            Text(email.preview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
} 