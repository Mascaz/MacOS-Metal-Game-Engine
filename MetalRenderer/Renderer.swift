//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Maxwell Montes Diaz on 2/25/21.
//

import Foundation
import MetalKit

struct Vertex {
    let position: SIMD3<Float>
    let color: SIMD3<Float>
}

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState

    weak var scene: Scene?

    let camera = ArcballCamera()
    
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        pipelineState = Renderer.createPipelineState()
        depthStencilState = Renderer.createDepthState()
        
        camera.target = [0, 0.8, 0]
        camera.distance = 3
        
        view.depthStencilPixelFormat = .depth32Float
        
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        let cameraVector = camera.transform.matrix.upperLeft.columns.2
        camera.transform.position += delta * sensitivity * cameraVector
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
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        
        fragmentUniforms.cameraPosition = camera.transform.position
        commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 22)

        for renderable in scene.renderables {
            commandEncoder.pushDebugGroup(renderable.name)

            renderable.render(commandEncoder: commandEncoder, uniforms: uniforms)

            commandEncoder.popDebugGroup()
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
