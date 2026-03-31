shader_type canvas_item;

uniform float reveal : hint_range(-1.0, 1.0, 0.001) = 0.0; // 0=hidden, 1=visible
uniform float softness : hint_range(0.0, 0.2, 0.001) = 0.05;
uniform float sway_strength : hint_range(0.0, 8.0, 0.01) = 2.0;
uniform float sway_speed : hint_range(0.0, 8.0, 0.01) = 1.2;
uniform vec4 vine_tint : source_color = vec4(1.0);

void fragment() {
    vec2 uv = UV;

    // Gentle sway
    
   

    vec4 col = texture(TEXTURE, uv) * vine_tint;

    // Ensure valid ramp range
    float r = clamp(reveal, 0.0, 1.0);
    float s = max(softness, 0.0001);

    // Visible for uv.x <= r, with a soft fade beyond r
    float mask = 1.0 - smoothstep(r, min(r + s, 1.0), uv.x);

    col.a *= mask;

    if (col.a <= 0.001) discard;
    COLOR = col;
}