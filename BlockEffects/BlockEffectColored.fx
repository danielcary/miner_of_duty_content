struct VertexShaderColorInput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
};

VertexShaderColorInput VertexShaderColorFunction(VertexShaderColorInput input)
{
	VertexShaderColorInput output;

	float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.Color = input.Color;

	return output;
}

float4 PixelShaderColorFunction(VertexShaderColorInput input) : COLOR0
{
	return Gray(input.Color);
}

technique Colored
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderColorFunction();
        PixelShader = compile ps_2_0 PixelShaderColorFunction();
	}
}

////////////lighedted
struct VertexShaderLightColorOuput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
	float3 WorldPosition : TEXCOORD0;
};

VertexShaderLightColorOuput VertexShaderColorLightFunction(VertexShaderColorInput input)
{
	VertexShaderLightColorOuput output;

	float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.Color = input.Color;
	output.WorldPosition = worldPosition.xyz;

	return output;
}

float4 PixelShaderColorLightFunction(VertexShaderLightColorOuput input) : COLOR0
{
	input.WorldPosition.x -= 1.5;
	//input.WorldPosition.y -= 1;
	input.WorldPosition.z += 4;

	input.WorldPosition.x  /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler,input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .1, 1);

	return Gray(float4(input.Color.rgb * lightLevel, 1));
}

technique ColoredLight
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderColorLightFunction();
        PixelShader = compile ps_2_0 PixelShaderColorLightFunction();
	}
}


