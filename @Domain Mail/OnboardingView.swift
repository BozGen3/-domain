import SwiftUI

struct OnboardingView: View {
    @State private var name: String = ""
    @State private var domain: String = "@example.com"
    @State private var isValid: Bool = false
    @State private var errorMessage: String? = nil
    
    @AppStorage("username") private var username: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Your Mail App")
                .font(.title)
                .fontWeight(.bold)

            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: name) { _ in validateName() }

            HStack {
                TextField("Enter custom domain", text: $domain)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: domain) { _ in validateName() }
                Text("@")
                    .foregroundColor(.gray)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: {
                if isValid {
                    username = "\(name)\(domain)"
                }
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isValid)
        }
        .padding()
    }

    private func validateName() {
        if name.isEmpty || !domain.contains(".") {
            isValid = false
            errorMessage = "Please enter a valid name and domain."
        } else {
            isValid = name.lowercased() != "admin" // Example: disallow 'admin'
            errorMessage = isValid ? nil : "This name is not available."
        }
    }
}
