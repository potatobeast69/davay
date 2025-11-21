import Foundation

enum Player: String, Codable {
    case a = "A"
    case b = "B"
    
    var opponent: Player {
        self == .a ? .b : .a
    }
}

enum Direction: Int, CaseIterable, Codable {
    case n = 0
    case ne = 1
    case e = 2
    case se = 3
    case s = 4
    case sw = 5
    case w = 6
    case nw = 7
    
    var offset: (dx: Int, dy: Int) {
        switch self {
        case .n: return (0, -1)
        case .ne: return (1, -1)
        case .e: return (1, 0)
        case .se: return (1, 1)
        case .s: return (0, 1)
        case .sw: return (-1, 1)
        case .w: return (-1, 0)
        case .nw: return (-1, -1)
        }
    }
    
    var angle: Double {
        Double(rawValue) * 45.0
    }
}

struct Position: Hashable, Codable {
    let x: Int
    let y: Int
    
    func isValid(gridSize: Int = 6) -> Bool {
        x >= 0 && x < gridSize && y >= 0 && y < gridSize
    }
    
    func moved(by direction: Direction) -> Position {
        let offset = direction.offset
        return Position(x: x + offset.dx, y: y + offset.dy)
    }
}

struct Arrow: Codable {
    let player: Player
    let position: Position
    let direction: Direction
    let moveIndex: Int
}

struct Edge: Hashable {
    let from: Position
    let to: Position
}

struct Cycle: Equatable {
    let positions: [Position]
    let player: Player
    let isStable: Bool
}

enum GameEvent: Codable {
    case arrowPlaced(player: Player, position: Position, direction: Direction, moveIndex: Int)
    case arrowRotated(player: Player, position: Position, newDirection: Direction, moveIndex: Int)
    case segmentsGassed(edges: [String])
    case cycleStabilized(player: Player, positions: [Position])
    case cycleDestroyed(player: Player, positions: [Position])
    case gameEnded(winner: Player?, reason: String)
    
    enum CodingKeys: String, CodingKey {
        case type, player, position, direction, moveIndex, edges, positions, winner, reason, newDirection
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "arrowPlaced":
            let player = try container.decode(Player.self, forKey: .player)
            let position = try container.decode(Position.self, forKey: .position)
            let direction = try container.decode(Direction.self, forKey: .direction)
            let moveIndex = try container.decode(Int.self, forKey: .moveIndex)
            self = .arrowPlaced(player: player, position: position, direction: direction, moveIndex: moveIndex)
        case "arrowRotated":
            let player = try container.decode(Player.self, forKey: .player)
            let position = try container.decode(Position.self, forKey: .position)
            let direction = try container.decode(Direction.self, forKey: .newDirection)
            let moveIndex = try container.decode(Int.self, forKey: .moveIndex)
            self = .arrowRotated(player: player, position: position, newDirection: direction, moveIndex: moveIndex)
        case "segmentsGassed":
            let edges = try container.decode([String].self, forKey: .edges)
            self = .segmentsGassed(edges: edges)
        case "cycleStabilized":
            let player = try container.decode(Player.self, forKey: .player)
            let positions = try container.decode([Position].self, forKey: .positions)
            self = .cycleStabilized(player: player, positions: positions)
        case "cycleDestroyed":
            let player = try container.decode(Player.self, forKey: .player)
            let positions = try container.decode([Position].self, forKey: .positions)
            self = .cycleDestroyed(player: player, positions: positions)
        case "gameEnded":
            let winner = try container.decodeIfPresent(Player.self, forKey: .winner)
            let reason = try container.decode(String.self, forKey: .reason)
            self = .gameEnded(winner: winner, reason: reason)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown event type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .arrowPlaced(let player, let position, let direction, let moveIndex):
            try container.encode("arrowPlaced", forKey: .type)
            try container.encode(player, forKey: .player)
            try container.encode(position, forKey: .position)
            try container.encode(direction, forKey: .direction)
            try container.encode(moveIndex, forKey: .moveIndex)
        case .arrowRotated(let player, let position, let direction, let moveIndex):
            try container.encode("arrowRotated", forKey: .type)
            try container.encode(player, forKey: .player)
            try container.encode(position, forKey: .position)
            try container.encode(direction, forKey: .newDirection)
            try container.encode(moveIndex, forKey: .moveIndex)
        case .segmentsGassed(let edges):
            try container.encode("segmentsGassed", forKey: .type)
            try container.encode(edges, forKey: .edges)
        case .cycleStabilized(let player, let positions):
            try container.encode("cycleStabilized", forKey: .type)
            try container.encode(player, forKey: .player)
            try container.encode(positions, forKey: .positions)
        case .cycleDestroyed(let player, let positions):
            try container.encode("cycleDestroyed", forKey: .type)
            try container.encode(player, forKey: .player)
            try container.encode(positions, forKey: .positions)
        case .gameEnded(let winner, let reason):
            try container.encode("gameEnded", forKey: .type)
            try container.encodeIfPresent(winner, forKey: .winner)
            try container.encode(reason, forKey: .reason)
        }
    }
}

struct GameStats: Codable {
    var cyclesCreated: [Player: Int] = [.a: 0, .b: 0]
    var cyclesDestroyed: [Player: Int] = [.a: 0, .b: 0]
    var territoryClaimed: [Player: Int] = [.a: 0, .b: 0]
    var segmentsGassed: Int = 0
    var rotationUsed: [Player: Bool] = [.a: false, .b: false]
    var totalMoves: Int = 0
}

enum GameMode {
    case practiceEasy
    case practiceMedium
    case practiceHard
    case localDuel
    case puzzle(Int)
    case blitz
}
