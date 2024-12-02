import SwiftUI

struct MailAppView: View {
    let username: String
    @State private var isComposingMail: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Inbox")) {
                    ForEach(1...10, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("Subject \(index)")
                                .fontWeight(.bold)
                            Text("Preview of the email content...")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Welcome, \(username)")
            .toolbar {
                Button(action: {
                    isComposingMail = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
            .sheet(isPresented: $isComposingMail) {
                ComposeMailView()
            }
        }
    }
}
