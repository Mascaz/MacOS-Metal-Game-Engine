//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Maxwell Montes Diaz on 2/25/21.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue

    static var library: MTLLibrary!
    let depthStencilState: MTLDepthStencilState

    weak var scene: Scene? // we make this weak because the strong reference is held by the main view

    let camera = ArcballCamera()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        depthStencilState = Renderer.createDepthState()
        
        view.depthStencilPixelFormat = .depth32Float
        
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width / view.bounds.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
              let scene = scene else {
            return
        }
        commandEncoder.setDepthStencilState(depthStencilState)

        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)

        for renderable in scene.renderables {
            commandEncoder.pushDebugGroup(renderable.name)

            renderable.render(commandEncoder: commandEncoder, uniforms: scene.uniforms, fragmentUniforms: scene.fragmentUniforms)

            commandEncoder.popDebugGroup()
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
