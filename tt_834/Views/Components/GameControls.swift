import SwiftUI

struct GameControls: View {
    @ObservedObject var gameState: GameState
    @Binding var selectedPosition: Position?
    @Binding var showDirectionPicker: Bool
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Button(action: {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                gameState.undo()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 24, height: 24)
                    
                    Text("UNDO")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .tracking(2)
                }
                .foregroundColor(gameState.canUndo() && isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.gridLine.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.gridLine, lineWidth: 1.5)
                        )
                )
            }
            .disabled(!gameState.canUndo() || !isEnabled)
            
            Button(action: {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                if let pos = selectedPosition, gameState.grid[pos.y][pos.x]?.player == gameState.currentPlayer {
                    showDirectionPicker = true
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 24, height: 24)
                    
                    Text("ROTATE")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .tracking(2)
                }
                .foregroundColor((gameState.rotationAvailable[gameState.currentPlayer] == true && isEnabled) ? AppTheme.background : AppTheme.textSecondary.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill((gameState.rotationAvailable[gameState.currentPlayer] == true && isEnabled) ? AppTheme.gridNode : AppTheme.gridLine.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke((gameState.rotationAvailable[gameState.currentPlayer] == true && isEnabled) ? Color.clear : AppTheme.gridLine, lineWidth: 1.5)
                        )
                )
            }
            .disabled(gameState.rotationAvailable[gameState.currentPlayer] != true || selectedPosition == nil || !isEnabled)
        }
    }
}
