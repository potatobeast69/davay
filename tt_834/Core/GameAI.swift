import Foundation

class GameAI {
    enum Difficulty {
        case easy
        case medium
        case hard
    }
    
    let difficulty: Difficulty
    let player: Player
    
    init(difficulty: Difficulty, player: Player) {
        self.difficulty = difficulty
        self.player = player
    }
    
    func makeMove(gameState: GameState) -> (position: Position, direction: Direction)? {
        let emptyCells = getEmptyCells(gameState: gameState)
        guard !emptyCells.isEmpty else { return nil }
        
        switch difficulty {
        case .easy:
            return makeEasyMove(emptyCells: emptyCells)
        case .medium:
            return makeMediumMove(gameState: gameState, emptyCells: emptyCells)
        case .hard:
            return makeHardMove(gameState: gameState, emptyCells: emptyCells)
        }
    }
    
    func shouldRotate(gameState: GameState) -> (position: Position, direction: Direction)? {
        guard gameState.rotationAvailable[player] == true else { return nil }
        
        switch difficulty {
        case .easy:
            return nil
        case .medium:
            if Double.random(in: 0...1) < 0.3 {
                return findRotationOpportunity(gameState: gameState)
            }
            return nil
        case .hard:
            return findBestRotation(gameState: gameState)
        }
    }
    
    private func getEmptyCells(gameState: GameState) -> [Position] {
        var empty: [Position] = []
        for y in 0..<6 {
            for x in 0..<6 {
                if gameState.grid[y][x] == nil {
                    empty.append(Position(x: x, y: y))
                }
            }
        }
        return empty
    }
    
    private func makeEasyMove(emptyCells: [Position]) -> (Position, Direction) {
        let position = emptyCells.randomElement()!
        let direction = Direction.allCases.randomElement()!
        return (position, direction)
    }
    
    private func makeMediumMove(gameState: GameState, emptyCells: [Position]) -> (Position, Direction) {
        if let move = tryCompleteCycle(gameState: gameState, emptyCells: emptyCells) {
            return move
        }
        
        if let move = tryBlockOpponent(gameState: gameState, emptyCells: emptyCells) {
            return move
        }
        
        if let move = tryBuildTowardsCycle(gameState: gameState, emptyCells: emptyCells) {
            return move
        }
        
        return makeEasyMove(emptyCells: emptyCells)
    }
    
    private func makeHardMove(gameState: GameState, emptyCells: [Position]) -> (Position, Direction) {
        let bestMove = findBestMove(gameState: gameState, emptyCells: emptyCells, depth: 2)
        return bestMove ?? makeMediumMove(gameState: gameState, emptyCells: emptyCells)
    }
    
    private func tryCompleteCycle(gameState: GameState, emptyCells: [Position]) -> (Position, Direction)? {
        let myArrows = getAllArrows(gameState: gameState, for: player)
        
        for emptyPos in emptyCells {
            for direction in Direction.allCases {
                let target = emptyPos.moved(by: direction)
                guard target.isValid() else { continue }
                
                if canFormCycle(from: emptyPos, to: target, arrows: myArrows, gameState: gameState) {
                    return (emptyPos, direction)
                }
            }
        }
        
        return nil
    }
    
    private func canFormCycle(from: Position, to: Position, arrows: [Arrow], gameState: GameState) -> Bool {
        var adjList: [Position: Position] = [:]
        
        for arrow in arrows {
            let targetPos = arrow.position.moved(by: arrow.direction)
            if targetPos.isValid() {
                adjList[arrow.position] = targetPos
            }
        }
        
        adjList[from] = to
        
        var visited = Set<Position>()
        var current = from
        var steps = 0
        
        while steps < 37 {
            if let next = adjList[current] {
                if next == from && steps >= 2 {
                    return true
                }
                
                if visited.contains(next) {
                    return false
                }
                
                visited.insert(current)
                current = next
                steps += 1
            } else {
                return false
            }
        }
        
        return false
    }
    
    private func tryBlockOpponent(gameState: GameState, emptyCells: [Position]) -> (Position, Direction)? {
        let opponent = player.opponent
        let opponentArrows = getAllArrows(gameState: gameState, for: opponent)
        
        for emptyPos in emptyCells {
            for direction in Direction.allCases {
                let target = emptyPos.moved(by: direction)
                guard target.isValid() else { continue }
                
                if wouldBlockCycle(from: emptyPos, to: target, opponentArrows: opponentArrows, gameState: gameState) {
                    return (emptyPos, direction)
                }
            }
        }
        
        return nil
    }
    
