import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    @Binding var selectedPosition: Position?
    @Binding var showDirectionPicker: Bool
    let isInteractive: Bool
    
    @State private var pulseAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = size / 6
            
            ZStack {
                BoardGlowEffect(cellSize: cellSize, pulse: pulseAnimation)
                
                GridView(cellSize: cellSize)
                
                TerritoryView(gameState: gameState, cellSize: cellSize)
                
                EdgesView(gameState: gameState, cellSize: cellSize)
                
                CyclesView(gameState: gameState, cellSize: cellSize)
                
                NodesView(cellSize: cellSize, pulse: pulseAnimation)
                
                ArrowsView(
                    gameState: gameState,
                    cellSize: cellSize,
                    selectedPosition: $selectedPosition,
                    showDirectionPicker: $showDirectionPicker,
                    isInteractive: isInteractive
                )
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation.toggle()
            }
        }
    }
}

struct BoardGlowEffect: View {
    let cellSize: CGFloat
    let pulse: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.gridNodeGlow.opacity(0.08),
                            AppTheme.gridNodeGlow.opacity(0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: cellSize * 4
                    )
                )
                .frame(width: cellSize * 6, height: cellSize * 6)
                .blur(radius: 40)
                .scaleEffect(pulse ? 1.1 : 1.0)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.glassBackground)
                .frame(width: cellSize * 6, height: cellSize * 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
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
                )
                .shadow(color: AppTheme.gridNodeGlow.opacity(0.2), radius: 20)
        }
    }
}

struct GridView: View {
    let cellSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            var gridPath = Path()
            
            for i in 0...6 {
                let pos = CGFloat(i) * cellSize
                gridPath.move(to: CGPoint(x: pos, y: 0))
                gridPath.addLine(to: CGPoint(x: pos, y: cellSize * 6))
                gridPath.move(to: CGPoint(x: 0, y: pos))
                gridPath.addLine(to: CGPoint(x: cellSize * 6, y: pos))
            }
            
            context.stroke(gridPath, with: .color(AppTheme.gridLine.opacity(0.4)), lineWidth: 1)
            
            var centerPath = Path()
            let centerPos = cellSize * 3
            centerPath.move(to: CGPoint(x: centerPos, y: 0))
            centerPath.addLine(to: CGPoint(x: centerPos, y: cellSize * 6))
            centerPath.move(to: CGPoint(x: 0, y: centerPos))
            centerPath.addLine(to: CGPoint(x: cellSize * 6, y: centerPos))
            
            context.stroke(centerPath, with: .color(AppTheme.gridLineGlow.opacity(0.6)), lineWidth: 2)
            
