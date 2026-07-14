shader_type canvas_item;

uniform bool outline_enabled = false;
uniform vec4 outline_color : source_color = vec4(1, 1, 1, 1);
uniform float outline_size = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (outline_enabled) {
		vec2 size = outline_size / vec2(textureSize(TEXTURE, 0));
		float alpha = texture(TEXTURE, UV + vec2(size.x, 0)).a
					+ texture(TEXTURE, UV - vec2(size.x, 0)).a
					+ texture(TEXTURE, UV + vec2(0, size.y)).a
					+ texture(TEXTURE, UV - vec2(0, size.y)).a;
		if (color.a < 0.5 && alpha > 0.0) {
			color = outline_color;
		}
	}
	COLOR = color;
}
