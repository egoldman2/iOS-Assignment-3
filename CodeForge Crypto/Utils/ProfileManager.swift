import Foundation

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    @Published var profile: UserProfile?

    private let key = "user_profile"

    private init() {
        loadProfile()
    }

    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        }
    }

    func saveProfile() {
        if let profile = profile,
           let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func createProfile(name: String, email: String, pin: String) {
        profile = UserProfile(name: name, email: email, pin: pin, holdings: [])
        saveProfile()
    }

    func updateHoldings(_ holdings: [Holding]) {
        profile?.holdings = holdings
        saveProfile()
    }

    func addHolding(_ holding: Holding) {
        profile?.holdings.append(holding)
        saveProfile()
    }
}