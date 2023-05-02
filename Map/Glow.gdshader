shader_type canvas_item;

uniform float glow = 0.2;

void fragment() {
	COLOR.r = COLOR.r + glow;
	COLOR.g = COLOR.g + glow;
	COLOR.b = COLOR.b + glow;
}
