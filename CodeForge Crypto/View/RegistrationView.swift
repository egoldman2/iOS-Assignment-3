import SwiftUI

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @FocusState private var nameFocused: Bool
    @FocusState private var emailFocused: Bool
    @FocusState private var pinFocused: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.green, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass morphism overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.7)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Join the crypto revolution")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("John Doe", text: $name)
                                .textContentType(.name)
                                .focused($nameFocused)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(nameFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($emailFocused)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(emailFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        
                        // PIN Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create 4-Digit PIN")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            SecureField("", text: $pin)
                                .placeholder(when: pin.isEmpty) {
                                    Text("••••")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .focused($pinFocused)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(pinFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .onChange(of: pin) { _, newValue in
                                    // Only allow numbers
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    
                                    // Limit to exactly 4 digits
                                    if filtered.count > 4 {
                                        pin = String(filtered.prefix(4))
                                    } else {
                                        pin = filtered
                                    }
                                }
                            
                            HStack {
                                Text("You'll use this PIN to login")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                                
                                // PIN progress dots
                                HStack(spacing: 4) {
                                    ForEach(0..<4) { index in
                                        Circle()
                                            .fill(index < pin.count ? Color.white : Color.white.opacity(0.3))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Register Button
                    Button(action: handleRegistration) {
                        Text("Create Account")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: isValidInput ? [Color.white, Color.white.opacity(0.9)] : [Color.gray, Color.gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(isValidInput ? Color.green : Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(!isValidInput)
                    .padding(.horizontal, 40)
                    
                    // Terms
                    Text("By continuing, you agree to HODL responsibly 🚀")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(PortfolioViewModel())
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage == "Account created successfully!" ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Account created successfully!" {
                        navigateToHome = true
                    }
                }
            )
        }
        .onAppear {
            nameFocused = true
        }
    }

    private var isValidInput: Bool {
        !name.isEmpty && !email.isEmpty && pin.count == 4
    }

    private func handleRegistration() {
        guard pin.allSatisfy({ $0.isNumber }) else {
            alertMessage = "PIN must be numeric."
            showAlert = true
            return
        }

        if ProfileManager.shared.profiles[email] != nil {
            alertMessage = "An account with this email already exists."
            showAlert = true
            return
        }

        ProfileManager.shared.createProfile(name: name, email: email, pin: pin)
        alertMessage = "Account created successfully!"
        showAlert = true
    }
}

// Extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    NavigationStack {
        RegistrationView()
    }
}
