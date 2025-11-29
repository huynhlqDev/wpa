//
//  PipeType.swift
//  wpa
//
//  Created by huynh on 26/11/25.
//

import SwiftUI

struct Pipe: Identifiable, Codable {
    let id: UUID
    var type: PipeType

    /// Rotation 1, 2, 3, 4 theo chiều kim đồng hồ
    /// 1 = mặc định, 2 = 90°, 3 = 180°, 4 = 270°
    var rotation: Int = 1

    init(type: PipeType, rotation: Int = 1) {
        self.id = UUID()
        self.type = type
        self.rotation = rotation
    }
}

//MARK: - Extension rotate Clock wise method
extension Pipe {

    /// Hàm xoay ống theo chiều kim đồng hồ
    mutating func rotateClockwise() {
        // Công thức xoay vòng 1 → 2 → 3 → 4 → 1
        rotation = rotation % 4 + 1
    }
}

