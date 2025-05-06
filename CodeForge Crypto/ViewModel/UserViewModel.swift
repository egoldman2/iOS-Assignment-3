import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [UserAccount] = []
    @Published var currentUser: UserAccount?

    func register(email: String, password: String) throws {
        guard email.contains("@") && email.contains(".") else {
            throw AppError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AppError.passwordTooShort
        }

        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw AppError.emailAlreadyExists
        }

        let newUser = UserAccount(email: email, name:"" ,password: password)
        users.append(newUser)
        currentUser = newUser
    }

    func login(email: String, password: String) throws {
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            throw AppError.userNotFound
        }

        guard user.password == password else {
            throw AppError.incorrectPassword
        }

        currentUser = user
    }

    func logout() {
        currentUser = nil
    }

    func deposit(amount: Double) throws {
        guard var user = currentUser else {
            throw AppError.userNotFound
        }

        guard amount > 0 else {
            throw AppError.invalidAmount
        }

        user.balance += amount
        updateUserInfo(user)
        currentUser = user
    }

    func withdraw(amount: Double) throws {
        guard var user = currentUser else {
            throw AppError.userNotFound
        }

        guard amount > 0 else {
            throw AppError.invalidAmount
        }

        guard user.balance >= amount else {
            throw AppError.insufficientBalance
        }

        user.balance -= amount
        updateUserInfo(user)
        currentUser = user
    }
    
    func changeUserName(to newName: String) throws {
        guard var user = currentUser else {
            throw AppError.userNotFound
        }

        user.name = newName
        updateUserInfo(user)
        currentUser = user
    }


    private func updateUserInfo(_ user: UserAccount) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
}

