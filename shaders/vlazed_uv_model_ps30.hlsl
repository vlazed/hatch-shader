// Defines cEyePos
#include "common_ps_fxc.h"

sampler BASETEXTURE : register(s0);

float2 texelSize    : register( c4 );

struct PS_INPUT
{
    float2 pPos : VPOS;             // Position on triangle
    float2 uv : TEXCOORD0;             // Position on triangle
    float3 view_space_dir : TEXCOORD1; // Projection matrix (used for calculating depth)
};

float4 main(PS_INPUT frag) : COLOR
{
    return float4(frag.uv.x, frag.uv.y, 0, 1);
}