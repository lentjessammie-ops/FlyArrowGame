import SwiftUI

struct LockedLevelView: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("Level Locked")
                    .font(.custom("FascinateInline-Regular", size: 40))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.custom("MuseoModerno-Regular", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("OK")
                        .font(.custom("MuseoModerno-Regular", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(25)
                }
            }
            .padding(40)
            .background(Color.black.opacity(0.7))
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}
