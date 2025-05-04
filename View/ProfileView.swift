import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Your Portfolio")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