    private func wouldBlockCycle(from: Position, to: Position, opponentArrows: [Arrow], gameState: GameState) -> Bool {
        for arrow in opponentArrows {
            let arrowTarget = arrow.position.moved(by: arrow.direction)
            if arrowTarget.isValid() {
                let edge1 = (from: from, to: to)
                let edge2 = (from: arrow.position, to: arrowTarget)
                
                if wouldIntersect(edge1, edge2) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func wouldIntersect(_ e1: (from: Position, to: Position), _ e2: (from: Position, to: Position)) -> Bool {
        if e1.from == e2.from || e1.from == e2.to || e1.to == e2.from || e1.to == e2.to {
            return false
        }
        
        let p1 = CGPoint(x: Double(e1.from.x), y: Double(e1.from.y))
        let p2 = CGPoint(x: Double(e1.to.x), y: Double(e1.to.y))
        let p3 = CGPoint(x: Double(e2.from.x), y: Double(e2.from.y))
        let p4 = CGPoint(x: Double(e2.to.x), y: Double(e2.to.y))
        
        let d1 = direction(p3, p4, p1)
        let d2 = direction(p3, p4, p2)
        let d3 = direction(p1, p2, p3)
        let d4 = direction(p1, p2, p4)
        
        if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)) {
            return true
        }
        
        return false
    }
    
    private func direction(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> Double {
        return (p3.x - p1.x) * (p2.y - p1.y) - (p2.x - p1.x) * (p3.y - p1.y)
    }
    
    private func tryBuildTowardsCycle(gameState: GameState, emptyCells: [Position]) -> (Position, Direction)? {
        let myArrows = getAllArrows(gameState: gameState, for: player)
        
        for emptyPos in emptyCells {
            for direction in Direction.allCases {
                let target = emptyPos.moved(by: direction)
                guard target.isValid() else { continue }
                
                if hasArrowAt(position: target, arrows: myArrows) {
                    return (emptyPos, direction)
                }
                
                for arrow in myArrows {
                    if arrow.position.moved(by: arrow.direction) == emptyPos {
                        return (emptyPos, direction)
                    }
                }
            }
        }
        
        let centerPositions = [Position(x: 2, y: 2), Position(x: 3, y: 2), Position(x: 2, y: 3), Position(x: 3, y: 3)]
        for pos in centerPositions {
            if emptyCells.contains(where: { $0.x == pos.x && $0.y == pos.y }) {
                let direction = Direction.allCases.randomElement()!
                return (pos, direction)
            }
        }
        
        return nil
    }
    
    private func hasArrowAt(position: Position, arrows: [Arrow]) -> Bool {
        return arrows.contains { $0.position.x == position.x && $0.position.y == position.y }
    }
    
    private func getAllArrows(gameState: GameState, for player: Player) -> [Arrow] {
        var arrows: [Arrow] = []
        for row in gameState.grid {
            for arrow in row {
                if let arrow = arrow, arrow.player == player {
                    arrows.append(arrow)
                }
            }
        }
        return arrows
    }
    
    private func findBestMove(gameState: GameState, emptyCells: [Position], depth: Int) -> (Position, Direction)? {
        var bestMove: (Position, Direction)? = nil
        var bestScore = Int.min
        
        let movesToEvaluate = min(emptyCells.count * 3, 24)
        
        for _ in 0..<movesToEvaluate {
            let position = emptyCells.randomElement()!
            let direction = Direction.allCases.randomElement()!
            
            let score = evaluateMove(position: position, direction: direction, gameState: gameState, depth: depth)
            
            if score > bestScore {
                bestScore = score
                bestMove = (position, direction)
            }
        }
        
        return bestMove
    }
    
    private func evaluateMove(position: Position, direction: Direction, gameState: GameState, depth: Int) -> Int {
        var score = 0
        
        let myArrows = getAllArrows(gameState: gameState, for: player)
        let opponentArrows = getAllArrows(gameState: gameState, for: player.opponent)
        
        if canFormCycle(from: position, to: position.moved(by: direction), arrows: myArrows, gameState: gameState) {
            score += 100
        }
        
        if wouldBlockCycle(from: position, to: position.moved(by: direction), opponentArrows: opponentArrows, gameState: gameState) {
            score += 50
        }
        
        let target = position.moved(by: direction)
        if target.isValid() {
            if hasArrowAt(position: target, arrows: myArrows) {
                score += 20
            }
            
            for arrow in myArrows {
                if arrow.position.moved(by: arrow.direction).x == position.x &&
                   arrow.position.moved(by: arrow.direction).y == position.y {
                    score += 20
                }
            }
        }
        
        let centerPositions = [Position(x: 2, y: 2), Position(x: 3, y: 2), Position(x: 2, y: 3), Position(x: 3, y: 3)]
        if centerPositions.contains(where: { $0.x == position.x && $0.y == position.y }) {
            score += 10
        }
        
        score += Int.random(in: 0...5)
        
        return score
    }
    
    private func findRotationOpportunity(gameState: GameState) -> (Position, Direction)? {
        let myArrows = getAllArrows(gameState: gameState, for: player)
        
        for arrow in myArrows {
            for newDirection in Direction.allCases {
                if newDirection == arrow.direction { continue }
                
                if canFormCycle(from: arrow.position, to: arrow.position.moved(by: newDirection), arrows: myArrows.filter { $0.position != arrow.position }, gameState: gameState) {
                    return (arrow.position, newDirection)
                }
            }
        }
        
        return nil
    }
    
    private func findBestRotation(gameState: GameState) -> (Position, Direction)? {
        let myArrows = getAllArrows(gameState: gameState, for: player)
        var bestRotation: (Position, Direction)? = nil
        var bestScore = Int.min
        
        for arrow in myArrows {
            for newDirection in Direction.allCases {
                if newDirection == arrow.direction { continue }
                
                let score = evaluateMove(position: arrow.position, direction: newDirection, gameState: gameState, depth: 1)
                
                if score > bestScore {
                    bestScore = score
                    bestRotation = (arrow.position, newDirection)
                }
            }
        }
        
        return bestScore > 30 ? bestRotation : nil
    }
}
