//
//  FlowLogic.swift
//  wpa
//
//  Created by huynh on 26/11/25.
//

// Mỗi loại là 1 hình dạng riêng biệt để dễ xử lý logic & animation
enum PipeType: String, Codable, CaseIterable {
    // Ống thẳng (2 loại tách riêng)
    case straightHorizontal   // Ống thẳng nằm ngang
    case straightVertical     // Ống thẳng đứng dọc

    // Ống góc (4 loại, mỗi loại 1 hướng cụ thể)
    case cornerTopRight       // Cong từ trên → phải
    case cornerRightBottom    // Cong từ phải → dưới
    case cornerBottomLeft     // Cong từ dưới → trái
    case cornerLeftTop        // Cong từ trái → trên

    // Ống chia 3 nhánh (mỗi loại thiếu 1 nhánh)
    case teeUpMissing         // Thiếu nhánh trên
    case teeRightMissing      // Thiếu nhánh phải
    case teeDownMissing       // Thiếu nhánh dưới
    case teeLeftMissing       // Thiếu nhánh trái

    // Ống chia 4 nhánh (+)
    case cross

    // Ống blocker (X) — không thông nước
    case blocker
}
