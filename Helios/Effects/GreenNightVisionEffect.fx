sampler2D implicitInput : register(s0);
float brightness : register(c0);

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 main(float2 uv : TEXCOORD) : COLOR
{
	float4 color = tex2D(implicitInput, uv);
	const float4 grayscale = float4(0.2125,0.7154,0.0721,0.0);
	if ((color.a * brightness) < 0.04) {
		return float4(0.0, 0.0, 0.0, 0.0);
	}
	float intensity = min(1.0, dot(color, grayscale) * brightness);
	return float4(intensity / 10.0, intensity, 0.0, color.a);
}