            var borderPath = Path()
            borderPath.addRoundedRect(in: CGRect(x: 0, y: 0, width: cellSize * 6, height: cellSize * 6), cornerSize: CGSize(width: 16, height: 16))
            context.stroke(borderPath, with: .color(AppTheme.gridNodeGlow.opacity(0.5)), lineWidth: 2)
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct NodesView: View {
    let cellSize: CGFloat
    let pulse: Bool
    
    var body: some View {
        Canvas { context, size in
            for y in 0..<7 {
                for x in 0..<7 {
                    let isCenter = (x >= 2 && x <= 4) && (y >= 2 && y <= 4)
                    let nodeSize: CGFloat = isCenter ? 8 : 5
                    let glowSize: CGFloat = isCenter ? 20 : 14
                    let pulseMultiplier: CGFloat = pulse ? 1.2 : 1.0
                    
                    let point = CGPoint(
                        x: CGFloat(x) * cellSize,
                        y: CGFloat(y) * cellSize
                    )
                    
                    var glowPath = Path()
                    glowPath.addEllipse(in: CGRect(x: point.x - glowSize/2 * pulseMultiplier, y: point.y - glowSize/2 * pulseMultiplier, width: glowSize * pulseMultiplier, height: glowSize * pulseMultiplier))
                    context.fill(glowPath, with: .color(AppTheme.gridNodeGlow.opacity(isCenter ? 0.4 : 0.2)))
                    
                    var nodePath = Path()
                    nodePath.addEllipse(in: CGRect(x: point.x - nodeSize/2, y: point.y - nodeSize/2, width: nodeSize, height: nodeSize))
                    
                    let gradient = Gradient(colors: [
                        AppTheme.gridNode,
                        AppTheme.gridNodeGlow
                    ])
                    context.fill(nodePath, with: .linearGradient(gradient, startPoint: CGPoint(x: point.x - nodeSize/2, y: point.y - nodeSize/2), endPoint: CGPoint(x: point.x + nodeSize/2, y: point.y + nodeSize/2)))
                    
                    var highlightPath = Path()
                    highlightPath.addEllipse(in: CGRect(x: point.x - nodeSize/3, y: point.y - nodeSize/3, width: nodeSize/1.5, height: nodeSize/1.5))
                    context.fill(highlightPath, with: .color(Color.white.opacity(0.6)))
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct TerritoryView: View {
    @ObservedObject var gameState: GameState
    let cellSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            for player in [Player.a, Player.b] {
                guard let territory = gameState.territories[player] else { continue }
                
                for position in territory {
                    let rect = CGRect(
                        x: CGFloat(position.x) * cellSize + 3,
                        y: CGFloat(position.y) * cellSize + 3,
                        width: cellSize - 6,
                        height: cellSize - 6
                    )
                    
                    var glowPath = Path(roundedRect: rect.insetBy(dx: -4, dy: -4), cornerRadius: 10)
                    let glowColor = player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow
                    context.fill(glowPath, with: .color(glowColor.opacity(0.15)))
                    
                    var path = Path(roundedRect: rect, cornerRadius: 8)
                    let gradient = Gradient(colors: [
                        (player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.25),
                        (player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.15)
                    ])
                    context.fill(path, with: .linearGradient(gradient, startPoint: CGPoint(x: rect.minX, y: rect.minY), endPoint: CGPoint(x: rect.maxX, y: rect.maxY)))
                    
                    context.stroke(path, with: .color((player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.5)), lineWidth: 1.5)
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct EdgesView: View {
    @ObservedObject var gameState: GameState
    let cellSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            for y in 0..<6 {
                for x in 0..<6 {
                    guard let arrow = gameState.grid[y][x] else { continue }
                    
                    let from = Position(x: x, y: y)
                    let to = from.moved(by: arrow.direction)
                    
                    guard to.isValid() else { continue }
                    
                    let edge = Edge(from: from, to: to)
                    let isGashed = gameState.gashedEdges.contains(edge)
                    
                    let start = CGPoint(
                        x: CGFloat(from.x) * cellSize + cellSize / 2,
                        y: CGFloat(from.y) * cellSize + cellSize / 2
                    )
                    let end = CGPoint(
                        x: CGFloat(to.x) * cellSize + cellSize / 2,
                        y: CGFloat(to.y) * cellSize + cellSize / 2
                    )
                    
                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)
                    
                    let baseColor = arrow.player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent
                    let glowColor = arrow.player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow
                    
                    if !isGashed {
                        context.stroke(path, with: .color(glowColor.opacity(0.4)), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        context.stroke(path, with: .color(glowColor.opacity(0.6)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    }
                    
                    let gradient = Gradient(colors: [
                        isGashed ? AppTheme.graphite.opacity(0.4) : baseColor,
                        isGashed ? AppTheme.graphite.opacity(0.3) : glowColor
                    ])
                    
                    context.stroke(
                        path,
                        with: .linearGradient(gradient, startPoint: start, endPoint: end),
                        style: StrokeStyle(lineWidth: isGashed ? 2 : 3, lineCap: .round)
                    )
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct CyclesView: View {
    @ObservedObject var gameState: GameState
    let cellSize: CGFloat
    
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            for player in [Player.a, Player.b] {
                guard let cycles = gameState.cycles[player] else { continue }
                
                for cycle in cycles where cycle.isStable && cycle.positions.count > 2 {
                    var path = Path()
                    
                    let firstPoint = CGPoint(
                        x: CGFloat(cycle.positions[0].x) * cellSize + cellSize / 2,
                        y: CGFloat(cycle.positions[0].y) * cellSize + cellSize / 2
                    )
                    path.move(to: firstPoint)
                    
                    for position in cycle.positions.dropFirst() {
                        let point = CGPoint(
                            x: CGFloat(position.x) * cellSize + cellSize / 2,
                            y: CGFloat(position.y) * cellSize + cellSize / 2
                        )
                        path.addLine(to: point)
                    }
                    
                    path.closeSubpath()
                    
                    let glowColor = player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow
                    let baseColor = player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent
                    
                    context.stroke(path, with: .color(glowColor.opacity(0.5)), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    context.stroke(path, with: .color(baseColor.opacity(0.8)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    context.stroke(path, with: .color(Color.white.opacity(0.3)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [8, 8], dashPhase: dashPhase))
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                dashPhase = 16
            }
        }
    }
}

struct ArrowsView: View {
    @ObservedObject var gameState: GameState
    let cellSize: CGFloat
    @Binding var selectedPosition: Position?
    @Binding var showDirectionPicker: Bool
    let isInteractive: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { y in
                ForEach(0..<6, id: \.self) { x in
                    let position = Position(x: x, y: y)
                    
                    if let arrow = gameState.grid[y][x] {
                        ArrowNode(
                            arrow: arrow,
                            cellSize: cellSize,
                            isSelected: selectedPosition == position,
                            isInteractive: isInteractive,
                            onTap: {
                                if isInteractive && arrow.player == gameState.currentPlayer {
                                    selectedPosition = position
                                    if gameState.rotationAvailable[gameState.currentPlayer] == true {
                                        showDirectionPicker = true
                                    }
                                }
                            }
                        )
                    } else {
                        EmptyCell(
                            position: position,
                            cellSize: cellSize,
                            isInteractive: isInteractive,
                            currentPlayer: gameState.currentPlayer,
                            onTap: {
                                if isInteractive {
                                    selectedPosition = position
                                    showDirectionPicker = true
                                }
                            }
                        )
                    }
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct ArrowNode: View {
    let arrow: Arrow
    let cellSize: CGFloat
    let isSelected: Bool
    let isInteractive: Bool
    let onTap: () -> Void
    
    @State private var rotationAnim: Double = 0
    @State private var pulseAnim: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            onTap()
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (arrow.player == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent),
                                (arrow.player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: cellSize * 0.25
                        )
                    )
                    .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: (arrow.player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.8), radius: 12)
                
                if isSelected {
                    Circle()
                        .stroke(arrow.player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow, lineWidth: 3)
                        .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                        .shadow(color: arrow.player == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow, radius: 10)
                        .scaleEffect(pulseAnim)
                }
                
                ZStack {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: cellSize * 0.32, weight: .bold))
                        .foregroundColor(AppTheme.background.opacity(0.3))
                        .offset(y: 2)
                    
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: cellSize * 0.3, weight: .semibold))
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
                .rotationEffect(.degrees(arrow.direction.angle + rotationAnim))
            }
        }
        .disabled(!isInteractive)
        .position(
            x: CGFloat(arrow.position.x) * cellSize + cellSize / 2,
            y: CGFloat(arrow.position.y) * cellSize + cellSize / 2
        )
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                rotationAnim = 0
            }
            
            if isSelected {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    pulseAnim = 1.2
                }
            }
        }
    }
}

struct EmptyCell: View {
    let position: Position
    let cellSize: CGFloat
    let isInteractive: Bool
    let currentPlayer: Player
    let onTap: () -> Void
    
    @State private var pulseAnim: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            onTap()
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }) {
            ZStack {
                if isInteractive {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.2),
                                    (currentPlayer == .a ? AppTheme.playerAGlow : AppTheme.playerBGlow).opacity(0.05)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: cellSize * 0.2
                            )
                        )
                        .frame(width: cellSize * 0.4, height: cellSize * 0.4)
                        .scaleEffect(pulseAnim)
                    
                    Circle()
                        .stroke((currentPlayer == .a ? AppTheme.playerAAccent : AppTheme.playerBAccent).opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: cellSize * 0.35, height: cellSize * 0.35)
                }
            }
        }
        .disabled(!isInteractive)
        .position(
            x: CGFloat(position.x) * cellSize + cellSize / 2,
            y: CGFloat(position.y) * cellSize + cellSize / 2
        )
        .onAppear {
            if isInteractive {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseAnim = 1.2
                }
            }
        }
    }
}


