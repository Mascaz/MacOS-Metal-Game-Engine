//
//  Renderable.swift
//  MetalRenderer
//
//  Created by Maxwell Montes Diaz on 3/6/21.
//

import Foundation
import MetalKit

protocol Renderable {
    var name: String { get }
    
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                fragmentUniforms: FragmentUniforms)
}
