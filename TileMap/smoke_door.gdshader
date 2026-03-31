shader_type canvas_item;

uniform vec4 smoke_color : source_color = vec4(0.75, 0.78, 0.82, 0.72);
uniform float speed = 0.22;
uniform float noise_scale = 3.8;
uniform float softness = 0.28;
uniform float density = 0.48;
uniform float flow_strength = 0.10;
uniform float edge_fade = 0.14;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += noise(p) * a;
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV;
	vec2 p = uv;
	p.y -= TIME * speed;
	p.x += sin((uv.y + TIME * 0.4) * 7.0) * flow_strength;

	float n = fbm(p * noise_scale);
	float smoke = smoothstep(density - softness, density + softness, n);

	float edge =
		smoothstep(0.0, edge_fade, uv.x) *
		smoothstep(0.0, edge_fade, 1.0 - uv.x) *
		smoothstep(0.0, edge_fade, uv.y) *
		smoothstep(0.0, edge_fade, 1.0 - uv.y);

	COLOR = vec4(smoke_color.rgb, smoke * edge * smoke_color.a);
}