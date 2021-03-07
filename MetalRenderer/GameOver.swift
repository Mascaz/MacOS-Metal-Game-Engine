//
// Created by Maxwell Montes Diaz on 3/7/21.
//

import Foundation

class GameOver: Scene {

    var messageModel: Model?

    var win = false {
        didSet {
            messageModel = Model(name: win ? "youwin" : "youlose")
            add(node: messageModel!)
        }
    }

    override func click(location: SIMD2<Float>) {
        let scene = RayBreak(sceneSize: sceneSize)
        sceneDelegate?.transition(to: scene)
    }

    override func setupScene() {
        camera.distance = 15
        camera.fov = radians(fromDegrees: 100)
    }

    override func updateScene(deltaTime: Float) {
        messageModel?.rotation.y += .pi / 4 * deltaTime
    }
}