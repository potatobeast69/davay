import SwiftUI

struct MenuView: View {
    @State private var titleScale: CGFloat = 0.8
    @State private var iconRotation: Double = 0
    @State private var glowPulse: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                BlueprintGridBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)
                    
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.gridNodeGlow.opacity(0.3),
                                        AppTheme.gridNodeGlow.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .scaleEffect(glowPulse)
                            .blur(radius: 40)
                        
                        VStack(spacing: 16) {
                            Text("CIRCUIT LINES")
                                .font(.system(size: 38, weight: .thin, design: .default))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.textPrimary,
                                            AppTheme.textSecondary
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .tracking(5)
                                .shadow(color: AppTheme.gridNodeGlow.opacity(0.3), radius: 10)
                            
                            Text("DUEL")
                                .font(.system(size: 52, weight: .light, design: .default))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.gridNode,
                                            AppTheme.gridNodeGlow
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .tracking(10)
                                .shadow(color: AppTheme.gridNodeGlow.opacity(0.8), radius: 20)
                        }
                    }
                    .scaleEffect(titleScale)
                    
                
                    
                    Spacer()
                        .frame(height: 60)
                    
                    VStack(spacing: 18) {
                        NavigationLink(destination: ModeSelectView()) {
                            MenuButtonView(title: "PLAY", icon: "play.circle", gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow])
                        }
                        .buttonStyle(MenuButtonStyle())
                        
                        NavigationLink(destination: PuzzlesView()) {
                            MenuButtonView(title: "PUZZLES", icon: "puzzlepiece", gradient: [AppTheme.playerAAccent, AppTheme.playerAGlow])
                        }
                        .buttonStyle(MenuButtonStyle())
                        
                        NavigationLink(destination: SettingsView()) {
                            MenuButtonView(title: "SETTINGS", icon: "gearshape", gradient: [AppTheme.playerBAccent, AppTheme.playerBGlow])
                        }
                        .buttonStyle(MenuButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    Text("v\(RunesUtilities.appVersion)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.bottom, 24)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    titleScale = 1.0
                }
                
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    iconRotation = 360
                }
                
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    glowPulse = 1.3
                }
            }
        }
    }
}

struct MenuButtonView: View {
    let title: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gradient[0].opacity(0.3),
                                gradient[1].opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
            }
            
            Text(title)
                .font(.system(size: 19, weight: .semibold, design: .default))
                .foregroundColor(AppTheme.textPrimary)
                .tracking(3)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 26)
        .frame(height: 68)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.glassBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                gradient[0].opacity(0.1),
                                gradient[1].opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.glassBorder,
                                gradient[1].opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: gradient[1].opacity(0.3), radius: 15)
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
