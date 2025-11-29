//
//  PipeShape.swift
//  wpa
//
//  Created by huynh on 28/11/25.
//

import SwiftUI

/// Shape để vẽ đường đi của ống nước dựa trên loại + hướng
/// Shape này dùng để:
/// - Vẽ ống
/// - Vẽ đường nước chảy theo path (trim)
struct PipeShape: Shape {

    /// Loại ống
    let type: PipeType
    /// Hướng xoay 1–4
    let rotation: Int

    func path(in rect: CGRect) -> Path {
        var p = Path()

        /// Kích thước cơ bản
        let w = rect.width
        let h = rect.height
        let midX = w/2
        let midY = h/2

        /// Độ dày của đường ống (tỷ lệ theo kích thước ô)
        let thickness: CGFloat = w * 0.25

        /// Vẽ ống thẳng ngang
        func addStraightHorizontal() {
            p.addRect(CGRect(
                x: 0,
                y: midY - thickness/2,
                width: w,
                height: thickness
            ))
        }

        /// Vẽ ống thẳng dọc
        func addStraightVertical() {
            p.addRect(CGRect(
                x: midX - thickness/2,
                y: 0,
                width: thickness,
                height: h
            ))
        }

        /// Vẽ góc cong từ điểm A → B
        func addCorner(_ from: CGPoint, _ to: CGPoint) {
            p.move(to: from)
            /// control point đặt ở giữa để tạo cong
            p.addQuadCurve(
                to: to,
                control: CGPoint(x: midX, y: midY)
            )
        }

        /// Chọn path theo loại ống
        switch type {

        case .straightHorizontal:
            addStraightHorizontal()

        case .straightVertical:
            addStraightVertical()

        case .cornerTopRight:
            /// từ trên → phải
            addCorner(CGPoint(x: midX, y: 0),
                      CGPoint(x: w, y: midY))

        case .cornerRightBottom:
            addCorner(CGPoint(x: w, y: midY),
                      CGPoint(x: midX, y: h))

        case .cornerBottomLeft:
            addCorner(CGPoint(x: midX, y: h),
                      CGPoint(x: 0, y: midY))

        case .cornerLeftTop:
            addCorner(CGPoint(x: 0, y: midY),
                      CGPoint(x: midX, y: 0))

        case .teeUpMissing:
            /// Đủ cả ngang + dọc, chỉ thiếu hướng trên
            addStraightHorizontal()
            addStraightVertical()

        case .teeRightMissing:
            addStraightVertical()
            p.addRect(CGRect(
                x: 0,
                y: midY - thickness/2,
                width: midX,
                height: thickness
            ))

        case .teeDownMissing:
            addStraightHorizontal()
            p.addRect(CGRect(
                x: midX - thickness/2,
                y: 0,
                width: thickness,
                height: midY
            ))

        case .teeLeftMissing:
            addStraightVertical()
            p.addRect(CGRect(
                x: midX,
                y: midY - thickness/2,
                width: midX,
                height: thickness
            ))

        case .cross:
            addStraightHorizontal()
            addStraightVertical()

        case .blocker:
            /// Ống không thông – vẽ hình vuông
            p.addRect(CGRect(origin: .zero, size: rect.size))
        }

        /// Xoay path theo rotation 1–4
        /// rotation = (n - 1) * 90°
        return p.applying(
            CGAffineTransform(rotationAngle:
                                CGFloat(rotation - 1) * .pi/2
                             )
        )
    }
}
