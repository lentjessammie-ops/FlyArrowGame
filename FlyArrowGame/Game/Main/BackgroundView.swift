//
//  BackgroundView.swift
//  FlyArrowGame
//
//  Created by D K on 07.11.2025.
//

import SwiftUI

extension View {
    func size() -> CGSize {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        return window.screen.bounds.size
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 145/255, green: 202/255, blue: 240/255),
                    Color(red: 128/255, green: 197/255, blue: 255/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size().width, height: size().height)
            .offset(y: -20)
            
            Image("bg")
                .resizable()
                .ignoresSafeArea()
                .frame(width: size().width, height: size().height)
                .scaledToFill()
                .clipped()
        }
        
    }
}

#Preview {
    BackgroundView()
}
