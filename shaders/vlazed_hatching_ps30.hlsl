// Defines cEyePos
#include "common_ps_fxc.h"

sampler BASETEXTURE : register(s0);
sampler TAMTEXTURE1 : register(s1);
sampler TAMTEXTURE2 : register(s2);
sampler UVBUFFER : register(s3);

float4 hatchScale   : register(c0);
float4 COLOR   : register(c1);

// Combines the top and bottom colors using normal blending.
// https://en.wikipedia.org/wiki/Blend_modes#Normal_blend_mode
// This performs the same operation as Blend SrcAlpha OneMinusSrcAlpha.
float4 alphaBlend(float4 top, float4 bottom)
{
    float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
    float alpha = top.a + bottom.a * (1 - top.a);

    return float4(color, alpha);
}

// https://kylehalladay.com/blog/tutorial/2017/02/21/Pencil-Sketch-Effect.html
float3 Hatching(float2 _uv, half _intensity, half intensityScale)
{
    half3 hatch0 = tex2D(TAMTEXTURE1, _uv).rgb;
    half3 hatch1 = tex2D(TAMTEXTURE2, _uv).rgb;

    // half3 overbright = max(0, _intensity - 1.0);
    half3 overbright = _intensity;

    half3 weightsA = saturate(((1 - _intensity) * intensityScale) + half3(-0, -1, -2));
    half3 weightsB = saturate(((1 - _intensity) * intensityScale) + half3(-3, -4, -5));
    // half3 weightsA = saturate(_intensity + half3(-0, -1, -2));
    // half3 weightsB = saturate(_intensity + half3(-3, -4, -5));

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

half4 main(PS_INPUT frag) : COLOR
{
    float4 uv = tex2D(UVBUFFER, frag.uv);
    
    float4 color = tex2D(BASETEXTURE, frag.uv);

    // Convert to linear and get luminance
    half intensity = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    
    float s = sin(hatchScale.y);
    float c = cos(hatchScale.y);
    float2x2 rotation = float2x2(c, -s, -s, c);
    float2 rotated = mul(uv.xy, rotation);  

    // Apply hatching   
    half3 hatching = Hatching(rotated * hatchScale.x, intensity, hatchScale.z);

    hatching.rgb *= COLOR.rgb;
    half4 result = alphaBlend(half4(hatching, COLOR.a), color);

    return result;
}