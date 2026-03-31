shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float radius : hint_range(0.0, 1.5) = 0.75;
uniform float softness : hint_range(0.001, 1.0) = 0.4;

void fragment() {
	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv);

	float vignette = smoothstep(radius - softness, radius, dist);

	COLOR = vec4(0.0, 0.0, 0.0, vignette * intensity);
}