shader_type spatial;

uniform vec3 body_color = vec3(0.0, 0.0, 0.0);
const float min_stripe_val = 0.74;
const float max_stripe_val = 0.88;


vec3 get_stripe_color() {
	return vec3(1.0, 1.0, 1.0) - body_color;
}


void vertex() {
	if (VERTEX.z > 2.0) {
		COLOR = vec4(1.0, 0.0, 0.0, 1.0);
	} else if (VERTEX.z < -3.0) {
		COLOR = vec4(0.0, 1.0, 0.0, 1.0);
	}
}

void fragment() {
	
	if (COLOR.r > min_stripe_val && COLOR.r < max_stripe_val) {
		ALBEDO = get_stripe_color();
	} else if (COLOR.g > min_stripe_val && COLOR.g < max_stripe_val) {
		ALBEDO = get_stripe_color();
	} else {
		ALBEDO = body_color;
	}
}
