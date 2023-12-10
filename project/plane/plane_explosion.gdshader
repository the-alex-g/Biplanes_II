shader_type spatial;


void vertex() {
	COLOR.rgb = vec3(1.0, 0.0, 0.0);
}


void fragment() {
	ALBEDO = COLOR.rgb;
}
