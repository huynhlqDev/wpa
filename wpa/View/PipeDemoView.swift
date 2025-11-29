//
//  PipeDemoView.swift
//  wpa
//
//  Created by huynh on 28/11/25.
//
import SwiftUI

// Parent demo tạo state và truyền binding xuống
struct PipeDemoView: View {

    @State private var flowing: [Bool] = [false, false]
    let pipes: [Pipe] = [
        Pipe(type: .cornerRightBottom, rotation: 1),
        Pipe(type: .cornerTopRight, rotation: 1),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // // truyền binding xuống PipeView bằng $
            ForEach(pipes.indices, id: \.self) { index in
                PipeView(pipe: pipes[index], isWaterFlowing: flowing[index])
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .onAppear {
            Task {
                for i in pipes.indices {
                    // bật pipe i
                    flowing[i] = true

                    // chờ 0.8–1s cho animation chạy
                    try? await Task.sleep(for: .seconds(pumpTime))

                    // tắt pipe i (nếu muốn)
                    // flowing[i] = false
                }
            }
        }
    }
}

#Preview {
    PipeDemoView()
}
