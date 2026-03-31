shader_type canvas_item;

group_uniforms SourceColors;

uniform vec4 head_light_from : source_color = vec4(0.266667, 0.874510, 1.000000, 1.0); // 44dfff
uniform vec4 head_shadow_from : source_color = vec4(0.282353, 0.760784, 1.000000, 1.0); // 48c2ff

uniform vec4 body_light_from : source_color = vec4(1.000000, 0.419608, 0.023529, 1.0); // ff6b06
uniform vec4 body_shadow_from : source_color = vec4(0.929412, 0.372549, 0.000000, 1.0); // ed5f00

uniform vec4 left_arm_light_from : source_color = vec4(0.870588, 0.000000, 0.000000, 1.0); // de0000
uniform vec4 left_arm_shadow_from : source_color = vec4(0.800000, 0.000000, 0.215686, 1.0); // cc0037

uniform vec4 right_arm_light_from : source_color = vec4(0.525490, 0.117647, 0.682353, 1.0); // 861eae
uniform vec4 right_arm_shadow_from : source_color = vec4(0.419608, 0.117647, 0.658824, 1.0); // 6b1ea8

uniform vec4 left_leg_light_from : source_color = vec4(0.509804, 0.964706, 0.000000, 1.0); // 82f600
uniform vec4 left_leg_shadow_from : source_color = vec4(0.247059, 0.694118, 0.223529, 1.0); // 3fb139

uniform vec4 right_leg_light_from : source_color = vec4(1.000000, 0.325490, 0.788235, 1.0); // ff53c9
uniform vec4 right_leg_shadow_from : source_color = vec4(0.890196, 0.286275, 0.945098, 1.0); // e349f1

group_uniforms;

group_uniforms TargetColors;

uniform vec4 head_light_to : source_color = vec4(0.901961, 0.564706, 0.305882, 1.0); // e6904e
uniform vec4 head_shadow_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42

uniform vec4 body_light_to : source_color = vec4(0.631373, 0.254902, 0.211765, 1.0); // a14136
uniform vec4 body_shadow_to : source_color = vec4(0.603922, 0.235294, 0.192157, 1.0); // 9a3c31

uniform vec4 left_arm_light_to : source_color = vec4(0.901961, 0.564706, 0.305882, 1.0); // e6904e
uniform vec4 left_arm_shadow_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42

uniform vec4 right_arm_light_to : source_color = vec4(0.901961, 0.564706, 0.305882, 1.0); // e6904e
uniform vec4 right_arm_shadow_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42

uniform vec4 left_leg_light_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42
uniform vec4 left_leg_shadow_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42

uniform vec4 right_leg_light_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42
uniform vec4 right_leg_shadow_to : source_color = vec4(0.831373, 0.494118, 0.258824, 1.0); // d47e42

group_uniforms;

group_uniforms FlashSettings;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

uniform float tolerance : hint_range(0.0, 0.05, 0.001) = 0.01;

bool same_color(vec3 a, vec3 b, float t) {
	return distance(a, b) <= t;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	if (tex.a <= 0.0) {
		COLOR = tex;
	} else {
		vec3 rgb = tex.rgb;

		if (same_color(rgb, head_light_from.rgb, tolerance)) {
			tex.rgb = head_light_to.rgb;
		}
		else if (same_color(rgb, head_shadow_from.rgb, tolerance)) {
			tex.rgb = head_shadow_to.rgb;
		}
		else if (same_color(rgb, body_light_from.rgb, tolerance)) {
			tex.rgb = body_light_to.rgb;
		}
		else if (same_color(rgb, body_shadow_from.rgb, tolerance)) {
			tex.rgb = body_shadow_to.rgb;
		}
		else if (same_color(rgb, left_arm_light_from.rgb, tolerance)) {
			tex.rgb = left_arm_light_to.rgb;
		}
		else if (same_color(rgb, left_arm_shadow_from.rgb, tolerance)) {
			tex.rgb = left_arm_shadow_to.rgb;
		}
		else if (same_color(rgb, right_arm_light_from.rgb, tolerance)) {
			tex.rgb = right_arm_light_to.rgb;
		}
		else if (same_color(rgb, right_arm_shadow_from.rgb, tolerance)) {
			tex.rgb = right_arm_shadow_to.rgb;
		}
		else if (same_color(rgb, left_leg_light_from.rgb, tolerance)) {
			tex.rgb = left_leg_light_to.rgb;
		}
		else if (same_color(rgb, left_leg_shadow_from.rgb, tolerance)) {
			tex.rgb = left_leg_shadow_to.rgb;
		}
		else if (same_color(rgb, right_leg_light_from.rgb, tolerance)) {
			tex.rgb = right_leg_light_to.rgb;
		}
		else if (same_color(rgb, right_leg_shadow_from.rgb, tolerance)) {
			tex.rgb = right_leg_shadow_to.rgb;
		}

		tex.rgb = mix(tex.rgb, flash_color.rgb, flash);

		COLOR = tex;
	}
}