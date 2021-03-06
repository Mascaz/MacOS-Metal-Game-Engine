//
//  GameScene.swift
//  MetalRenderer
//
//  Created by Maxwell Montes Diaz on 3/6/21.
//

import Foundation

class GameScene: Scene {
    let train = Model(name: "train")

    override func setupScene() {
        add(node: train)

        let tree = Model(name: "treefir")
        add(node: tree)
        tree.position.x = -2.0
    }
}
