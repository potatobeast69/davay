import SwiftUI

struct PuzzlesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appearAnimation = false
    
    let puzzles = [
        (id: 1, title: "First Cycle", description: "Create your first cycle in 3 moves", difficulty: "Easy"),
        (id: 2, title: "Defense", description: "Block opponent's cycle formation", difficulty: "Medium"),
        (id: 3, title: "Double Trouble", description: "Create 2 cycles in 6 moves", difficulty: "Hard"),
        (id: 4, title: "Intersection", description: "Use gashing to break enemy cycle", difficulty: "Medium"),
        (id: 5, title: "Master Builder", description: "3 stable cycles in minimal moves", difficulty: "Hard"),
        (id: 6, title: "Territory Control", description: "Claim center territory", difficulty: "Easy")
    ]
    
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
                                .foregroundColor(AppTheme.playerAAccent)
                        }
                    }
                    
                    Spacer()
                    
                    Text("PUZZLES")
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
                    LazyVStack(spacing: 16) {
                        ForEach(Array(puzzles.enumerated()), id: \.element.id) { index, puzzle in
                            NavigationLink(destination: GameView(gameState: GameState(mode: .puzzle(puzzle.id)))) {
                                PuzzleCardContentView(
                                    number: puzzle.id,
                                    title: puzzle.title,
                                    description: puzzle.description,
                                    difficulty: puzzle.difficulty
                                )
                            }
                            .buttonStyle(PuzzleCardButtonStyle())
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.08), value: appearAnimation)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appearAnimation = true
        }
    }
}

struct PuzzleCardContentView: View {
    let number: Int
    let title: String
    let description: String
    let difficulty: String
    
    var difficultyColor: [Color] {
        switch difficulty {
        case "Easy": return [AppTheme.playerAAccent, AppTheme.playerAGlow]
        case "Medium": return [AppTheme.gridNode, AppTheme.gridNodeGlow]
        case "Hard": return [AppTheme.playerBAccent, AppTheme.playerBGlow]
        default: return [AppTheme.gridLine, AppTheme.gridLine]
        }
    }
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                difficultyColor[0].opacity(0.3),
                                difficultyColor[1].opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 15)
                
                Circle()
                    .fill(AppTheme.glassBackground)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        difficultyColor[0].opacity(0.5),
                                        difficultyColor[1].opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                Text("\(number)")
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: difficultyColor,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(AppTheme.textPrimary)
                    .tracking(1)
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: difficultyColor,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 6, height: 6)
                    
                    Text(difficulty.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: difficultyColor,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .tracking(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(difficultyColor[0].opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(difficultyColor[0].opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                difficultyColor[0].opacity(0.3),
                                difficultyColor[1].opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)
                    .blur(radius: 8)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: difficultyColor,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.glassBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                difficultyColor[0].opacity(0.08),
                                difficultyColor[1].opacity(0.04)
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
                                difficultyColor[1].opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: difficultyColor[1].opacity(0.2), radius: 12)
    }
}

struct PuzzleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
