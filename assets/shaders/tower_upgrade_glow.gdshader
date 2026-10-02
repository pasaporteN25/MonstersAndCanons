shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 accent : source_color = vec4(1.0, 0.65, 0.2, 1.0);
uniform float strength = 0.0;
uniform float phase = 0.0;

void fragment() {
 vec4 source = texture(TEXTURE, UV);
 float light = dot(source.rgb, vec3(0.299, 0.587, 0.114));
 // El brillo se concentra en los reflejos existentes del metal/cristal, sin alterar la silueta.
 float highlight = smoothstep(0.38, 0.82, light);
 float pulse = 0.88 + 0.12 * sin(phase * 2.0);
 COLOR = vec4(accent.rgb, source.a * highlight * strength * pulse);
}
