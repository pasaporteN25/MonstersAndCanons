shader_type canvas_item;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 ember : source_color = vec4(1.0, 0.6, 0.3, 1.0);
void fragment() {
    vec4 body = texture(TEXTURE, UV);
    vec2 cell = floor(UV * 160.0);
    float grain = fract(52.9829189 * fract(dot(cell, vec2(0.06711056, 0.00583715))));
    float edge = smoothstep(progress - 0.07, progress + 0.03, grain);
    float rim = (1.0 - smoothstep(progress + 0.02, progress + 0.12, grain)) * edge;
    body.rgb = mix(body.rgb * (1.0 - progress * 0.5), ember.rgb, rim * 0.55);
    body.a *= edge * (1.0 - progress);
    COLOR = body;
}
