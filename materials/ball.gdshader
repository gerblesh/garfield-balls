shader_type spatial;
render_mode cull_front,unshaded;
uniform float blur_amount;
uniform vec4 rim_color: source_color;
uniform float rim_width;
void fragment() {
	vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	vec3 blurred_col = vec3(blurred.x,blurred.y,blurred.z);
	float rim = 1.0 - abs(dot(VIEW,NORMAL));
	float outer_rim = pow(rim,4.0);
	vec3 color = blurred_col + rim * rim_color.rgb;
	ALBEDO = color;
}
