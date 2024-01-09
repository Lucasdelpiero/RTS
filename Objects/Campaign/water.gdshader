
shader_type canvas_item;

uniform sampler2D noise_secondary;

uniform float tile_factor = 10.0;
uniform float aspect_ratio = 0.5;

uniform vec2 time_factor = vec2(2.0, 3.0);
uniform vec2 offset_factor = vec2(5.0, 2.0);
uniform vec2 amplitude = vec2(0.05, 0.05);

void fragment() {
	vec2 tiled_uvs = UV * tile_factor;
	tiled_uvs.y *= aspect_ratio;
	
	vec2 wave_uv_offset;
	wave_uv_offset.x += sin(TIME * time_factor.x + (tiled_uvs.x + tiled_uvs.y) * offset_factor.x);
	wave_uv_offset.y += cos(TIME * time_factor.y + (tiled_uvs.x + tiled_uvs.y) * offset_factor.y);
	
	vec4 new_color = texture(TEXTURE, tiled_uvs + wave_uv_offset * amplitude);
	vec4 secondary_color = texture(noise_secondary, UV);
	
	new_color = mix(new_color, secondary_color, 0.25);
	
	
	
	//COLOR = texture(TEXTURE, tiled_uvs + wave_uv_offset * amplitude);
	COLOR = new_color;
	//COLOR = texture(noise_secondary, UV);
	
}
