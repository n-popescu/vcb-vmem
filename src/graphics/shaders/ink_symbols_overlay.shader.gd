


extends Resource
var shader_code: = \
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
"\r\nshader_type canvas_item;\r\nconst float board_size = 2048.0;\r\nconst float brightness_factor = 0.3;\r\nconst float brightness_off = 0.6; \r\nconst float brightness_on = 0.6; \r\nuniform float zoom = 1.0;\r\nuniform float tileset_rows = 8;\r\nuniform float tileset_scale = 0.125; \r\nuniform float visibility = 0.0;\r\nuniform sampler2D smp_ed_logic;\r\nuniform sampler2D smp_tileset;\r\nuniform sampler3D smp_lut;\r\nvec4 get_texel(sampler2D p_smp, vec2 p_coord) {\r\n\tvec2 texel_size = 1.0 / vec2(textureSize(p_smp, 0));\r\n\tvec2 texel_pos = (p_coord * texel_size) + (texel_size * 0.5);\r\n\treturn texture(p_smp, texel_pos);\r\n}\r\nvec4 get_texel3D(sampler3D p_smp, vec3 p_coord) {\r\n\tvec3 texel_size = 1.0 / vec3(textureSize(p_smp, 0));\r\n\tvec3 texel_pos = (p_coord * texel_size) + (texel_size * 0.5);\r\n\treturn texture(p_smp, texel_pos);\r\n}\r\nvoid fragment() {\r\n\tvec3 tex_ed = texture(smp_ed_logic, UV).rgb;\r\n\tvec3 tex_sm = texture(TEXTURE, UV).rgb;\r\n\tvec3 coords = round(vec3(tex_ed * 255.0));\r\n\tfloat symbol_offset = round(get_texel3D(smp_lut, coords).r * 255.0);\r\n\tvec2 offset = round(vec2(mod(symbol_offset, tileset_rows), floor(symbol_offset / tileset_rows)));\r\n\tvec2 uv_tileset = (mod(UV * board_size, 1.0) * tileset_scale) + (offset * tileset_scale);\r\n\tvec4 tex = texture(smp_tileset, uv_tileset);\r\n\tfloat bmask = float((tex_sm.r * 0.3 + tex_sm.g * 0.59 + tex_sm.b * 0.11) > brightness_factor);\r\n\ttex.rgb = mix(tex_sm * brightness_off, tex_sm * brightness_on, bmask);\r\n\ttex.rgb = clamp(tex.rgb, 0.1, 1.0);\r\n\tCOLOR = tex;\r\n\tCOLOR.rgb *= vec3(0.2, 0.2, 0.3) * SCREEN_UV.y + 1.0;\r\n\tCOLOR.a *= visibility;\r\n}\r\n\r\n"