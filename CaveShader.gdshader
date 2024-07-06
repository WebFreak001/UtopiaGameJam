// NOTE: Shader automatically converted from Godot Engine 4.2.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

varying vec3 local_pos;


void vertex() {
	local_pos = VERTEX;
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 base_uv = vec2(UV.x * 400.0, local_pos.z);
	vec3 moss_base = vec3(max(0, texture(texture_albedo,base_uv).r - pow(base_uv.y, 1.3)));
	float moss = clamp((4.0 - pow(local_pos.z + 0.5, 2.0)) * pow(local_pos.z, 0.5), 0.0, 1.0);
	ALBEDO = mix(albedo.rgb, mix(albedo.rgb, vec3(0), moss_base.r), min(clamp((moss_base.r - 0.3) * 8.0, 0.0, 1.0), moss));
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
