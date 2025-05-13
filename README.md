# iOS-Assignment-3

# CodeForge Crypto

CodeForge Crypto is a SwiftUI-based iOS app that simulates a secure, modern cryptocurrency wallet and trading interface. It includes account creation, profile-based portfolio management, secure login via PIN entry, and a stylish, interactive UI designed for iOS 17+.

## ✨ Features

### 🔐 Secure Login
- Custom PIN entry screen using a fully custom number pad
- Profile switching and persistent login state

### 👤 Profile Management
- Multiple user profiles supported
- Each profile has independent portfolios, stored credit cards, and balances
- Data is persisted using `UserDefaults` keyed per profile

### 📈 Portfolio Tracking
- Balance and coin holdings displayed
- Mock coin trading and balance adjustment
- Coin detail views with charted price data and news

### 💳 Credit Card Recharge
- Recharge balance using a card form with MM/YY pickers and validation
- Cards stored per profile

### 🧭 Navigation
- Tab-based navigation with three core views:
  - Home (market overview)
  - Portfolio
  - Profile settings and logout

### 🎨 UI and Experience
- Gradient backgrounds and glassmorphism styling
- Responsive layouts with support for dynamic sizing using `GeometryReader`
- Modern SwiftUI animations and transitions

## 🧪 Known Issues
- Due to budget constraints, the app uses the free tier of the API used, which enforces rate limits and can cause the app not to load coin data
- This is mitigated by caching API responses to reuse and having fallback static data when all else fails 

## 📊 Assessment Criteria Commentary

### ✅ Data Modeling
The app uses structured models such as `UserAccount`, `Portfolio`, `CreditCard`, and `TradeRecord` that clearly represent real-world crypto wallet concepts. These models map directly to the app's feature set and data needs.

### ✅ Immutable Data & Idempotent Methods
Where appropriate, Swift's `let` is used to enforce immutability, particularly in views and model construction. Portfolio changes and PIN input behave predictably, and view updates rely on `@Published` state, ensuring clean side-effect-free interactions.

### ✅ Functional Separation
Logic is neatly split into files and classes: `ProfileManager` handles user persistence, `PortfolioViewModel` manages financial logic, and views like `RechargeView`, `PinView`, and `CustomNumberPad` focus on UI. This makes the codebase easy to navigate and test.

### ✅ Loose Coupling
Most components communicate through bindings or environment objects, allowing them to be tested or replaced independently. For example, `PinView` and `CustomNumberPad` can be swapped out or reused with minimal changes.

### ✅ Extensibility
The modular structure allows for easy expansion. Adding a new feature, like transaction history or recurring payments, would involve minimal changes thanks to separated data and view logic. Profile support already demonstrates data-driven extensibility.

### ✅ Error Handling
User input is validated at key points:
- PIN limited to numeric 4-digit input
- Email validated using regex
- Credit card fields max length
- And many more instances of data validation
- Invalid inputs show contextual error messages, preventing incorrect data entry and guiding users toward valid formats.
- Static Data fallback when API is not accessible
- Backend focused errors appear in the console when debugging


### ✅ Collaboration Evidence
This project demonstrates GitHub collaboration 

## 📱 Requirements
- iOS 17 or later

---

This app is a demonstration project and does **not** connect to real financial services.
