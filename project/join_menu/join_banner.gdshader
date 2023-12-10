shader_type canvas_item;

uniform vec4 color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	if (COLOR.a == 1.0 && COLOR.rgb != vec3(0.0, 0.0, 0.0)) {
		COLOR = color;
	}
}
