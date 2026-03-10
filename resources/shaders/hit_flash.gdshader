shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 original = tex_color * COLOR; // COLOR carries the modulate tint
	COLOR = mix(original, vec4(flash_color.rgb, original.a), flash_amount);
}
