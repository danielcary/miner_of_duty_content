struct ModelLightInput
{
    float4 Position : POSITION0;
	float3 Normal : NORMAL0;
	float2 TexCoord : TEXCOORD0;
	float3 Color : COLOR0;
    
};

struct ModelLightOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD1;
	float3 Color : COLOR0;
	float3 WorldPosition : TEXCOORD0;
};

ModelLightOutput VertexShaderModelLightFunction(ModelLightInput input)
{
    ModelLightOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.WorldPosition = CameraPosition;
	output.TexCoord = float2(0,0);
	output.Color = input.Color;

    return output;
}

ModelLightOutput VertexShaderModelTextureLightFunction(ModelLightInput input)
{
    ModelLightOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.WorldPosition = CameraPosition;
	output.Color = input.Color;
	output.TexCoord = input.TexCoord;

    return output;
}

float4 PixelShaderModelLightFunction(ModelLightOutput input) : COLOR0
{
	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .15, 1);

    return Gray(float4(input.Color.rgb * lightLevel, 1));
}

float4 PixelShaderModelTextureLightFunction(ModelLightOutput input) : COLOR0
{
	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .15, 1);

	float3 texColor = tex2D(TextureSampler, input.TexCoord).xyz;

    return Gray(float4((input.Color.rgb * texColor) * lightLevel, 1));
}

technique ModelLight
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShaderModelLightFunction();
        PixelShader = compile ps_2_0 PixelShaderModelLightFunction();
    }
}

technique ModelLightTexture
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShaderModelTextureLightFunction();
        PixelShader = compile ps_2_0 PixelShaderModelTextureLightFunction();
    }
}


//gun model lighing fog

struct ModelLightFogInput
{
    float4 Position : POSITION0;
	float3 Normal : NORMAL0;
	float2 TexCoord : TEXCOORD0;	
};

struct ModelLightFogOutput
{
    float4 Position : POSITION0;
	float3 Normal : TEXCOORD3;
	float2 TexCoord : TEXCOORD1;
	float3 WorldPosition : TEXCOORD0;
	float Distance : TEXCOORD2;
};

ModelLightFogOutput VertexShaderModelLightFogFunction(ModelLightFogInput input)
{
    ModelLightFogOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);
	output.Normal = input.Normal;
	output.WorldPosition = worldPosition.xyz;

	//output.WorldPosition = CameraPosition;


    return output;
}

float4 PixelShaderModelLightFogFunction(ModelLightFogOutput input) : COLOR0
{
	input.WorldPosition.x /= 128;
	input.WorldPosition.y /= 64;
	input.WorldPosition.z /= 128;

    float lightLevel = tex3D(LightMapLinearSampler, input.WorldPosition.zyx).a * 255;
	lightLevel = ((.0015151515 * lightLevel) * (.0015151515 * lightLevel)) + (.0739393939 * lightLevel) + .2090909091;
	lightLevel = clamp(lightLevel, .15, 1); //foo lighing

	float4 texColor = tex2D(TextureSampler, input.TexCoord); //tex color

	float3 sun = float3(0,0,1);
	float dp = dot(sun, input.Normal);
	sun = float3(-1,0 ,0);
	dp = (dp + clamp(dot(sun, input.Normal) + .4, .4,1)) / 2;
	dp = clamp(dp + .4, .4, 1); //lighing

    float3 color = texColor.xyz * (((lightLevel * .7) + dp) / 2);//gets color

	
	float l =  Fog(input.Distance);
    color = lerp(color, float3(.5f,.5f,.5f), l); //adds fog

	//do water fog
	float3 modifer = float3(0,0,0);
	float l2 = 0;
	if(underWater)
	{
		 l2 = saturate((input.Distance - 3.5) / (8 - 3.5));
		 modifer = float3(.2f,.2f,.6f);
	}
	else if(underLava)
	{
		l2 = saturate((input.Distance - 2) / (5 - 2));
		 modifer =float3(.6f,.2f,.2f);
	}

	return Gray(float4(lerp(color.xyz,modifer, l2), texColor.a));

}

technique ModelLightFog
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShaderModelLightFogFunction();
        PixelShader = compile ps_2_0 PixelShaderModelLightFogFunction();
    }
}

//model fog

struct ModelFogInput
{
    float4 Position : POSITION0;
	float3 Normal : NORMAL0;
	float2 TexCoord : TEXCOORD0;	
};

struct ModelFogOutput
{
    float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD1;
	float Distance : TEXCOORD2;
};

ModelFogOutput VertexShaderModelFogFunction(ModelFogInput input)
{
    ModelFogOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
	output.TexCoord = input.TexCoord;
	output.Distance = Distance(worldPosition.xyz, CameraPosition);

    return output;
}

float4 PixelShaderModelFogFunction(ModelFogOutput input) : COLOR0
{
	float4 texColor = tex2D(TextureSampler, input.TexCoord); //tex color


	float l =  Fog(input.Distance);
    return Gray(float4(lerp(texColor.rgb, float3(.5f,.5f,.5f), l), texColor.a)); //adds fog
}

technique ModelFog
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShaderModelFogFunction();
        PixelShader = compile ps_2_0 PixelShaderModelFogFunction();
    }
}
