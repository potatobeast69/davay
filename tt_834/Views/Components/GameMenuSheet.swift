import SwiftUI

struct GameMenuSheet: View {
    let onResume: () -> Void
    let onExit: () -> Void
    
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            BlueprintGridBackground()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                VStack(spacing: 12) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(AppTheme.gridNode)
                        .frame(height: 80)
                    
                    Text("PAUSED")
                        .font(.system(size: 32, weight: .light, design: .default))
                        .foregroundColor(AppTheme.textPrimary)
                        .tracking(6)
                        .frame(height: 40)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: onResume) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 24, height: 24)
                            
                            Text("RESUME GAME")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .tracking(2)
                        }
                        .foregroundColor(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.gridNode)
                        )
                    }
                    
                    Button(action: onExit) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 24, height: 24)
                            
                            Text("EXIT TO MENU")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .tracking(2)
                        }
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.gridLine.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.gridLine, lineWidth: 2)
                                )
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
    }
}
