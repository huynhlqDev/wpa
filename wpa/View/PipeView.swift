//
//  PipeView.swift
//  wpa
//
//  Created by huynh on 28/11/25.
//

import SwiftUI
import Combine

// View hiển thị 1 ô ống nước
// Có xoay (tap) + animation nước chảy
struct PipeView: View {

    // Binding để pipe xoay từ bên ngoài
    @State var pipe: Pipe
    // Biến điều khiển animation trim
    @State private var animateFlow = false
    // true = đang có nước chạy qua ống
    let isWaterFlowing: Bool

    var body: some View {
        ZStack {

            // Vẽ ống nền (màu xám nhạt)
            PipeShape(type: pipe.type, rotation: pipe.rotation)
                .stroke(Color.gray.opacity(0.4), lineWidth: 18)
                .background(
                    PipeShape(type: pipe.type, rotation: pipe.rotation)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 26)
                )

            // Nếu nước đang chảy thì overlay stroke màu xanh chạy trim
            if isWaterFlowing {
                PipeShape(type: pipe.type, rotation: pipe.rotation)
                    .trim(from: 0, to: animateFlow ? 1 : 0) // trim để tạo hiệu ứng nước chạy
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                // Lặp animation liên tục
                    .animation(
                        .linear(duration: 0.8),
                        value: animateFlow
                    )
                    .onAppear {
                        animateFlow = true
                    }
            }
        }
        // Để tap vào sẽ xoay ống
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                pipe.rotateClockwise()
            }
        }
    }
}
