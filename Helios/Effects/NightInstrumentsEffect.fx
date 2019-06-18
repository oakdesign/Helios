sampler2D implicitInput : register(s0);

float brightness : register(c0);
float threshold: register(c1);
float ambient: register(c2);
// float glow_floor: register(c3);

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 main(float2 uv : TEXCOORD) : COLOR
{
	const float glow_floor = 0.8;

	float4 color = tex2D(implicitInput, uv);
	const float4 grayscale = float4(0.2125,0.7154,0.0721,0.0);
	if ((color.a * brightness) < 0.04) {
		// transparent
		return float4(0.0, 0.0, 0.0, 0.0);
	}
	float intensity = min(1.0, dot(color, grayscale));
	if (intensity < threshold) {
		return float4(color.r * ambient, color.g * ambient, color.b * ambient, color.a);
	}
	float glow = glow_floor;
	if (intensity < 1.0) {
		glow = glow + (1.0 - glow_floor) * (intensity - threshold) / (1.0 - threshold);
	}
	glow = glow * brightness;
	return float4(glow / 10.0, glow, 0.0, color.a);
}