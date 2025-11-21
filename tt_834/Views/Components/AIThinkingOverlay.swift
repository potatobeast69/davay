import SwiftUI

struct AIThinkingOverlay: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var pulseOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(AppTheme.playerBAccent.opacity(pulseOpacity - Double(index) * 0.1), lineWidth: 2)
                            .frame(width: 80 + CGFloat(index) * 30, height: 80 + CGFloat(index) * 30)
                            .rotationEffect(.degrees(rotation + Double(index * 120)))
                    }
                    
                    ZStack {
                        Circle()
                            .fill(AppTheme.playerBAccent)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "cpu")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(AppTheme.background)
                    }
                }
                .frame(height: 140)
                
                VStack(spacing: 8) {
                    Text("AI PROCESSING")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(AppTheme.textPrimary)
                        .tracking(3)
                        .frame(height: 24)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(AppTheme.playerBAccent)
                                .frame(width: 8, height: 8)
                                .scaleEffect(scale)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: scale
                                )
                        }
                    }
                    .frame(height: 16)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.playerBAccent, lineWidth: 3)
                    )
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                scale = 1.2
                pulseOpacity = 0.6
            }
        }
    }
}
