import SwiftUI

struct ContentView: View {
    @State private var isAccelerating = false
    @State private var isBraking = false
    @State private var isTurningLeft = false
    @State private var isTurningRight = false

    var body: some View {
        ZStack {
            ARViewContainer(
                isAccelerating: $isAccelerating,
                isBraking: $isBraking,
                isTurningLeft: $isTurningLeft,
                isTurningRight: $isTurningRight
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text("B5用紙をカメラに向けてください")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()

                // 左右コントロールボタン
                HStack(spacing: 60) {
                    // 左ボタン
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(isTurningLeft ? Color.blue : Color.blue.opacity(0.6))
                            .cornerRadius(40)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isTurningLeft = true }
                            .onEnded { _ in isTurningLeft = false }
                    )

                    // 右ボタン
                    Button(action: {}) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(isTurningRight ? Color.blue : Color.blue.opacity(0.6))
                            .cornerRadius(40)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isTurningRight = true }
                            .onEnded { _ in isTurningRight = false }
                    )
                }
                .padding(.bottom, 20)

                // アクセル・ブレーキボタン
                HStack(spacing: 40) {
                    // ブレーキボタン（ボタンB）
                    Button(action: {}) {
                        Text("B\nブレーキ")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 120, height: 120)
                            .background(isBraking ? Color.red : Color.red.opacity(0.6))
                            .cornerRadius(60)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isBraking = true }
                            .onEnded { _ in isBraking = false }
                    )

                    // アクセルボタン（ボタンA）
                    Button(action: {}) {
                        Text("A\nアクセル")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 120, height: 120)
                            .background(isAccelerating ? Color.green : Color.green.opacity(0.6))
                            .cornerRadius(60)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isAccelerating = true }
                            .onEnded { _ in isAccelerating = false }
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    ContentView()
}
