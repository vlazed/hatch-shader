// Defines cEyePos
#include "common_ps_fxc.h"

sampler WORLDPOS : register(s0);
sampler NORMALTEXTURE : register(s1);

float4 scales : register(c0);
float2 texelSize    : register( c4 );

struct PS_INPUT
{
    float2 uv : TEXCOORD0;             // Position on triangle
    float2 pPos : VPOS;                 // Projected position
};

float3 decodeNormal(float2 f)
{
    f = f * 2.0 - 1.0;

    // https://twitter.com/Stubbesaurus/status/937994790553227264
    float3 n = float3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
    float t = saturate(-n.z);
    n.xy += n.xy >= 0.0 ? -t : t;
    return normalize(n);
}

float3 sampleWorldNormals(float2 uv)
{
    float4 normalTangent = tex2D(NORMALTEXTURE, uv);
    float3 worldNormal = decodeNormal(normalTangent.xy);

    return worldNormal;
}

float4 main(PS_INPUT frag) : COLOR
{
    float worldScale = scales.x;

    float2 texCoord = (frag.pPos+0.5)*texelSize;
    float4 wpndepth = tex2D(WORLDPOS,texCoord);
    float4 worldPos = float4(1/wpndepth.xyz,1);
    float3 worldNormals = sampleWorldNormals(texCoord);

    float2 uv_front = worldPos.xy *= worldScale;
    float2 uv_side = worldPos.zy *= worldScale;
    float2 uv_top = worldPos.xz *= worldScale;

    // Triplanar mapping from 
    // https://www.ronja-tutorials.com/post/010-triplanar-mapping/

    //generate weights from world normals
    float3 weights = worldNormals;
    //show texture on both sides of the object (positive and negative)
    weights = abs(weights);
    //make the transition sharper
    weights = pow(weights, 1);
    //make it so the sum of all components is 1
    weights = weights / (weights.x + weights.y + weights.z);

    //combine weights with projected colors
    uv_front *= weights.z;
    uv_side *= weights.x;
    uv_top *= weights.y;

    //combine the projected colors
    float4 col = float4(uv_front + uv_side + uv_top, 0, 1);

    return worldPos;
}