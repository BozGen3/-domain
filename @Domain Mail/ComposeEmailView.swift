import SwiftUI

struct ComposeEmailView: View {
    @ObservedObject var mailViewModel: MailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipientsText = ""
    @State private var subjectText = ""
    @State private var messageBody = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("To", text: $recipientsText)
                    TextField("Subject", text: $subjectText)
                }
                
                Section {
                    TextEditor(text: $messageBody)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("New Email")
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
                    Button(action: sendEmail) {
                        if isSending {
                            ProgressView()
                        } else {
                            Text("Send")
                        }
                    }
                    .disabled(isSending || recipientsText.isEmpty || subjectText.isEmpty)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private func sendEmail() {
        isSending = true
        let recipientList = recipientsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        Task {
            do {
                try await mailViewModel.sendEmail(to: recipientList, subject: subjectText, body: messageBody)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSending = false
                }
            }
        }
    }
} 