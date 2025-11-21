import Foundation
import Combine

class GameState: ObservableObject {
    @Published var grid: [[Arrow?]] = Array(repeating: Array(repeating: nil, count: 6), count: 6)
    @Published var currentPlayer: Player = .a
    @Published var moveNumber: Int = 0
    @Published var events: [GameEvent] = []
    @Published var cycles: [Player: [Cycle]] = [.a: [], .b: []]
    @Published var gashedEdges: Set<Edge> = []
    @Published var rotationAvailable: [Player: Bool] = [.a: true, .b: true]
    @Published var stats: GameStats = GameStats()
    @Published var gameEnded: Bool = false
    @Published var winner: Player? = nil
    @Published var endReason: String = ""
    @Published var territories: [Player: Set<Position>] = [.a: [], .b: []]
    
    let mode: GameMode
    let maxMoves: Int
    
    init(mode: GameMode) {
        self.mode = mode
        switch mode {
        case .blitz:
            self.maxMoves = 16
        default:
            self.maxMoves = 24
        }
    }
    
    func placeArrow(at position: Position, direction: Direction) {
        guard !gameEnded else { return }
        guard grid[position.y][position.x] == nil else { return }
        
        let arrow = Arrow(player: currentPlayer, position: position, direction: direction, moveIndex: moveNumber)
        grid[position.y][position.x] = arrow
        
        let event = GameEvent.arrowPlaced(player: currentPlayer, position: position, direction: direction, moveIndex: moveNumber)
        events.append(event)
        
        moveNumber += 1
        stats.totalMoves += 1
        
        processGameLogic()
        
        if !gameEnded {
            currentPlayer = currentPlayer.opponent
        }
        
        checkGameEnd()
    }
    
    func rotateArrow(at position: Position, to direction: Direction) {
        guard !gameEnded else { return }
        guard let arrow = grid[position.y][position.x], arrow.player == currentPlayer else { return }
        guard rotationAvailable[currentPlayer] == true else { return }
        
        let newArrow = Arrow(player: currentPlayer, position: position, direction: direction, moveIndex: moveNumber)
        grid[position.y][position.x] = newArrow
        
        let event = GameEvent.arrowRotated(player: currentPlayer, position: position, newDirection: direction, moveIndex: moveNumber)
        events.append(event)
        
        rotationAvailable[currentPlayer] = false
        stats.rotationUsed[currentPlayer] = true
        
        moveNumber += 1
        stats.totalMoves += 1
        
        processGameLogic()
        
        if !gameEnded {
            currentPlayer = currentPlayer.opponent
        }
        
        checkGameEnd()
    }
    
    private func processGameLogic() {
        detectCycles()
        detectIntersections()
        detectCycles()
        updateTerritories()
    }
    
    private func detectCycles() {
        for player in [Player.a, Player.b] {
            let playerArrows = getAllArrows(for: player)
            let newCycles = findCycles(from: playerArrows, player: player)
            
            let oldCycleCount = cycles[player]?.count ?? 0
            cycles[player] = newCycles
            
            if newCycles.count > oldCycleCount {
                stats.cyclesCreated[player, default: 0] += (newCycles.count - oldCycleCount)
            } else if newCycles.count < oldCycleCount {
                stats.cyclesDestroyed[player, default: 0] += (oldCycleCount - newCycles.count)
            }
        }
    }
    
    private func getAllArrows(for player: Player) -> [Arrow] {
        var arrows: [Arrow] = []
        for row in grid {
            for arrow in row {
                if let arrow = arrow, arrow.player == player {
                    arrows.append(arrow)
                }
            }
        }
        return arrows
    }
    
    private func findCycles(from arrows: [Arrow], player: Player) -> [Cycle] {
        var adjList: [Position: Position] = [:]
        
        for arrow in arrows {
            let target = arrow.position.moved(by: arrow.direction)
            if target.isValid() {
                adjList[arrow.position] = target
            }
        }
        
        var visited = Set<Position>()
        var cycles: [Cycle] = []
        
        for arrow in arrows {
            if visited.contains(arrow.position) { continue }
            
            var path: [Position] = []
            var current = arrow.position
            var localVisited = Set<Position>()
            
            while let next = adjList[current] {
                if localVisited.contains(next) {
                    if let cycleStart = path.firstIndex(of: next) {
                        let cyclePositions = Array(path[cycleStart...])
                        let isStable = isCycleStable(positions: cyclePositions)
                        cycles.append(Cycle(positions: cyclePositions, player: player, isStable: isStable))
                        visited.formUnion(cyclePositions)
                    }
                    break
                }
                
                path.append(current)
                localVisited.insert(current)
                current = next
                
                if path.count > 36 { break }
            }
        }
        
        return cycles
    }
    
    private func isCycleStable(positions: [Position]) -> Bool {
        for i in 0..<positions.count {
            let from = positions[i]
            let to = positions[(i + 1) % positions.count]
            let edge = Edge(from: from, to: to)
            if gashedEdges.contains(edge) {
                return false
            }
        }
        return true
    }
    
