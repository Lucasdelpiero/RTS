shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color: source_color;
uniform vec4 inside_color: source_color;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);
	
	COLOR = mix(col, outline_color, maxa - mina);
	if (col.r > 0.01){
//		COLOR.r = 0.52;
//		COLOR.g = 0.12;
//		COLOR.b = 0.12;
		COLOR.r = inside_color.r;
		COLOR.g = inside_color.g;
		COLOR.b = inside_color.b;
	}
//	COLOR.r = 50.0;
//	COLOR.r = 255.0;
//	if (pixel_color.rgb == vec3(0.0, 0.0, 0.0)) {
//		pixel_color.rgb = vec3(100.0, 100.0, 200.0);
//	}

}