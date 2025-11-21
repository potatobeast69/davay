import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var gameState: GameState
    @State private var showDirectionPicker = false
    @State private var selectedPosition: Position? = nil
    @State private var showResult = false
    @State private var showMenu = false
    @State private var isAIThinking = false
    @State private var gameAI: GameAI?
    
    var isAIMode: Bool {
        switch gameState.mode {
        case .practiceEasy, .practiceMedium, .practiceHard:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                BlueprintGridBackground()
                
                VStack(spacing: 0) {
                    GameHeader(
                        gameState: gameState,
                        onMenuTap: {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            showMenu = true
                        },
                        isAIThinking: isAIThinking,
                        isAIMode: isAIMode
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .frame(height: 150)
                    
                    Spacer()
                        .frame(minHeight: 20)
                    
                    GameBoardContainer(
                        gameState: gameState,
                        selectedPosition: $selectedPosition,
                        showDirectionPicker: $showDirectionPicker,
                        isInteractive: !isAIThinking && (gameState.currentPlayer == .a || !isAIMode),
                        geometry: geometry
                    )
                    
                    Spacer()
                        .frame(minHeight: 20)
                    
                
                }
                
                if showDirectionPicker, let position = selectedPosition {
                    DirectionPickerOverlay(
                        position: position,
                        gameState: gameState,
                        onSelect: { direction in
                            if let arrow = gameState.grid[position.y][position.x] {
                                gameState.rotateArrow(at: position, to: direction)
                            } else {
                                gameState.placeArrow(at: position, direction: direction)
                            }
                            showDirectionPicker = false
                            selectedPosition = nil
                            
                            if isAIMode && !gameState.gameEnded {
                                makeAIMove()
                            }
                        },
                        onCancel: {
                            showDirectionPicker = false
                            selectedPosition = nil
                        }
                    )
                }
                
                if isAIThinking {
                    AIThinkingOverlay()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupAI()
        }
        .onChange(of: gameState.gameEnded) { ended in
            if ended {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showResult = true
                }
            }
        }
        .sheet(isPresented: $showResult) {
            GameResultView(gameState: gameState, onDismiss: { dismiss() })
        }
        .sheet(isPresented: $showMenu) {
            GameMenuSheet(
                onResume: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    showMenu = false
                },
                onExit: {
                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                    impactHeavy.impactOccurred()
                    dismiss()
                }
            )
        }
    }
    
    private func setupAI() {
        guard isAIMode else { return }
        
        let difficulty: GameAI.Difficulty
        switch gameState.mode {
        case .practiceEasy:
            difficulty = .easy
        case .practiceMedium:
            difficulty = .medium
        case .practiceHard:
            difficulty = .hard
        default:
            return
        }
        
        gameAI = GameAI(difficulty: difficulty, player: .b)
    }
    
    private func makeAIMove() {
        guard let ai = gameAI, gameState.currentPlayer == .b, !gameState.gameEnded else { return }
        
        isAIThinking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let rotation = ai.shouldRotate(gameState: gameState), Double.random(in: 0...1) < 0.4 {
                gameState.rotateArrow(at: rotation.position, to: rotation.direction)
            } else if let move = ai.makeMove(gameState: gameState) {
                gameState.placeArrow(at: move.position, direction: move.direction)
            }
            
            isAIThinking = false
            
            if !gameState.gameEnded && gameState.currentPlayer == .b {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    makeAIMove()
                }
            }
        }
    }
}

struct GameBoardContainer: View {
    @ObservedObject var gameState: GameState
    @Binding var selectedPosition: Position?
    @Binding var showDirectionPicker: Bool
    let isInteractive: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        let availableHeight = geometry.size.height - 246
        let availableWidth = geometry.size.width - 40
        let boardSize = min(availableHeight, availableWidth)
        
        GameBoardView(
            gameState: gameState,
            selectedPosition: $selectedPosition,
            showDirectionPicker: $showDirectionPicker,
            isInteractive: isInteractive
        )
        .frame(width: boardSize, height: boardSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
