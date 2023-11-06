Texture Body1; //basehead
sampler Body1Sampler = sampler_state
{
	Texture = <Body1>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};
Texture Body2; //eyelayer
sampler Body2Sampler = sampler_state
{
	Texture = <Body2>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};
Texture Body3; //hairlayer
sampler Body3Sampler = sampler_state
{
	Texture = <Body3>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};
Texture Body4; //skinlayer
sampler Body4Sampler = sampler_state
{
	Texture = <Body4>;
	minfilter = POINT;
	magfilter = POINT;
	mipfilter = LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};


struct HeadInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 EyeColor : COLOR0;
	float3 HairColor : COLOR1;
	float3 SkinColor : COLOR2;
};

struct HeadOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 EyeColor : COLOR0;
	float3 HairColor : COLOR1;
	float3 SkinColor : COLOR2;
	
	float3 WorldPosition : TEXCOORD1;
	float Distance : TEXCOORD2;
};

HeadOutput VertexShaderHeadFunction(HeadInput input)
{
    HeadOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);

    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.EyeColor = input.EyeColor;
	output.HairColor = input.HairColor;
	output.SkinColor = input.SkinColor;

	
	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.WorldPosition = worldPosition.xyz;

    return output;
}

float4 PixelShaderHeadFunction(HeadOutput input) : COLOR0
{
	
	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .7, .9); //foo lighing

	float4 color1 = tex2D(Body1Sampler, input.TexCoord); //base
	float4 color2 = tex2D(Body2Sampler, input.TexCoord); //eye
	color2.rgb *= input.EyeColor.rgb;
	float4 color3 = tex2D(Body3Sampler, input.TexCoord); //hair
	color3.rgb *= input.HairColor.rgb;
	float4 color4 = tex2D(Body4Sampler, input.TexCoord); //skin
	color4.rgb *= input.SkinColor.rgb;

	float3 color = color1.rgb + color2.rgb + color3.rgb + color4.rgb;
	color *= lightLevel;

	float l =  Fog(input.Distance);
    return Gray(float4(lerp(color, float3(.5f,.5f,.5f), l), 1));

}


technique BodyHead
{
    pass Pass1
    {
        VertexShader = compile vs_3_0 VertexShaderHeadFunction();
        PixelShader = compile ps_3_0 PixelShaderHeadFunction();
    }
}

//////////////////////Body
struct BodyInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 ShirtColor : COLOR0;
	float3 PantsColor : COLOR1;
	float3 SkinColor : COLOR2;
};

struct BodyOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 ShirtColor : COLOR0;
	float3 PantsColor : COLOR1;
	float3 SkinColor : COLOR2;

	float3 WorldPosition : TEXCOORD1;
	float Distance : TEXCOORD2;
};

BodyOutput VertexShaderBodyFunction(BodyInput input)
{
    BodyOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);

    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.ShirtColor = input.ShirtColor;
	output.PantsColor = input.PantsColor;
	output.SkinColor = input.SkinColor;

	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.WorldPosition = worldPosition.xyz;

    return output;
}

float4 PixelShaderBodyFunction(BodyOutput input) : COLOR0
{
	
	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .7, .9); //foo lighing

	float4 color1 = tex2D(Body1Sampler, input.TexCoord); //shirt
	color1.rgb *= input.ShirtColor.rgb;
	float4 color2 = tex2D(Body2Sampler, input.TexCoord); //pants
	color2.rgb *= input.PantsColor.rgb;
	float4 color3 = tex2D(Body3Sampler, input.TexCoord); //skin
	color3.rgb *= input.SkinColor.rgb;

	float3 color = color1.rgb + color2.rgb + color3.rgb;
	color *= lightLevel;

	float l =  Fog(input.Distance);
    return Gray(float4(lerp(color, float3(.5f,.5f,.5f), l), 1));
}


technique BodyBody
{
    pass Pass1
    {
        VertexShader = compile vs_3_0 VertexShaderBodyFunction();
        PixelShader = compile ps_3_0 PixelShaderBodyFunction();
    }
}


//////////////////////Arm
struct ArmInput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 ShirtColor : COLOR0;
	float3 SkinColor : COLOR1;
};

struct ArmOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
	float3 ShirtColor : COLOR0;
	float3 SkinColor : COLOR1;

	float3 WorldPosition : TEXCOORD1;
	float Distance : TEXCOORD2;
};

ArmOutput VertexShaderArmFunction(ArmInput input)
{
    ArmOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);

    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.ShirtColor = input.ShirtColor;
	output.SkinColor = input.SkinColor;

	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.WorldPosition = worldPosition.xyz;

    return output;
}

float4 PixelShaderArmFunction(ArmOutput input) : COLOR0
{

	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .7, .9); //foo lighing
	
	float4 color1 = tex2D(Body1Sampler, input.TexCoord); //shirt
	color1.rgb *= input.ShirtColor.rgb;
	float4 color2 = tex2D(Body2Sampler, input.TexCoord); //skin
	color2.rgb *= input.SkinColor.rgb;

	float3 color = color1.rgb + color2.rgb;
	color *= lightLevel;

	float l = Fog(input.Distance);
    return Gray(float4(lerp(color, float3(.5f,.5f,.5f), l), 1));
}


technique BodyArmLeg
{
    pass Pass1
    {
        VertexShader = compile vs_3_0 VertexShaderArmFunction();
        PixelShader = compile ps_3_0 PixelShaderArmFunction();
    }
}
