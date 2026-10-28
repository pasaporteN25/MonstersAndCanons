// T532 (RF-726): apaga las franjas externas del host. Solo se aplica a BackgroundTexture, nunca al viewport jugable.
shader_type canvas_item;

uniform float brightness : hint_range(0.0, 1.0) = 1.0;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float luma = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 rgb = mix(vec3(luma), base.rgb, saturation) * brightness;
	COLOR = vec4(rgb, base.a);
}
