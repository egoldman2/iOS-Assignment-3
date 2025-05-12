import Foundation

enum AppError: LocalizedError, Equatable {

    case invalidEmail
    case passwordTooShort
    case emailAlreadyExists
    case userNotFound
    case incorrectPassword
    
  
    case insufficientBalance
    case invalidAmount
    case portfolioNotFound
    case cannotSellZeroOrNegative
    
    // API Error
    case apiFailure
    case invalidResponse
    case decodingError
    case noInternetConnection
    case invalidChartData

    // General Error
    case unknownError
    case custom(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Invalid email format"
        case .passwordTooShort: return "Password must be at least 6 characters"
        case .emailAlreadyExists: return "Email is already registered"
        case .userNotFound: return "User not found"
        case .incorrectPassword: return "Incorrect password"

        case .insufficientBalance: return "Insufficient balance"
        case .invalidAmount: return "Invalid transaction amount"
        case .portfolioNotFound: return "No portfolio data found"
        case .cannotSellZeroOrNegative: return "You must sell at least one unit"

        // API
        case .apiFailure: return "Can't connect to service"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError: return "Data could not be decoded"
        case .noInternetConnection: return "There is no internet connection"
        case .invalidChartData: return "Chart data format is invalid" 

        // other
        case .unknownError: return "Unknown error"
        case .custom(let message): return message
        }
    }



}
