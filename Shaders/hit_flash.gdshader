shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0; // 0 = normal, 1 = fully white
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Keep alpha from the texture so the silhouette stays correct
    vec3 base_rgb = tex.rgb;
    vec3 target_rgb = flash_color.rgb;

    // Blend to white (or any flash_color) based on flash
    vec3 out_rgb = mix(base_rgb, target_rgb, flash);

    COLOR = vec4(out_rgb, tex.a);
}