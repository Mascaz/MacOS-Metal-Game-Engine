//
//  Shaders.metal
//  MetalRenderer
//
//  Created by Maxwell Montes Diaz on 2/25/21.
//

#include <metal_stdlib>
using namespace metal;


constant float3 color[6] {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(1, 0, 0)
};


struct VertexIn {
    float4 position [[attribute(0)]];
};
 
struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant uint &colorIndex [[buffer(11)]]) {
    VertexOut out {
        .position = vertexBuffer.position,
        .color = color[colorIndex]
    };
    
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
