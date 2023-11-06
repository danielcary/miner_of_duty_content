Texture3D NonPlayableLightMap;
sampler3D NonPlayableLightMapLightMapLinearSampler = sampler_state
{
	Texture = <NonPlayableLightMap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};


struct VertexShaderNonPlayableTextureLightOutput
{
	float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float Side : TEXCOORD1;
	float3 WorldPosition : TEXCOORD2;
	float Distance : TEXCOORD3;
	float3 Adder : TEXCOORD4;
};


VertexShaderNonPlayableTextureLightOutput VertexShaderNonPlayableTextureLightFunction(VertexShaderTextureLightInput input)
{
	VertexShaderNonPlayableTextureLightOutput output;

	input.TexCoord.x /= 5;
	input.TexCoord.y /= 5;
	input.TexCoord.x += input.TexCoord2.x * (1.0 / 5.0);
	input.TexCoord.y += input.TexCoord2.y * (1.0 / 5.0);

	output.Adder = input.Position.xyz;
	
	if(input.Position.x > 0)
		output.Adder.x = output.Adder.x - (output.Adder.x - .5f);
	else
		output.Adder.x = abs(output.Adder.x) + (output.Adder.x - .5f);

	if(input.Position.y > 0)
		output.Adder.y = output.Adder.y - (output.Adder.y - .5f);
	else
		output.Adder.y = abs(output.Adder.y) + (output.Adder.y - .5f);

	if(input.Position.z > 0)
		output.Adder.z = output.Adder.z - (output.Adder.z - .5f);
	else
		output.Adder.z = abs(output.Adder.z) + (output.Adder.z - .5f);

	float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.Side = input.Side;
	output.WorldPosition = worldPosition.xyz + float3(64,0,64);//we translated it
	output.Distance = Distance(worldPosition.xyz, CameraPosition);

	return output;
}


float4 PixelShaderNonPlayableTextureLightFunction(VertexShaderNonPlayableTextureLightOutput input) : COLOR0
{
	float3 side = float3(0,0,0);
	if(input.Side == 0)
	{
		side = float3(0,1,0);
	}
	else if(input.Side == 1)
	{
		side = float3(-1,0,0);
	}
	else if(input.Side == 2)
	{
		side = float3(0,-1,0);
	}
	else if(input.Side == 3)
	{
		side = float3(1,0,0);
	}
	else if(input.Side == 4)
	{
		side = float3(0,0,1);
	}
	else if(input.Side == 5)
	{
		side = float3(0,0,-1);
	}

	float lightLevel = 1;
	float lightLevel1, lightLevel2;

	

	float3 worldPos = input.WorldPosition;

	input.WorldPosition += input.Adder;

	input.WorldPosition.x /= 256;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 256;
	
	lightLevel1 = tex3D(NonPlayableLightMapLightMapLinearSampler, input.WorldPosition.zyx).a * 255; //we used an alpha surface format
	lightLevel1 -= DarkenSide(input.Side);
	lightLevel1 = ((.0015151515 * lightLevel1) * (.0015151515 * lightLevel1)) + (.0739393939 * lightLevel1) + .2090909091;
	lightLevel1 = clamp(lightLevel1, .1, 1);

	input.WorldPosition = worldPos;

	input.WorldPosition += side;
	input.WorldPosition += input.Adder * .55;

	input.WorldPosition.x /= 256;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 256;

	lightLevel2 = tex3D(NonPlayableLightMapLightMapLinearSampler, input.WorldPosition.zyx).a * 255; //we used an alpha surface format
	lightLevel2 -= DarkenSide(input.Side);
	lightLevel2 = ((.0015151515 * lightLevel2) * (.0015151515 * lightLevel2)) + (.0739393939 * lightLevel2) + .2090909091;
	lightLevel2 = clamp(lightLevel2, .1, 1);

	lightLevel = (lightLevel1 + .5 + lightLevel1 + lightLevel1 + lightLevel1 + lightLevel2 + lightLevel2 + lightLevel2 + lightLevel2 + lightLevel2) / 9;
	
	float l = Fog(input.Distance);//saturate((input.Distance - 50) / (100 - 50));

	lightLevel = (-.3565625 * (lightLevel * lightLevel)) + (1.52578125 * lightLevel) - .154375;
	lightLevel = clamp(lightLevel, .05, 1);

	float4 color = tex2D(TextureSampler, input.TexCoord);
	color.rgb *= lightLevel;
	if(color.a > .8)
		return Gray(lerp(color, float4(.5f,.5f,.5f,1), l));
	else return Gray(color);
}

technique NonPlayableTextureLighting
{
	pass Pass1
	{
		VertexShader = compile vs_3_0 VertexShaderNonPlayableTextureLightFunction();
        PixelShader = compile ps_3_0 PixelShaderNonPlayableTextureLightFunction();
	}
}