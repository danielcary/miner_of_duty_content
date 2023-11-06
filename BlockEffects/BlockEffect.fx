Texture Texture0;
sampler TextureSampler = sampler_state
{
	Texture = <Texture0>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};

Texture3D LightMap;
sampler3D LightMapSampler = sampler_state
{
	Texture = <LightMap>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};

sampler3D LightMapLinearSampler = sampler_state
{
	Texture = <LightMap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};

float4x4 World;
float4x4 View;
float4x4 Projection;
float3 CameraPosition;

float GrayAmount;
float3 Brightness;
bool DiscardAlpha, DiscardSolid;

bool underWater, underLava;

//float4 Fog = float4(.5f,.5f,.5f,1);
float FogSwitch = 1;
float Fog(float3 inputDist)
{
	return saturate((inputDist - 50) / (100 - 50)) * FogSwitch;
}

float4 Gray(float4 color)
{
	float avg = (color.r + color.g + color.b) / 3;
	return float4(lerp(color.rgb, float3(avg,avg,avg), GrayAmount) + Brightness, color.a );
}

float Distance(float3 a, float3 b)
{
	return sqrt(((b.x - a.x) * (b.x - a.x)) + ((b.y - a.y) * (b.y - a.y)) + ((b.z - a.z) * (b.z - a.z)));
}


struct VertexShaderInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float Light : COLOR0;
};

struct VertexShaderLightOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 WorldPosition : TEXCOORD1;
};

struct VertexShaderNoLightOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
};

VertexShaderLightOutput VertexShaderLightFunction(VertexShaderInput input)
{
    VertexShaderLightOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.WorldPosition = worldPosition.xyz;

    return output;
}

float4 PixelShaderLightFunction(VertexShaderLightOutput input) : COLOR0
{
	input.WorldPosition.x += .5f;
	input.WorldPosition.z += .5f;

	input.WorldPosition.x  /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler,input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .1, 1);
	float4 color = tex2D(TextureSampler, input.TexCoord);
    return Gray(float4(color.xyz * lightLevel,color.a));
}


VertexShaderNoLightOutput VertexShaderNoLightFunction(VertexShaderInput input)
{
    VertexShaderNoLightOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;

    return output;
}

float4 PixelShaderNoLightFunction(VertexShaderNoLightOutput input) : COLOR0
{
    return Gray(tex2D(TextureSampler, input.TexCoord));
}


technique NoLight
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderNoLightFunction();
        PixelShader = compile ps_2_0 PixelShaderNoLightFunction();
	}
}

technique Light
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderLightFunction();
        PixelShader = compile ps_2_0 PixelShaderLightFunction();
	}
}

struct VertexShaderLight2Output
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 WorldPosition : TEXCOORD1;

	
	float Distance : TEXCOORD2;
};


VertexShaderLight2Output VertexShaderLight2Function(VertexShaderInput input)
{
    VertexShaderLight2Output output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.WorldPosition = worldPosition.xyz;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);

    return output;
}

float4 PixelShaderLight2Function(VertexShaderLight2Output input) : COLOR0
{
	input.WorldPosition.x += .5f;
	input.WorldPosition.z += .5f;

	input.WorldPosition.x  /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler,input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .1, 1);

	float l = saturate((input.Distance - 50) / (100 - 50));
	float4 color = float4(tex2D(TextureSampler, input.TexCoord).xyz * lightLevel,tex2D(TextureSampler, input.TexCoord).a) ;
    return Gray(float4(lerp(color.rgb,float3(.5f,.5f,.5f),l),color.a));
}

technique Light2
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderLight2Function();
        PixelShader = compile ps_2_0 PixelShaderLight2Function();
	}
}

#include "BlockEffectMainBlock.fx"
#include "NPBlockEffectMainBlock.fx"
#include "BlockEffectFog.fx"
#include "BlockEffectColored.fx"
#include "ModelEffect.fx"
#include "BodyEffect.fx"
#include "AreaWallEffect.fx"