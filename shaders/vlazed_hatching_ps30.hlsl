// Defines cEyePos
#include "common_ps_fxc.h"

sampler BASETEXTURE : register(s0);
sampler TAMTEXTURE1 : register(s1);
sampler TAMTEXTURE2 : register(s2);
sampler UVBUFFER : register(s3);

float4 hatchScale   : register(c0);
float4 texelSize    : register( c3 );

// Helper function to sample scene luminance.
float sampleSceneLuminance(float2 uv)
{
    float3 color = tex2D(BASETEXTURE, uv).rgb;
    return dot(pow(abs(color), 2.2), half3(0.2326, 0.7152, 0.0722));
}

// https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html
float3 Hatching(float2 _uv, half _intensity)
{
    half3 hatch0 = tex2D(TAMTEXTURE1, _uv).rgb;
    half3 hatch1 = tex2D(TAMTEXTURE2, _uv).rgb;

    half3 overbright = max(0, _intensity - 1.0);

    half3 weightsA = saturate((_intensity * 6.0) + half3(-0, -1, -2));
    half3 weightsB = saturate((_intensity * 6.0) + half3(-3, -4, -5));

    weightsA.xy -= weightsA.yz;
    weightsA.z -= weightsB.x;
    weightsB.xy -= weightsB.yz;

    hatch0 = hatch0 * weightsA;
    hatch1 = hatch1 * weightsB;

    half3 hatching = overbright + hatch0.r +
        hatch0.g + hatch0.b +
        hatch1.r + hatch1.g +
        hatch1.b;

    return hatching;
}

struct PS_INPUT
{
    float2 uv : TEXCOORD0;             // Position on triangle
    float2 pPos: VPOS;
    float3 view_space_dir : TEXCOORD1; // Projection matrix (used for calculating depth)
};

float4 main(PS_INPUT frag) : COLOR
{
    float4 uv = tex2D(UVBUFFER, frag.uv);
    float intensity = sampleSceneLuminance(frag.uv.xy);
    float s = sin(hatchScale.y);
    float c = cos(hatchScale.y);
    float2x2 rotation = float2x2(c, -s, -s, c);
    float2 rotated = mul(uv.xy, rotation);  
    float3 hatching = Hatching(rotated * hatchScale.x, intensity);

    hatching = pow(abs(hatching), 1/2.2);

    return float4(hatching, 1);
}