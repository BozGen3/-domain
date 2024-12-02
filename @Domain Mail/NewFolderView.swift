import SwiftUI

struct NewFolderView: View {
    @ObservedObject var mailViewModel: MailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var folderName = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Folder Name", text: $folderName)
            }
            .navigationTitle("New Folder")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        mailViewModel.createFolder(name: folderName)
                        dismiss()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
} 