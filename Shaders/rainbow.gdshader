shader_type canvas_item;

uniform float line_count: hint_range(0.0, 50.0) = 20.0;
uniform float line_width: hint_range(0.0, 1.0) = 0.5;
uniform float speed: hint_range(0.0, 1.0) = 0.5;

vec3 hsv2rgb(float hue){
	vec3 k = vec3(1.0, 2.0/3.0, 1.0/3.0);
	vec3 p = abs(fract(vec3(hue) + k) * 6.0 - 3.0);
	return clamp(p - vec3(1.0), 0.0, 1.0);
}

void fragment() {
	vec2 pixel_uv = floor(UV * 120.0) / 120.0;
	//float diagonal_pos = pixel_uv.x + pixel_uv.y;
	
	// use if I dont want it pixelated
	float diagonal_pos = UV.x + UV.y;
	
	float moving_pos = diagonal_pos - (TIME * speed);
	float pattern = fract(moving_pos * line_count);
	vec3 rainbow = hsv2rgb(moving_pos);
	float is_line = float(pattern < line_width);
	COLOR.rgb = mix(COLOR.rgb, rainbow, is_line);
	}