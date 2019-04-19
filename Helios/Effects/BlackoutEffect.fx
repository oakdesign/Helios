sampler2D implicitInput : register(s0);
float intensity : register(c0);

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 main(float2 uv : TEXCOORD) : COLOR
{
	float4 color = tex2D(implicitInput, uv);
	float factor = (1.0 - intensity);
	return float4(color.r * factor, color.g * factor, color.b * factor, color.a);
}