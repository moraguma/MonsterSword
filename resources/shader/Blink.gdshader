shader_type canvas_item;


uniform vec4 color : source_color;
uniform float amount : hint_range(0, 1);


void fragment() {
	if (COLOR.a != 0.) {
		COLOR = COLOR * (1. - amount) + color * amount;
	}
}
