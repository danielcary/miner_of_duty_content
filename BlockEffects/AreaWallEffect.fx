
struct AreaWallVertexShaderInput
{
    float4 Position : POSITION0;
	float3 Normal : NORMAL0;
};

struct AreaWallVertexShaderOutput
{
    float4 Position : POSITION0;
};

AreaWallVertexShaderOutput AreaWallVertexShaderFunction(AreaWallVertexShaderInput input)
{
    AreaWallVertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

    return output;
}

float WallAlpha;

float4 AreaWallPixelShaderFunction(AreaWallVertexShaderOutput input) : COLOR0
{
	if(WallAlpha < .01f)
		return float4(0,0,0,0);

    return Gray(float4(0, (WallAlpha / .2f) * .6f, 0, WallAlpha));
}

technique AreaWallTechnique
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 AreaWallVertexShaderFunction();
        PixelShader = compile ps_2_0 AreaWallPixelShaderFunction();
    }
}
