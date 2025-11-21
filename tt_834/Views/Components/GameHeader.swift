import SwiftUI

struct GameHeader: View {
    @ObservedObject var gameState: GameState
    let onMenuTap: () -> Void
    let isAIThinking: Bool
    let isAIMode: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                Button(action: onMenuTap) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gridLine.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 6) {
                    Text("MOVE \(gameState.moveNumber + 1)")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                        .tracking(1)
                    
                    if isAIThinking {
                        Text("AI THINKING")
                            .font(.system(size: 17, weight: .bold, design: .default))
                            .foregroundColor(AppTheme.playerBAccent)
                            .tracking(3)
                    } else {
                        Text(gameState.currentPlayer == .a ? "YOUR TURN" : (isAIMode ? "AI TURN" : "PLAYER B"))
                            .font(.system(size: 17, weight: .bold, design: .default))
                            .foregroundColor(gameState.currentPlayer == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent)
                            .tracking(3)
                    }
                }
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            
            HStack(spacing: 16) {
                PlayerScoreCard(
                    player: .a,
                    cycles: gameState.cycles[.a]?.filter { $0.isStable }.count ?? 0,
                    score: gameState.calculateScore(for: .a),
                    isActive: gameState.currentPlayer == .a,
                    label: "YOU"
                )
                
                PlayerScoreCard(
                    player: .b,
                    cycles: gameState.cycles[.b]?.filter { $0.isStable }.count ?? 0,
                    score: gameState.calculateScore(for: .b),
                    isActive: gameState.currentPlayer == .b,
                    label: isAIMode ? "AI" : "B"
                )
            }
        }
    }
}

struct PlayerScoreCard: View {
    let player: Player
    let cycles: Int
    let score: Int
    let isActive: Bool
    let label: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent)
                .tracking(2)
                .frame(height: 16)
            
            HStack(spacing: 14) {
                VStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor((player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.8))
                        .frame(height: 20)
                    
                    Text("\(cycles)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(height: 24)
                }
                
                Rectangle()
                    .fill((player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor((player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.8))
                        .frame(height: 20)
                    
                    Text("\(score)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(height: 24)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.gridLine.opacity(isActive ? 0.3 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isActive ? (player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent) : AppTheme.gridLine,
                            lineWidth: isActive ? 2.5 : 1
                        )
                )
        )
    }
}
