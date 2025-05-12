import Foundation

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    @Published var profiles: [String: UserAccount] = [:]
    @Published var activeProfile: UserAccount?

    private let key = "user_profiles"
    private let activeKey = "active_profile"

    private init() {
        loadProfiles()
    }

    func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: UserAccount].self, from: data) {
            profiles = decoded
        }

        if let activeEmail = UserDefaults.standard.string(forKey: activeKey) {
            activeProfile = profiles[activeEmail]
        }
    }

    func saveProfiles() {
        // Update the stored profile with current active profile data before saving
        if let email = activeProfile?.email {
            profiles[email] = activeProfile
        }
        
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func createProfile(name: String, email: String, pin: String) {
        let newProfile = UserAccount(email: email, name: name, pin: pin, holdings: [], storedCards: [], accountBalance: 0)
        profiles[email] = newProfile
        activeProfile = newProfile
        UserDefaults.standard.set(email, forKey: activeKey)
        saveProfiles()
    }

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

    func deleteProfile(email: String) {
        profiles.removeValue(forKey: email)
        if activeProfile?.email == email {
            activeProfile = nil
            UserDefaults.standard.removeObject(forKey: activeKey)
        }
        saveProfiles()
    }

    func updateHoldings(_ holdings: [Holding]) {
        if let email = activeProfile?.email {
            activeProfile?.holdings = holdings
            profiles[email]?.holdings = holdings
            saveProfiles()
        }
    }

    func addHolding(_ holding: Holding) {
        if let email = activeProfile?.email {
            activeProfile?.holdings.append(holding)
            profiles[email]?.holdings.append(holding)
            saveProfiles()
        }
    }
    
    func updateStoredCards(_ cards: [CreditCard]) {
        if let email = activeProfile?.email {
            activeProfile?.storedCards = cards
            profiles[email]?.storedCards = cards
            saveProfiles()
        }
    }
    
    func addStoredCard(_ card: CreditCard) {
        if let email = activeProfile?.email {
            activeProfile?.storedCards.append(card)
            profiles[email]?.storedCards.append(card)
            saveProfiles()
        }
    }
}
