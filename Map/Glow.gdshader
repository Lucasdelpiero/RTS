shader_type canvas_item;

uniform float glow = 0.2;

void fragment() {
	COLOR.r = COLOR.r + 0.1;
	COLOR.g = COLOR.g + 0.1;
	COLOR.b = COLOR.b + 0.1;
}
