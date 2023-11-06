
struct VertexShaderFogNoLightInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
};

struct VertexShaderFogNoLightOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float Distance : TEXCOORD1;
	float3 WorldPosition : TEXCOORD2;
};

VertexShaderFogNoLightOutput VertexShaderFogNoLightFunction(VertexShaderFogNoLightInput input)
{
    VertexShaderFogNoLightOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.WorldPosition = worldPosition.xyz;

    return output;
}

float4 PixelShaderLavaFogNoLightFunction(VertexShaderFogNoLightOutput input) : COLOR0
{

    float l = saturate((input.Distance - 2) / (5 - 2));
	
	float4 color = tex2D(TextureSampler, input.TexCoord);
    return Gray(float4(lerp(color.xyz,float3(.6f,.2f,.2f), l), color.a));
}

float4 PixelShaderWaterFogLightFunction(VertexShaderFogNoLightOutput input) : COLOR0
{
	VertexShaderLightOutput i;

	i.WorldPosition = input.WorldPosition;
	i.TexCoord = input.TexCoord;


	float4 color = PixelShaderLightFunction(i);

    float l = saturate((input.Distance - 3.5f) / (8 - 3.5f));
	
    return Gray(float4(lerp(color.xyz,float3(.2f,.2f,.6f), l), color.a));
}

technique FogLavaNoLight
{
	pass Pass1
	{
	
		VertexShader = compile vs_2_0 VertexShaderFogNoLightFunction();
        PixelShader = compile ps_2_0 PixelShaderLavaFogNoLightFunction();
	}
}

technique FogWaterLight
{
	pass Pass1
	{
	
		VertexShader = compile vs_2_0 VertexShaderFogNoLightFunction();
        PixelShader = compile ps_2_0 PixelShaderWaterFogLightFunction();
	}
}

/////////////////////////LAVABLOCK
struct VertexShaderTextureFogLightOutput
{
	float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float4 Light : TEXCOORD1;
	float3 WorldPosition : TEXCOORD3;
	float Distance : TEXCOORD2;
};

VertexShaderTextureFogLightOutput VertexShaderTextureLavaFogLightFunction(VertexShaderTextureLightInput input)
{
	VertexShaderTextureFogLightOutput output;

	input.TexCoord.x /= 5;
	input.TexCoord.y /= 5;
	input.TexCoord.x += input.TexCoord2.x * (1.0 / 5.0);
	input.TexCoord.y += input.TexCoord2.y * (1.0 / 5.0);

	float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.Light = input.Side;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.WorldPosition = worldPosition.xyz;
	
	return output;
}

float4 PixelShaderTextureLavaFogLightFunction(VertexShaderTextureFogLightOutput input) : COLOR0
{
	VertexShaderTextureLightOutput i;

	i.Side = input.Light;
	i.TexCoord = input.TexCoord;
	i.WorldPosition = input.WorldPosition;
	i.Distance = input.Distance;
	i.Adder = float3(.5f,.5f,.5f);
	float4 color = PixelShaderTextureLightFunction(i);
	
	float l = saturate((input.Distance - 2) / (5 - 2));


    return Gray(float4(lerp(color.xyz,float3(.6f,.2f,.2f), l), color.a));
}

float4 PixelShaderTextureWaterFogLightFunction(VertexShaderTextureFogLightOutput input) : COLOR0
{
	VertexShaderTextureLightOutput i;

	i.Side = input.Light;
	i.TexCoord = input.TexCoord;
	i.WorldPosition = input.WorldPosition;
	i.Distance = input.Distance;
	i.Adder = float3(.5f,.5f,.5f);
	float4 color = PixelShaderTextureLightFunction(i);
	
	float l = saturate((input.Distance - 3.5) / (8 - 3.5));


    return Gray(float4(lerp(color.xyz,float3(.2f,.2f,.6f), l), color.a));
}

technique LavaFogLight
{
	pass Pass1
	{
		VertexShader = compile vs_3_0 VertexShaderTextureLavaFogLightFunction();
		PixelShader = compile ps_3_0 PixelShaderTextureLavaFogLightFunction();
	}
}

technique WaterFogLight
{
	pass Pass1
	{
		VertexShader = compile vs_3_0 VertexShaderTextureLavaFogLightFunction();
		PixelShader = compile ps_3_0 PixelShaderTextureWaterFogLightFunction();
	}
}


///fog light
struct VertexShaderFogLightLiquidInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float Light : TEXCOORD1;
};


struct VertexShaderFogLightLiquidOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 WorldPosition : TEXCOORD1;
	float Distance : TEXCOORD2;
	float Level : TEXCOORD3;
};


VertexShaderFogLightLiquidOutput VertexShaderFogLightFunction(VertexShaderFogLightLiquidInput input)
{
    VertexShaderFogLightLiquidOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.WorldPosition = worldPosition.xyz;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.Level = input.Light;

    return output;
}

float4 PixelShaderFogLightFunction(VertexShaderFogLightLiquidOutput input) : COLOR0
{
	input.WorldPosition.x += .5f;
	input.WorldPosition.z += .5f;
	if(input.Level != 1)
		input.WorldPosition.y += input.Level;// / 2;

	input.WorldPosition.x  /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler,input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .1, 1);

    float3 color = tex2D(TextureSampler, input.TexCoord).xyz * lightLevel;

	float l = Fog(input.Distance);
    return Gray(float4(lerp(color.xyz,float3(.5f,.5f,.5f), l), 1));
}

technique FogLightLiquid
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderFogLightFunction();
        PixelShader = compile ps_2_0 PixelShaderFogLightFunction();
	}
}
