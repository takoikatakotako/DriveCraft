//
//  ARViewContainer.swift
//  DriveCraft
//
//  Created by jumpei ono on 2026/01/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isAccelerating: Bool
    @Binding var isBraking: Bool
    @Binding var isTurningLeft: Bool
    @Binding var isTurningRight: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // AR設定
        let config = ARWorldTrackingConfiguration()

        // AR Reference Imageを読み込み
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            print("❌ AR Reference Imageが見つかりません")
            return arView
        }

        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1

        print("🚀 ARセッションを開始します（画像認識モード）")
        print("📷 登録画像数: \(referenceImages.count)")
        arView.session.run(config)

        // デリゲート設定
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        // デバッグ用（必要に応じてコメント解除）
        // arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins]

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isAccelerating = isAccelerating
        context.coordinator.isBraking = isBraking
        context.coordinator.isTurningLeft = isTurningLeft
        context.coordinator.isTurningRight = isTurningRight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        private var hasPlacedCube = false
        private var cubeEntity: ModelEntity?
        private var currentSpeed: Float = 0.0 // m/s
        private var currentRotation: Float = 0.0 // ラジアン
        private var updateTimer: Timer?

        var isAccelerating: Bool = false {
            didSet { updateSpeed() }
        }
        var isBraking: Bool = false {
            didSet { updateSpeed() }
        }
        var isTurningLeft: Bool = false
        var isTurningRight: Bool = false

        private let maxSpeed: Float = 0.2 // 最大速度 20cm/s
        private let acceleration: Float = 0.005 // 加速度
        private let deceleration: Float = 0.02 // 減速度
        private let rotationSpeed: Float = 0.05 // 回転速度（ラジアン/フレーム）

        func session(_ session: ARSession, didFailWithError error: Error) {
            print("❌ ARSession エラー: \(error.localizedDescription)")
        }

        func sessionWasInterrupted(_ session: ARSession) {
            print("⚠️ ARSession が中断されました")
        }

        func sessionInterruptionEnded(_ session: ARSession) {
            print("✅ ARSession の中断が終了しました")
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !hasPlacedCube else { return }

            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    let imageName = imageAnchor.referenceImage.name ?? "不明"
                    let imageSize = imageAnchor.referenceImage.physicalSize

                    print("✅ 画像を検出しました！")
                    print("📷 画像名: \(imageName)")
                    print("📏 サイズ: \(imageSize.width)m x \(imageSize.height)m")

                    placeBlueCube(on: imageAnchor)
                    hasPlacedCube = true
                    break
                }
            }
        }

        private func placeBlueCube(on imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }

            // 青い立方体を作成（2.5cm x 2.5cm x 2.5cm）
            let cubeMesh = MeshResource.generateBox(size: 0.025)
            var material = SimpleMaterial()
            material.color = .init(tint: .blue, texture: nil)

            let cube = ModelEntity(mesh: cubeMesh, materials: [material])

            // 立方体を画像の中央、上に配置
            let anchorEntity = AnchorEntity(anchor: imageAnchor)

            // 立方体を画像の上に配置（立方体の半分の高さ分上げる）
            cube.position = SIMD3<Float>(0, 0.0125, 0)

            anchorEntity.addChild(cube)
            arView.scene.addAnchor(anchorEntity)

            // Coordinatorに保存
            self.cubeEntity = cube

            // アニメーションタイマーを開始
            startAnimationTimer()

            print("🎉 青い立方体を配置しました")
        }

        private func startAnimationTimer() {
            updateTimer?.invalidate()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
                self?.updateCubePosition()
            }
        }

        private func updateSpeed() {
            if isAccelerating {
                currentSpeed = min(currentSpeed + acceleration, maxSpeed)
            } else if isBraking {
                currentSpeed = max(currentSpeed - deceleration, 0)
            } else {
                // 何も押されていない場合は徐々に減速
                currentSpeed = max(currentSpeed - deceleration * 0.5, 0)
            }
        }

        private func updateCubePosition() {
            guard let cube = cubeEntity else { return }

            // 速度を更新
            updateSpeed()

            // 回転を更新
            if isTurningLeft {
                currentRotation += rotationSpeed
            } else if isTurningRight {
                currentRotation -= rotationSpeed
            }

            // 立方体の向きを更新
            cube.orientation = simd_quatf(angle: currentRotation, axis: SIMD3<Float>(0, 1, 0))

            // 現在の速度が0より大きい場合のみ移動
            if currentSpeed > 0 {
                // 現在の向きに基づいて移動方向を計算
                let direction = SIMD3<Float>(
                    sin(currentRotation),
                    0,
                    -cos(currentRotation)
                )
                let movement = direction * (currentSpeed / 60.0)
                cube.position += movement
            }
        }
    }
}
