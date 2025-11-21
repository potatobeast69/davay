import SwiftUI

struct GameResultView: View {
    @ObservedObject var gameState: GameState
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.5
    @State private var iconRotation: Double = 0
    @State private var confettiAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                BlueprintGridBackground()
                
                if showContent {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: max(20, geometry.safeAreaInsets.top + 10))
                        
                        ResultHeader(
                            winner: gameState.winner,
                            endReason: gameState.endReason,
                            iconRotation: iconRotation,
                            confettiAnimation: confettiAnimation
                        )
                        
                        Spacer()
                            .frame(height: 16)
                        
                        ResultScores(gameState: gameState)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 12)
                        
                        ResultStats(gameState: gameState)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(minHeight: 12)
                        
                        Button(action: {
                            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                            impactHeavy.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showContent = false
                                scale = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDismiss()
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("BACK TO MENU")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .tracking(2)
                            }
                            .foregroundColor(AppTheme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    AppTheme.gridNode,
                                                    AppTheme.gridNodeGlow
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 2
                                        )
                                }
                            )
                            .shadow(color: AppTheme.gridNodeGlow.opacity(0.5), radius: 12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 10))
                    }
                    .scaleEffect(scale)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
                scale = 1.0
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                confettiAnimation.toggle()
            }
        }
    }
}

struct ResultHeader: View {
    let winner: Player?
    let endReason: String
    let iconRotation: Double
    let confettiAnimation: Bool
    
    @State private var iconScale: CGFloat = 0.5
    
    var headerGradient: [Color] {
        if let winner = winner {
            return winner == .a ? [AppTheme.playerAAccent, AppTheme.playerAGlow] : [AppTheme.playerBAccent, AppTheme.playerBGlow]
        }
        return [AppTheme.gridNode, AppTheme.gridNodeGlow]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ForEach(0..<2, id: \.self) { ring in
                    Circle()
                        .stroke(
                            headerGradient[0].opacity(0.2 - Double(ring) * 0.08),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 6])
                        )
                        .frame(width: 80 + CGFloat(ring) * 30, height: 80 + CGFloat(ring) * 30)
                        .rotationEffect(.degrees(iconRotation + Double(ring * 120)))
                }
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                headerGradient[0].opacity(0.3),
                                headerGradient[1].opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                    .scaleEffect(confettiAnimation ? 1.15 : 1.0)
                
                ZStack {
                    Circle()
                        .fill(AppTheme.glassBackground)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: headerGradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                        .shadow(color: headerGradient[1].opacity(0.5), radius: 12)
                    
                    if winner != nil {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: headerGradient,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        Image(systemName: "equal.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: headerGradient,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .scaleEffect(iconScale)
            }
            .frame(height: 110)
            
            VStack(spacing: 8) {
                if let winner = winner {
                    Text("PLAYER \(winner.rawValue) WINS!")
                        .font(.system(size: 28, weight: .bold, design: .default))
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
                        .shadow(color: headerGradient[1].opacity(0.4), radius: 10)
                } else {
                    Text("DRAW")
                        .font(.system(size: 28, weight: .bold, design: .default))
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
                        .shadow(color: headerGradient[1].opacity(0.4), radius: 10)
                }
                
                Text(endReason.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1.5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.glassBackground)
                            .overlay(
                                Capsule()
                                    .stroke(headerGradient[0].opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1.0
            }
        }
    }
}

struct ResultScores: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        HStack(spacing: 12) {
            ResultPlayerCard(
                player: .a,
                score: gameState.calculateScore(for: .a),
                cycles: gameState.cycles[.a]?.filter { $0.isStable }.count ?? 0,
                territory: gameState.territories[.a]?.count ?? 0,
                isWinner: gameState.winner == .a
            )
            
            ResultPlayerCard(
                player: .b,
                score: gameState.calculateScore(for: .b),
                cycles: gameState.cycles[.b]?.filter { $0.isStable }.count ?? 0,
                territory: gameState.territories[.b]?.count ?? 0,
                isWinner: gameState.winner == .b
            )
        }
    }
}

struct ResultPlayerCard: View {
    let player: Player
    let score: Int
    let cycles: Int
    let territory: Int
    let isWinner: Bool
    
    @State private var animatedScore: Int = 0
    
    var playerGradient: [Color] {
        player == .a ? [AppTheme.playerAAccent, AppTheme.playerAGlow] : [AppTheme.playerBAccent, AppTheme.playerBGlow]
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: playerGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("PLAYER \(player.rawValue)")
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: playerGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(1.5)
            }
            
            Text("\(animatedScore)")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
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
                .shadow(color: isWinner ? playerGradient[1].opacity(0.4) : .clear, radius: 10)
            
            Text("POINTS")
                .font(.system(size: 10, weight: .semibold, design: .default))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)
            
            Divider()
                .background(playerGradient[0].opacity(0.3))
                .padding(.vertical, 2)
            
            HStack(spacing: 14) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: playerGradient,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("\(cycles)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Cycles")
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .foregroundColor(AppTheme.textSecondary)
                        .tracking(0.5)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: playerGradient,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("\(territory)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Territory")
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .foregroundColor(AppTheme.textSecondary)
                        .tracking(0.5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.glassBackground)
                
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                playerGradient[0].opacity(isWinner ? 0.12 : 0.04),
                                playerGradient[1].opacity(isWinner ? 0.08 : 0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: isWinner ? [
                                playerGradient[0],
                                playerGradient[1].opacity(0.5)
                            ] : [
                                AppTheme.glassBorder,
                                AppTheme.glassBorder.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isWinner ? 2 : 1.5
                    )
            }
        )
        .shadow(color: isWinner ? playerGradient[1].opacity(0.25) : .clear, radius: 10)
        .onAppear {
            animateScore()
        }
    }
    
    private func animateScore() {
        let duration = 1.0
        let steps = 20
        let increment = score / steps
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration / Double(steps)) * Double(step)) {
                if step == steps {
                    animatedScore = score
                } else {
                    animatedScore = increment * step
                }
            }
        }
    }
}

struct ResultStats: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ResultStatCard(
                    title: "Total Moves",
                    value: "\(gameState.stats.totalMoves)",
                    icon: "number.circle.fill",
                    gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow]
                )
                
                ResultStatCard(
                    title: "Intersections",
                    value: "\(gameState.gashedEdges.count / 2)",
                    icon: "xmark.circle.fill",
                    gradient: [AppTheme.playerBAccent, AppTheme.playerBGlow]
                )
            }
            
            HStack(spacing: 10) {
                ResultStatCard(
                    title: "Rotations Used",
                    value: "\(gameState.stats.rotationUsed.values.filter { $0 }.count)",
                    icon: "arrow.clockwise.circle.fill",
                    gradient: [AppTheme.playerAAccent, AppTheme.playerAGlow]
                )
                
                ResultStatCard(
                    title: "Max Cycles",
                    value: "\(max(gameState.cycles[.a]?.filter { $0.isStable }.count ?? 0, gameState.cycles[.b]?.filter { $0.isStable }.count ?? 0))",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow]
                )
            }
        }
    }
}

struct ResultStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gradient[0].opacity(0.25),
                                gradient[1].opacity(0.08)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 14
                        )
                    )
                    .frame(width: 28, height: 28)
                    .blur(radius: 6)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .default))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(0.8)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.glassBackground)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                gradient[0].opacity(0.06),
                                gradient[1].opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.glassBorder,
                                gradient[1].opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: gradient[1].opacity(0.15), radius: 8)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double.random(in: 0.1...0.3))) {
                scale = 1.0
            }
        }
    }
}


