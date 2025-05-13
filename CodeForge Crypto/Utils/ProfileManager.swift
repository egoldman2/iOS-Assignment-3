import Foundation

// Singleton class that manages user profiles, including creation, selection, persistence, and in-memory state.
// Stores multiple profiles using UserDefaults and allows switching between them at runtime.
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    @Published var profiles: [String: UserAccount] = [:]
    @Published var activeProfile: UserAccount?

    private let key = "user_profiles"
    private let activeKey = "active_profile"

    private init() {
        loadProfiles()
    }

    // Handles loading and saving profiles from/to UserDefaults.
    // Includes methods for creating, switching, and deleting user profiles.
    // Load profiles from UserDefaults and set the active profile
    func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: UserAccount].self, from: data) {
            profiles = decoded
        }

        if let activeEmail = UserDefaults.standard.string(forKey: activeKey) {
            activeProfile = profiles[activeEmail]
        }
    }

    // Save all profiles to UserDefaults, including the currently active one
    func saveProfiles() {
        // Update the stored profile with current active profile data before saving
        if let email = activeProfile?.email {
            profiles[email] = activeProfile
        }

        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Create a new profile and set it as active
    func createProfile(name: String, email: String, pin: String) {
        let newProfile = UserAccount(email: email, name: name, pin: pin, holdings: [], storedCards: [], accountBalance: 0)
        profiles[email] = newProfile
        activeProfile = newProfile
        UserDefaults.standard.set(email, forKey: activeKey)
        saveProfiles()
    }

    // Switch the current session to another saved profile
    func switchProfile(email: String) {
        // Save current profile before switching
        if let currentEmail = activeProfile?.email {
            profiles[currentEmail] = activeProfile
        }

        if let profile = profiles[email] {
            activeProfile = profile
            UserDefaults.standard.set(email, forKey: activeKey)
            saveProfiles()
        }
    }

    // Delete a profile and clear it if currently active
    func deleteProfile(email: String) {
        profiles.removeValue(forKey: email)
        if activeProfile?.email == email {
            activeProfile = nil
            UserDefaults.standard.removeObject(forKey: activeKey)
        }
        saveProfiles()
    }

    // Methods to update or add holdings and stored credit cards for the active profile.
    // Replace all holdings for the current profile
    func updateHoldings(_ holdings: [Holding]) {
        if let email = activeProfile?.email {
            activeProfile?.holdings = holdings
            profiles[email]?.holdings = holdings
            saveProfiles()
        }
    }

    // Add a new holding to the current profile
    func addHolding(_ holding: Holding) {
        if let email = activeProfile?.email {
            activeProfile?.holdings.append(holding)
            profiles[email]?.holdings.append(holding)
            saveProfiles()
        }
    }

    // Replace all stored cards for the current profile
    func updateStoredCards(_ cards: [CreditCard]) {
        if let email = activeProfile?.email {
            activeProfile?.storedCards = cards
            profiles[email]?.storedCards = cards
            saveProfiles()
        }
    }

    // Add a new credit card to the current profile
    func addStoredCard(_ card: CreditCard) {
        if let email = activeProfile?.email {
            activeProfile?.storedCards.append(card)
            profiles[email]?.storedCards.append(card)
            saveProfiles()
        }
    }
}
