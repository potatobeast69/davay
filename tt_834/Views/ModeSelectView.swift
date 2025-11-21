import SwiftUI

struct ModeSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            BlueprintGridBackground()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.glassBackground)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.glassBorder, lineWidth: 1)
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.gridNode)
                        }
                    }
                    
                    Spacer()
                    
                    Text("SELECT MODE")
                        .font(.system(size: 20, weight: .semibold, design: .default))
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
                        .tracking(3)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .frame(height: 60)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ModeCategoryView(
                            title: "PRACTICE",
                            icon: "cpu",
                            gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow],
                            modes: [
                                ("EASY", "Beginner AI", GameMode.practiceEasy),
                                ("MEDIUM", "Intermediate AI", GameMode.practiceMedium),
                                ("HARD", "Advanced AI", GameMode.practiceHard)
                            ]
                        )
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        ModeCategoryView(
                            title: "LOCAL",
                            icon: "person.2",
                            gradient: [AppTheme.playerAAccent, AppTheme.playerAGlow],
                            modes: [
                                ("LOCAL DUEL", "Two players on one device", GameMode.localDuel)
                            ]
                        )
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        ModeCategoryView(
                            title: "QUICK",
                            icon: "bolt",
                            gradient: [AppTheme.playerBAccent, AppTheme.playerBGlow],
                            modes: [
                                ("BLITZ", "10 sec per turn, 16 moves total", GameMode.blitz)
                            ]
                        )
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
}

struct ModeCategoryView: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let modes: [(title: String, description: String, mode: GameMode)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
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
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                        .blur(radius: 6)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(2)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 14) {
                ForEach(modes.indices, id: \.self) { index in
                    NavigationLink(destination: GameView(gameState: GameState(mode: modes[index].mode))) {
                        ModeCardContentView(
                            title: modes[index].title,
                            description: modes[index].description,
                            gradient: gradient
                        )
                    }
                    .buttonStyle(ModeCardButtonStyle())
                }
            }
        }
    }
}

struct ModeCardContentView: View {
    let title: String
    let description: String
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 19, weight: .semibold, design: .default))
                    .foregroundColor(AppTheme.textPrimary)
                    .tracking(2)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
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
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.glassBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                gradient[0].opacity(0.08),
                                gradient[1].opacity(0.04)
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
        .shadow(color: gradient[1].opacity(0.2), radius: 12)
    }
}

struct ModeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
