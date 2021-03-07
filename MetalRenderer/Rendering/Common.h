//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    vector_float3 cameraPosition;
} FragmentUniforms;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float shininess;
} Material;

typedef struct {
    matrix_float4x4 modelMatrix;
} Instances;

#endif /* Common_h */
