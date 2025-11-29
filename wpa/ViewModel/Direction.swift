////
////  Direction.swift
////  wpa
////
////  Created by huynh on 28/11/25.
////
//
//
////
////  Direction.swift
////  WPA
////
////  Created by HuynhLQ on 28/11/25.
////
//
//import SwiftUI
//import Foundation
//import CoreGraphics
//
//// Hướng (direction) trên lưới: up/right/down/left
//enum Direction: CaseIterable {
//    case up, right, down, left
//
//    // dịch chuyển theo trục x (dx) cho mỗi hướng
//    var dx: Int {
//        switch self { case .left: return -1; case .right: return 1; default: return 0 }
//    }
//    // dịch chuyển theo trục y (dy) cho mỗi hướng
//    var dy: Int {
//        switch self { case .up: return -1; case .down: return 1; default: return 0 }
//    }
//    // hướng đối diện (ví dụ up.opposite() -> down)
//    func opposite() -> Direction {
//        switch self { case .up: return .down; case .down: return .up; case .left: return .right; case .right: return .left }
//    }
//}
//
//// Loại ô (tile) trong lưới
//enum TileType {
//    case empty         // ô trống
//    case straight      // ống thẳng (kết nối hai hướng đối diện)
//    case bend          // góc chữ L (kết nối hai hướng kề nhau)
//    case split3        // chia 3 nhánh
//    case split4        // chia 4 nhánh (tất cả)
//    case crossNoLink   // giao nhau nhưng không thông nối giữa trục ngang và trục dọc
//}
//
//// Mô tả 1 ô pipe: loại + rotation (0..3 tương ứng 0/90/180/270 độ)
//struct Tile {
//    var type: TileType
//    var rotation: Int = 0 // 0..3, bội số 90 độ
//    
//    // MARK: - Static factories
//    static func empty() -> Tile { Tile(type: .empty, rotation: 0) }
//    static func straight(_ rotation: Int = 0) -> Tile { Tile(type: .straight, rotation: rotation) }
//    static func bend(_ rotation: Int = 0) -> Tile { Tile(type: .bend, rotation: rotation) }
//    static func split3(_ rotation: Int = 0) -> Tile { Tile(type: .split3, rotation: rotation) }
//    static func split4(_ rotation: Int = 0) -> Tile { Tile(type: .split4, rotation: rotation) }
//    static func crossNoLink(_ rotation: Int = 0) -> Tile { Tile(type: .crossNoLink, rotation: rotation) }
//    
//    // Trả về tập các hướng (Direction) mà ô này kết nối (không phụ thuộc incoming)
//    func connections() -> Set<Direction> {
//        let r = (rotation % 4 + 4) % 4
//        switch type {
//        case .empty:
//            return []
//        case .straight:
//            // rotation 0: left-right; rotation 1: up-down (và luân phiên)
//            return r % 2 == 0 ? Set([.left, .right]) : Set([.up, .down])
//        case .bend:
//            // base (rotation 0) kết nối right + down
//            switch r {
//            case 0: return Set([.right, .down])
//            case 1: return Set([.down, .left])
//            case 2: return Set([.left, .up])
//            default: return Set([.up, .right])
//            }
//        case .split3:
//            // base: missing up -> kết nối left,right,down ở rotation 0
//            switch r {
//            case 0: return Set([.left, .right, .down])
//            case 1: return Set([.up, .left, .down])
//            case 2: return Set([.left, .right, .up])
//            default: return Set([.up, .right, .down])
//            }
//        case .split4:
//            // kết nối cả 4 hướng
//            return Set(Direction.allCases)
//        case .crossNoLink:
//            // để biểu diễn "giao nhau nhưng không nối" ta trả về cả 4 hướng,
//            // nhưng logic propagate sẽ xử lý special-case: nếu incoming ngang thì chỉ cho ngang,
//            // nếu incoming dọc thì chỉ cho dọc.
//            return Set(Direction.allCases)
//        }
//    }
//}
//
//// Vị trí trên lưới (x,y)
//struct GridPos: Hashable {
//    let x: Int, y: Int
//}
//
//// Kết quả exit: nước rời khỏi tile `pos` theo hướng `direction`
//struct Exit: Hashable {
//    let pos: GridPos
//    let direction: Direction
//}
//
//// Trạng thái kết hợp (pos + hướng incoming) dùng khi duyệt BFS/queue
//// Dùng struct để đảm bảo Hashable, tránh lặp vô hạn
//struct State: Hashable {
//    let pos: GridPos
//    // incoming = hướng từ đó nước đi vào ô này (ví dụ .left nghĩa nước đi từ trái vào)
//    // nil nghĩa nguồn (source) đặt ngay trong ô và không có hướng cụ thể
//    let incoming: Direction?
//}
//
//// Lớp quản lý lưới các tile/pipe và logic propagate (phân nhánh dòng chảy)
//class PipeGrid {
//    let width: Int, height: Int
//    private var tiles: [[Tile]]
//
//    // Khởi tạo grid với kích thước width x height, defaultTile mặc định (thường là .empty)
//    init(width: Int, height: Int, defaultTile: Tile = Tile(type: .empty)) {
//        self.width = width; self.height = height
//        tiles = Array(repeating: Array(repeating: defaultTile, count: width), count: height)
//    }
//
//    // Gán tile vào vị trí p (nếu nằm trong bounds)
//    func setTile(at p: GridPos, tile: Tile) {
//        guard inBounds(p) else { return }
//        tiles[p.y][p.x] = tile
//    }
//
//    // Lấy tile tại vị trí p (nếu ngoài bounds trả về nil)
//    func tile(at p: GridPos) -> Tile? {
//        guard inBounds(p) else { return nil }
//        return tiles[p.y][p.x]
//    }
//
//    // Kiểm tra nằm trong lưới
//    private func inBounds(_ p: GridPos) -> Bool {
//        return p.x >= 0 && p.x < width && p.y >= 0 && p.y < height
//    }
//
//    // Propagate: truyền một lượng `amount` nước bắt đầu tại tile `start`.
//    // `enterFrom` = hướng mà nước vào ô start (nil nếu nguồn nằm trong ô).
//    // Trả về dictionary mapping Exit -> tổng lượng đến exit đó.
//    func propagate(from start: GridPos, enterFrom: Direction?, amount: Double = 1.0) -> [Exit: Double] {
//        // hàng đợi BFS: mỗi phần tử là (state, amount)
//        var queue: [(State, Double)] = []
//        var visited = Set<State>() // tránh lặp vô hạn, đánh dấu đã xử lý state (pos + incoming)
//        var exits: [Exit: Double] = [:] // tích lũy lượng nước đến từng exit
//
//        queue.append((State(pos: start, incoming: enterFrom), amount))
//
//        while !queue.isEmpty {
//            let (state, amt) = queue.removeFirst()
//            let pos = state.pos
//            let incoming = state.incoming
//
//            // Lấy tile hiện tại; nếu nil => nước ra khỏi lưới tại vị trí này
//            guard let tile = tile(at: pos) else {
//                // Nếu không có tile ở vị trí, coi đó là exit: hướng out là opposite của incoming (nơi nước đi ra)
//                let outDir = incoming?.opposite() ?? .up
//                let e = Exit(pos: pos, direction: outDir)
//                exits[e, default: 0.0] += amt
//                continue
//            }
//
//            // Nếu đã xử lý (pos,incoming) trước đó thì bỏ qua
//            if visited.contains(state) { continue }
//            visited.insert(state)
//
//            // Lấy các kết nối vật lý của tile (các cổng mở)
//            var conns = tile.connections()
//
//            // Xử lý đặc biệt cho crossNoLink: nếu nước vào theo ngang thì chỉ cho ngang,
//            // nếu vào theo dọc thì chỉ cho dọc. (Tránh nối ngang->dọc)
//            if tile.type == .crossNoLink, let inc = incoming {
//                if inc == .left || inc == .right {
//                    conns = Set([.left, .right])
//                } else {
//                    conns = Set([.up, .down])
//                }
//            }
//
//            // Nếu có incoming, kiểm tra tile có chấp nhận incoming đó không
//            if let inc = incoming {
//                // Nếu tile không có cổng incoming (ví dụ nước đổ vô một mặt kín), thì coi đây là exit
//                if !conns.contains(inc) {
//                    let e = Exit(pos: pos, direction: inc)
//                    exits[e, default: 0.0] += amt
//                    continue
//                }
//            }
//
//            // Các output = tất cả connections trừ cổng nơi nước vừa vào (không đi ngược lại)
//            var outputs = conns
//            if let inc = incoming { outputs.remove(inc) }
//
//            // Nếu không còn output -> dead-end, xem như exit tại vị trí này
//            if outputs.isEmpty {
//                let outDir = incoming?.opposite() ?? .up
//                let e = Exit(pos: pos, direction: outDir)
//                exits[e, default: 0.0] += amt
//                continue
//            }
//
//            // Hiện tại chia đều lượng nước cho các outputs (có thể thay bằng trọng số nếu cần)
//            let splitAmt = amt / Double(outputs.count)
//            for out in outputs {
//                let nx = pos.x + out.dx
//                let ny = pos.y + out.dy
//                let npos = GridPos(x: nx, y: ny)
//
//                // Nếu có neighbor tile
//                if let neighbor = self.tile(at: npos) {
//                    // Kiểm tra neighbor có cổng tương ứng (opposite of out) để nhận nước không
//                    var neighborConns = neighbor.connections()
//                    if neighbor.type == .crossNoLink {
//                        // neighbor cross đặc biệt: nếu incoming tới neighbor là ngang thì giữ ngang, ngược lại giữ dọc
//                        neighborConns = (out.opposite() == .left || out.opposite() == .right) ? Set([.left, .right]) : Set([.up, .down])
//                    }
//                    // Nếu neighbor chấp nhận incoming, enqueue tiếp
//                    if neighborConns.contains(out.opposite()) {
//                        queue.append((State(pos: npos, incoming: out.opposite()), splitAmt))
//                    } else {
//                        // Nếu neighbor không kết nối ngược lại -> output này kết thúc tại tile hiện tại
//                        let e = Exit(pos: pos, direction: out)
//                        exits[e, default: 0.0] += splitAmt
//                    }
//                } else {
//                    // Ra khỏi lưới -> coi là exit
//                    let e = Exit(pos: pos, direction: out)
//                    exits[e, default: 0.0] += splitAmt
//                }
//            }
//        }
//
//        return exits
//    }
//}
//
//// --------------------------
//// Ví dụ sử dụng / test nhanh
//// --------------------------
//func exampleTest() {
//    // Tạo lưới 5x3
//    let grid = PipeGrid(width: 5, height: 3)
//    let straightH = Tile(type: .straight, rotation: 0) // left-right
//    let straightV = Tile(type: .straight, rotation: 1) // up-down
//    let split3 = Tile(type: .split3, rotation: 0)      // base connect left,right,down
//    let cross = Tile(type: .crossNoLink, rotation: 0)  // giao nhau (không thông)
//
//    // Đặt một vài tile mẫu lên lưới
//    grid.setTile(at: GridPos(x: 1, y: 1), tile: straightH)
//    grid.setTile(at: GridPos(x: 2, y: 1), tile: split3)
//    grid.setTile(at: GridPos(x: 3, y: 1), tile: straightH)
//    grid.setTile(at: GridPos(x: 2, y: 0), tile: straightV)
//    grid.setTile(at: GridPos(x: 2, y: 2), tile: straightV)
//
//    // Truyền nước vào ô (1,1) từ hướng trái (tức nước đến ô này từ ô bên trái)
//    let results = grid.propagate(from: GridPos(x: 1, y: 1), enterFrom: .left, amount: 1.0)
//
//    // In kết quả: vị trí exit và lượng đến exit đó
//    for (exit, amt) in results {
//        print("Exit tại tile (\(exit.pos.x),\(exit.pos.y)) theo hướng \(exit.direction) nhận lượng = \(amt)")
//    }
//}
//
//// Chạy ví dụ
//
