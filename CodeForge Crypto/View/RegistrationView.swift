import SwiftUI

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Create a New Profile")
                .font(.title2)
                .bold()

            TextField("Full Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: pin) {
                    // Enforce max 4 digits and numeric only
                    if pin.count > 4 {
                        pin = String(pin.prefix(4))
                    }
                    pin = pin.filter { $0.isNumber }
                }

            Button(action: {
                handleRegistration()
            }) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty || email.isEmpty || pin.count != 4 ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(name.isEmpty || email.isEmpty || pin.count != 4)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handleRegistration() {
        // Basic validation
        guard pin.allSatisfy({ $0.isNumber }) else {
            alertMessage = "PIN must be numeric."
            showAlert = true
            return
        }

        // Store profile
        ProfileManager.shared.createProfile(name: name, email: email, pin: pin)
        alertMessage = "Profile Created Successfully."
        showAlert = true
        
        // Auto-dismiss and navigate back
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

#Preview {
    RegistrationView()
}
