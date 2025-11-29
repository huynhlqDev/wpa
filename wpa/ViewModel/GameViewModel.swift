////
////  GameViewModel.swift
////  wpa
////
////  Created by huynh on 26/11/25.
////
//
//import Foundation
//import Combine
//import SwiftUI // Cần cho @Published và Color (nếu bạn muốn dùng nó trong VM)
//
//class GameViewModel: ObservableObject {
//    @Published var map: [[Cell]]
//    @Published var pipeQueue: [PipeType]
//    @Published var isGameWon: Bool = false
//    
//    let size: Int = 5
//    let startPos: (r: Int, c: Int)
//    let endPos: (r: Int, c: Int)
//    
//    init() {
//        self.startPos = (0, 2)
//        self.endPos = (size - 1, 2)
//        let mapSize = self.size
//        var initialMap: [[Cell]] = (0..<mapSize).map { r in
//            (0..<mapSize).map { c in
//                Cell(pipeType: .empty, rotation: 0, r: r, c: c)
//            }
//        }
//        initialMap[startPos.r][startPos.c].pipeType = .start
//        initialMap[endPos.r][endPos.c].pipeType = .end
//        
//        self.map = initialMap
//        self.pipeQueue = GameViewModel.generatePipes(5)
//    }
//    
//    // MARK: - Pipe Generation
//    private static func generatePipes(_ count: Int) -> [PipeType] {
//        let availablePipes: [PipeType] = [.straight, .corner, .threeWay, .cross]
//        return (0..<count).map { _ in availablePipes.randomElement()! }
//    }
//    
//    // MARK: - User Actions (Called by View)
//    
//    func placePipe(pipeType: PipeType, r: Int, c: Int) {
//        guard r >= 0, r < size, c >= 0, c < size, map[r][c].pipeType == .empty else {
//            return
//        }
//        
//        // 1. Cập nhật Model (map)
//        map[r][c].pipeType = pipeType
//        map[r][c].rotation = 0
//        
//        // 2. Cập nhật Queue
//        if let index = pipeQueue.firstIndex(of: pipeType) {
//            pipeQueue.remove(at: index) 
//            pipeQueue.append(GameViewModel.generatePipes(1).first!)
//        }
//        
//        // 3. Kích hoạt logic dòng chảy
//        checkFlow()
//    }
//    
//    func rotatePipe(r: Int, c: Int) {
//        // Chỉ xoay ống đã đặt
//        guard map[r][c].pipeType != .empty && map[r][c].pipeType != .start && map[r][c].pipeType != .end else {
//            return
//        }
//        
//        // Cập nhật Model (map)
//        map[r][c].rotation = (map[r][c].rotation + 1) % 4
//        
//        // Kích hoạt logic dòng chảy
//        checkFlow()
//    }
//    
//    // MARK: - Core Logic (Flow Simulation - BFS)
//    
//    private func checkFlow() {
//        var newMap = self.map // Tạo bản sao để sửa đổi
//        var q: [(r: Int, c: Int)] = [startPos]
//        var visited = Set<String>()
//        var flowReachedEnd = false
//        
//        // Reset trạng thái isFlowing
//        for r in 0..<size {
//            for c in 0..<size {
//                newMap[r][c].isFlowing = false
//            }
//        }
//        newMap[startPos.r][startPos.c].isFlowing = true
//        visited.insert("\(startPos.r),\(startPos.c)")
//
//        while !q.isEmpty {
//            let (r, c) = q.removeFirst() // Deque
//            let currentCell = newMap[r][c]
//            
//            // Lấy các cổng mở hiện tại (sử dụng Model/Logic helper)
//            let ports = rotatePorts(basePorts: currentCell.pipeType.basePorts, rotation: currentCell.rotation)
//            
//            for port in ports {
//                guard let (dr, dc) = DIRECTIONS[port],
//                      let oppositePort = OPPOSITE_PORT[port] else { continue }
//                
//                let (nr, nc) = (r + dr, c + dc)
//                let key = "\(nr),\(nc)"
//                
//                // 1. Kiểm tra biên
//                guard nr >= 0, nr < size, nc >= 0, nc < size else { continue }
//                
//                let neighborCell = newMap[nr][nc]
//                let neighborPorts = rotatePorts(basePorts: neighborCell.pipeType.basePorts, rotation: neighborCell.rotation)
//                
//                // 2. Kiểm tra Kết nối Hợp lệ: Cổng đối diện phải mở
//                if neighborPorts.contains(oppositePort) {
//                    
//                    // 3. Điều kiện Thắng
//                    if neighborCell.pipeType == .end {
//                        flowReachedEnd = true
//                        break 
//                    }
//                    
//                    // 4. Thăm ô mới
//                    if !visited.contains(key) {
//                        visited.insert(key)
//                        newMap[nr][nc].isFlowing = true
//                        q.append((nr, nc))
//                    }
//                }
//            }
//            if flowReachedEnd { break }
//        }
//        
//        // Cập nhật lại trạng thái Flowing cho tất cả các ô đã được thăm
//        for key in visited {
//             let parts = key.split(separator: ",").compactMap { Int($0) }
//             if parts.count == 2 {
//                 newMap[parts[0]][parts[1]].isFlowing = true
//             }
//         }
//        
//        // Cập nhật @Published properties
//        self.map = newMap
//        self.isGameWon = flowReachedEnd
//    }
//}
