import Foundation
import Combine
import SwiftUI

class MailViewModel: ObservableObject {
    @Published var emails: [Email] = []
    @Published var customFolders: [CustomFolder] = []
    @Published var isLoading = false
    @Published var error: String?
    @AppStorage("userEmail") private var userEmail: String = ""
    private var emailSession: URLSession?
    
    init() {
        setupEmailSession()
        loadCustomFolders()
    }
    
    private func setupEmailSession() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(getAuthToken())"
        ]
        emailSession = URLSession(configuration: configuration)
    }
    
    func fetchEmails(for mailbox: MailboxType) {
        isLoading = true
        
        Task {
            do {
                let fetchedEmails = try await fetchEmailsFromServer(mailbox: mailbox)
                await MainActor.run {
                    self.emails = fetchedEmails
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchEmailsFromServer(mailbox: MailboxType) async throws -> [Email] {
        guard let session = emailSession else {
            throw EmailError.notAuthenticated
        }
        
        let endpoint = "https://api.domain.com/mail/\(mailbox.rawValue.lowercased())"
        guard let url = URL(string: endpoint) else {
            throw EmailError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(EmailResponse.self, from: data)
        return response.emails
    }
    
    private func getAuthToken() -> String {
        UserDefaults.standard.string(forKey: "authToken") ?? ""
    }
    
    @MainActor
    func sendEmail(to recipients: [String], subject: String, body: String) async throws {
        guard let session = emailSession else {
            throw EmailError.notAuthenticated
        }
        
        let url = URL(string: "https://api.domain.com/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailData = [
            "from": userEmail,
            "to": recipients,
            "subject": subject,
            "body": body
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw EmailError.serverError("Failed to send email")
        }
    }
    
    @MainActor
    func deleteEmail(_ email: Email) async throws {
        guard let session = emailSession else {
            throw EmailError.notAuthenticated
        }
        
        let url = URL(string: "https://api.domain.com/mail/delete/\(email.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw EmailError.serverError("Failed to delete email")
        }
        
        emails.removeAll { $0.id == email.id }
    }
    
    @MainActor
    func createFolder(name: String) {
        let folder = CustomFolder(id: UUID().uuidString, name: name)
        customFolders.append(folder)
        saveCustomFolders()
    }
    
    @MainActor
    func deleteFolder(_ folder: CustomFolder) {
        customFolders.removeAll { $0.id == folder.id }
        saveCustomFolders()
    }
    
    @MainActor
    func moveEmail(_ email: Email, to folder: CustomFolder) {
        emails.removeAll { $0.id == email.id }
    }
    
    @MainActor
    func signOut() {
        userEmail = ""
        emails = []
        customFolders = []
        emailSession = nil
    }
    
    private func loadCustomFolders() {
        if let data = UserDefaults.standard.data(forKey: "customFolders"),
           let folders = try? JSONDecoder().decode([CustomFolder].self, from: data) {
            customFolders = folders
        }
    }
    
    private func saveCustomFolders() {
        if let data = try? JSONEncoder().encode(customFolders) {
            UserDefaults.standard.set(data, forKey: "customFolders")
        }
    }
}

struct EmailResponse: Codable {
    let emails: [Email]
}

struct Email: Identifiable, Codable {
    let id: String
    let subject: String
    let sender: String
    let preview: String
    let date: Date
    let isRead: Bool
}

struct CustomFolder: Identifiable, Codable {
    let id: String
    let name: String
} 