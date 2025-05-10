import Foundation

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    @Published var profile: UserAccount?

    private let key = "user_profile"

    private init() {
        loadProfile()
    }

    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserAccount.self, from: data) {
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
        profile = UserAccount(email: email, name: name, pin: pin, holdings: [], accountBalance: 0)

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
