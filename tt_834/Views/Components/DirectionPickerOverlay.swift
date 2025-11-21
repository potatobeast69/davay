import SwiftUI

struct DirectionPickerOverlay: View {
    let position: Position
    @ObservedObject var gameState: GameState
    let onSelect: (Direction) -> Void
    let onCancel: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .blur(radius: 20)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scale = 0.8
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        onCancel()
                    }
                }
            
            VStack(spacing: 50) {
                Text("SELECT DIRECTION")
                    .font(.system(size: 18, weight: .semibold, design: .default))
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
                    .tracking(4)
                    .shadow(color: (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.5), radius: 10)
                    .frame(height: 24)
                
                DirectionWheel(
                    gameState: gameState,
                    rotation: rotation,
                    onSelect: { direction in
                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                        impactHeavy.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            scale = 0.8
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onSelect(direction)
                        }
                    }
                )
                .frame(width: 320, height: 320)
                
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scale = 0.8
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        onCancel()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 24, height: 24)
                        
                        Text("CANCEL")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .tracking(3)
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 200, height: 56)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.glassBackground)
                            
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.glassBorder,
                                            AppTheme.glassBorder.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                    )
                    .shadow(color: AppTheme.gridLineGlow.opacity(0.3), radius: 10)
                }
            }
            .padding(40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct DirectionWheel: View {
    @ObservedObject var gameState: GameState
    let rotation: Double
    let onSelect: (Direction) -> Void
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { ring in
                Circle()
                    .stroke(
                        AppTheme.gridLineGlow.opacity(0.15 - Double(ring) * 0.03),
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 8])
                    )
                    .frame(width: 140 + CGFloat(ring) * 60, height: 140 + CGFloat(ring) * 60)
                    .rotationEffect(.degrees(rotation + Double(ring * 90)))
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.2),
                            (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow,
                            (gameState.currentPlayer == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 280, height: 280)
                .shadow(
                    color: (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.6),
                    radius: 20
                )
            
            ForEach(Direction.allCases, id: \.self) { direction in
                DirectionButton(
                    direction: direction,
                    player: gameState.currentPlayer,
                    onTap: { onSelect(direction) }
                )
            }
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (gameState.currentPlayer == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent),
                                (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: (gameState.currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.8),
                        radius: 15
                    )
                
                Image(systemName: "location.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.background,
                                AppTheme.background.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }
}

struct DirectionButton: View {
    let direction: Direction
    let player: Player
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 180
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onTap()
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent),
                                (player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: (player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(isPressed ? 0.5 : 0.9),
                        radius: isPressed ? 8 : 15
                    )
                
                ZStack {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.background.opacity(0.4))
                        .offset(y: 2)
                    
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.background,
                                    AppTheme.background.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .rotationEffect(.degrees(direction.angle + rotation))
            }
        }
        .scaleEffect(isPressed ? 0.85 : scale)
        .offset(
            x: cos(direction.angle * .pi / 180 - .pi / 2) * 125,
            y: sin(direction.angle * .pi / 180 - .pi / 2) * 125
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(Double(direction.rawValue) * 0.05)) {
                scale = 1.0
                rotation = 0
            }
        }
    }
}