    private func detectIntersections() {
        var allEdges: [(Edge, Player)] = []
        
        for row in grid {
            for arrow in row {
                if let arrow = arrow {
                    let target = arrow.position.moved(by: arrow.direction)
                    if target.isValid() {
                        allEdges.append((Edge(from: arrow.position, to: target), arrow.player))
                    }
                }
            }
        }
        
        for i in 0..<allEdges.count {
            for j in (i+1)..<allEdges.count {
                let (edge1, _) = allEdges[i]
                let (edge2, _) = allEdges[j]
                
                if edge1.from != edge2.from && edge1.from != edge2.to &&
                   edge1.to != edge2.from && edge1.to != edge2.to {
                    if segmentsIntersect(edge1, edge2) {
                        gashedEdges.insert(edge1)
                        gashedEdges.insert(edge2)
                    }
                }
            }
        }
    }
    
    private func segmentsIntersect(_ e1: Edge, _ e2: Edge) -> Bool {
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
    
    private func updateTerritories() {
        territories[.a] = []
        territories[.b] = []
        
        for player in [Player.a, Player.b] {
            guard let playerCycles = cycles[player] else { continue }
            
            for cycle in playerCycles where cycle.isStable {
                let territory = findTerritory(cycle: cycle)
                territories[player]?.formUnion(territory)
            }
        }
        
        stats.territoryClaimed[.a] = territories[.a]?.count ?? 0
        stats.territoryClaimed[.b] = territories[.b]?.count ?? 0
    }
    
    private func findTerritory(cycle: Cycle) -> Set<Position> {
        var territory = Set<Position>()
        
        let minX = cycle.positions.map { $0.x }.min() ?? 0
        let maxX = cycle.positions.map { $0.x }.max() ?? 5
        let minY = cycle.positions.map { $0.y }.min() ?? 0
        let maxY = cycle.positions.map { $0.y }.max() ?? 5
        
        for y in minY...maxY {
            for x in minX...maxX {
                let pos = Position(x: x, y: y)
                if isInsideCycle(position: pos, cycle: cycle) {
                    territory.insert(pos)
                }
            }
        }
        
        return territory
    }
    
    private func isInsideCycle(position: Position, cycle: Cycle) -> Bool {
        let point = CGPoint(x: Double(position.x), y: Double(position.y))
        var intersections = 0
        
        for i in 0..<cycle.positions.count {
            let p1 = cycle.positions[i]
            let p2 = cycle.positions[(i + 1) % cycle.positions.count]
            
            let point1 = CGPoint(x: Double(p1.x), y: Double(p1.y))
            let point2 = CGPoint(x: Double(p2.x), y: Double(p2.y))
            
            if rayIntersectsSegment(point: point, p1: point1, p2: point2) {
                intersections += 1
            }
        }
        
        return intersections % 2 == 1
    }
    
    private func rayIntersectsSegment(point: CGPoint, p1: CGPoint, p2: CGPoint) -> Bool {
        if p1.y > p2.y {
            return rayIntersectsSegment(point: point, p1: p2, p2: p1)
        }
        
        if point.y < p1.y || point.y > p2.y || point.x > max(p1.x, p2.x) {
            return false
        }
        
        if point.x < min(p1.x, p2.x) {
            return true
        }
        
        let red = (point.y - p1.y) / (point.x - p1.x)
        let blue = (p2.y - p1.y) / (p2.x - p1.x)
        
        return red >= blue
    }
    
    private func checkGameEnd() {
        let aCycles = cycles[.a]?.filter { $0.isStable }.count ?? 0
        let bCycles = cycles[.b]?.filter { $0.isStable }.count ?? 0
        
        if aCycles >= 3 {
            endGame(winner: .a, reason: "3 stable cycles achieved")
            return
        }
        
        if bCycles >= 3 {
            endGame(winner: .b, reason: "3 stable cycles achieved")
            return
        }
        
        if moveNumber >= maxMoves {
            let aScore = calculateScore(for: .a)
            let bScore = calculateScore(for: .b)
            
            if aScore > bScore {
                endGame(winner: .a, reason: "Higher score")
            } else if bScore > aScore {
                endGame(winner: .b, reason: "Higher score")
            } else {
                endGame(winner: nil, reason: "Draw")
            }
        }
    }
    
    func calculateScore(for player: Player) -> Int {
        let stableCycles = cycles[player]?.filter { $0.isStable }.count ?? 0
        let territory = territories[player]?.count ?? 0
        let centerControl = territories[player]?.contains(Position(x: 3, y: 3)) == true ? 1 : 0
        
        return stableCycles * 2 + territory / 3 + centerControl
    }
    
    private func endGame(winner: Player?, reason: String) {
        gameEnded = true
        self.winner = winner
        self.endReason = reason
        events.append(.gameEnded(winner: winner, reason: reason))
    }
    
    func canUndo() -> Bool {
        return moveNumber > 0 && !gameEnded
    }
    
    func undo() {
        guard canUndo() else { return }
        
        moveNumber -= 1
        stats.totalMoves -= 1
        
        for y in 0..<6 {
            for x in 0..<6 {
                if let arrow = grid[y][x], arrow.moveIndex == moveNumber {
                    grid[y][x] = nil
                }
            }
        }
        
        if !events.isEmpty {
            events.removeLast()
        }
        
        currentPlayer = currentPlayer.opponent
        processGameLogic()
    }
}
